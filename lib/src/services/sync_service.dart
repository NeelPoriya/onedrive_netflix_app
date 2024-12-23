import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:onedrive_netflix/src/models/account.model.dart';
import 'package:onedrive_netflix/src/models/folder.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:talker/talker.dart';

class SyncService {
  final Talker _talker = Talker();
  final DatabaseService _databaseService = DatabaseService();
  bool isRunning = false;

  Future<void> sync() async {
    _talker.info("Starting sync...");
    isRunning = true;

    // start time
    DateTime startTime = DateTime.now();

    await _deleteAllMediaItems();
    List<Folder> folders = await _getFoldersFromDatabase();
    if (folders.isEmpty) return;

    List<Account> accounts = await _getAccountsFromDatabase();
    if (accounts.isEmpty) return;

    final RetryClient client = RetryClient(Client());
    String token = await getToken(client);

    await _fetchAndStoreFolderMetadata(client, token, folders, accounts);

    // end time
    DateTime endTime = DateTime.now();

    Duration duration = endTime.difference(startTime);

    isRunning = false;

    _talker.info("Sync took ${duration.inSeconds} seconds");

    _talker.info("Sync completed");
  }

  Future<void> _deleteAllMediaItems() async {
    _talker.info("Deleting all media items from the database...");
    await _databaseService.deleteData('mediaItems');
  }

  Future<List<Folder>> _getFoldersFromDatabase() async {
    _talker.info("Reading all folders from the database...");
    DataSnapshot foldersSnapshot = await _databaseService.getData('folders');
    if (foldersSnapshot.value == null) {
      _talker.info("No folders found in the database");
      return [];
    }
    List<Folder> folders = [];
    (foldersSnapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
      folders.add(Folder.fromMap(key, value));
    });
    _talker.info("Found ${folders.length} folders in the database");
    _talker.info("Folders: ${jsonEncode(folders)}");
    return folders;
  }

  Future<List<Account>> _getAccountsFromDatabase() async {
    _talker.info("Reading all accounts from the database...");
    DataSnapshot accountsSnapshot = await _databaseService.getData('accounts');
    if (accountsSnapshot.value == null) {
      _talker.info("No accounts found in the database");
      return [];
    }
    List<Account> accounts = [];
    (accountsSnapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
      accounts.add(Account.fromMap(key, value));
    });
    _talker.info("Found ${accounts.length} accounts in the database");
    _talker.info("Accounts: ${jsonEncode(accounts)}");
    return accounts;
  }

  Future<void> _fetchAndStoreFolderMetadata(RetryClient client, String token,
      List<Folder> folders, List<Account> accounts) async {
    for (var folder in folders) {
      String accountEmail = accounts
          .firstWhere((account) => account.id == folder.accountId)
          .email;

      Response res = await client.get(
        Uri.parse(
            'https://graph.microsoft.com/beta/users/$accountEmail/drive/root/search(q=\'${folder.name}\')'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        _talker.error("Failed to get folder metadata: ${res.body}");
        return;
      }

      Map<String, dynamic> data = jsonDecode(res.body);

      if (data['value'].length == 0) {
        _talker.info("Folder not found: ${folder.name}");
        continue;
      }

      String driveId = data['value'][0]['parentReference']['driveId'];
      String itemId = data['value'][0]['id'];

      _talker.info("Drive ID: $driveId");
      _talker.info("Item ID: $itemId");

      await _fetchAndStoreFolderChildren(
          client, token, driveId, itemId, folder);
    }
  }

  Future<void> _fetchAndStoreFolderChildren(RetryClient client, String token,
      String driveId, String itemId, Folder folder) async {
    String childrenUrl =
        'https://graph.microsoft.com/beta/drives/$driveId/items/$itemId/children';
    final int maxThreads = 50;
    List<Future> futures = [];

    do {
      Response res = await client.get(
        Uri.parse(childrenUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        _talker.error("Failed to get folder children: ${res.body}");
        return;
      }

      Map<String, dynamic> data = jsonDecode(res.body);

      if (data['value'].length == 0) {
        _talker.info("No children found for folder: ${folder.name}");
        break;
      }

      for (var item in data['value']) {
        if (item['folder'] != null) {
          futures.add(_processFolderItem(client, token, item, folder));
          if (futures.length >= maxThreads) {
            await Future.wait(futures);
            futures.clear();
          }
        } else {
          _talker.info("File: ${item['name']}");
        }
      }

      if (data['@odata.nextLink'] == null) {
        break;
      }

      childrenUrl = data['@odata.nextLink'];
    } while (true);

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _processFolderItem(RetryClient client, String token,
      Map<String, dynamic> item, Folder folder) async {
    // _talker.info("Folder: ${item['name']}");
    Map<String, dynamic> mediaItem = {
      'title': item['name'],
      'folderId': folder.id,
      'onedriveItemId': item['id'],
      'onedriveFolderId': item['parentReference']['id'],
      'webUrl': item['webUrl'],
      'siteId': item['parentReference']['siteId'],
    };

    String title = item['name'];
    title = title.replaceAll(RegExp(r'\(.*\)|\[.*\]|\{.*\}'), '');
    // _talker.info("Searching for: $title");

    RegExp yearRegExp = RegExp(r'\b(19|20)\d{2}\b');
    Match? match = yearRegExp.firstMatch(item['name']);
    String? year;
    if (match != null) {
      year = match.group(0);
    }

    bool isMovie = true;
    String tmdbKey = dotenv.env['TMDB_API_KEY'] ?? '';
    String searchUrl = 'https://api.themoviedb.org/3/search/movie?query=$title';
    if (year != null) {
      searchUrl += '&year=$year';
    }
    Response tmdbRes = await client.get(
      Uri.parse(searchUrl),
      headers: {'Authorization': 'Bearer $tmdbKey'},
    );

    Map<String, dynamic> tmdbData = jsonDecode(tmdbRes.body);

    if (tmdbRes.statusCode != 200) {
      _talker.error("Failed to search TMDB: ${tmdbRes.body}");
      return;
    }

    if (tmdbData['results'].length == 0) {
      searchUrl = 'https://api.themoviedb.org/3/search/tv?query=$title';
      if (year != null) {
        searchUrl += '&first_air_date_year=$year';
      }
      tmdbRes = await client.get(
        Uri.parse(searchUrl),
        headers: {'Authorization': 'Bearer $tmdbKey'},
      );

      if (tmdbRes.statusCode != 200) {
        _talker.error("Failed to search TMDB: ${tmdbRes.body}");
        return;
      }

      tmdbData = jsonDecode(tmdbRes.body);
      isMovie = false;
    }

    if (tmdbData['results'].length > 0) {
      if (isMovie) {
        await _processMovieItem(client, tmdbKey, tmdbData, mediaItem);
      } else {
        await _processTvItem(client, tmdbKey, tmdbData, mediaItem);
      }
    } else {
      mediaItem['isFound'] = false;
    }

    await _databaseService.saveData('mediaItems', mediaItem);
  }

  Future<void> _processMovieItem(RetryClient client, String tmdbKey,
      Map<String, dynamic> tmdbData, Map<String, dynamic> mediaItem) async {
    String tmdbId = tmdbData['results'][0]['id'].toString();
    String movieDetails = 'https://api.themoviedb.org/3/movie/$tmdbId';
    Response movieRes = await client.get(
      Uri.parse(movieDetails),
      headers: {'Authorization': 'Bearer $tmdbKey'},
    );
    Map<String, dynamic> movieData = jsonDecode(movieRes.body);
    mediaItem['genre'] =
        List<String>.from(movieData['genres'].map((genre) => genre['name']));
    mediaItem['adult'] = movieData['adult'];
    mediaItem['budget'] = movieData['budget'];
    mediaItem['backdropImage'] = movieData['backdrop_path'];
    mediaItem['imdbId'] = movieData['imdb_id'];
    mediaItem['popularityId'] = movieData['popularity'];
    mediaItem['posterImage'] = movieData['poster_path'];
    mediaItem['releaseDate'] = movieData['release_date'] != ''
        ? DateTime.parse(movieData['release_date']).toIso8601String()
        : "";
    mediaItem['revenue'] = movieData['revenue'];
    mediaItem['status'] = movieData['status'];
    mediaItem['tmdbId'] = movieData['id'].toString();
    mediaItem['type'] = 'movie';
    mediaItem['voteAverage'] = movieData['vote_average'];
    mediaItem['voteCount'] = movieData['vote_count'];
    mediaItem['isFound'] = true;
  }

  Future<void> _processTvItem(RetryClient client, String tmdbKey,
      Map<String, dynamic> tmdbData, Map<String, dynamic> mediaItem) async {
    String tmdbId = tmdbData['results'][0]['id'].toString();
    String tvDetails = 'https://api.themoviedb.org/3/tv/$tmdbId';
    Response tvRes = await client.get(
      Uri.parse(tvDetails),
      headers: {'Authorization': 'Bearer $tmdbKey'},
    );
    Map<String, dynamic> tvData = jsonDecode(tvRes.body);
    mediaItem['genre'] =
        List<String>.from(tvData['genres'].map((genre) => genre['name']));
    mediaItem['backdropImage'] = tvData['backdrop_path'];
    mediaItem['imdbId'] = tvData['external_ids']['imdb_id'];
    mediaItem['popularityId'] = tvData['popularity'];
    mediaItem['posterImage'] = tvData['poster_path'];
    mediaItem['releaseDate'] = tvData['first_air_date'] != ''
        ? DateTime.parse(tvData['first_air_date']).toIso8601String()
        : '';
    mediaItem['status'] = tvData['status'];
    mediaItem['tmdbId'] = tvData['id'].toString();
    mediaItem['type'] = 'tv';
    mediaItem['voteAverage'] = tvData['vote_average'];
    mediaItem['voteCount'] = tvData['vote_count'];
    mediaItem['isFound'] = true;
  }

  Future<String> getToken(RetryClient client) async {
    String clientId = dotenv.env['CLIENT_ID'] ?? '';
    String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
    String tenantId = dotenv.env['TENANT_ID'] ?? '';

    _talker.info("Client ID: $clientId");
    _talker.info("Client Secret: $clientSecret");
    _talker.info("Tenant ID: $tenantId");

    Response res = await client.post(
      Uri.parse(
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token'),
      body: {
        'client_id': clientId,
        'scope': 'https://graph.microsoft.com/.default',
        'client_secret': clientSecret,
        'grant_type': 'client_credentials'
      },
    );

    if (res.statusCode != 200) {
      _talker.error("Failed to get token: ${res.body}");
      return '';
    }

    Map<String, dynamic> data = jsonDecode(res.body);
    _talker.info("Token fetched : ${data['access_token']}");

    return data['access_token'];
  }
}
