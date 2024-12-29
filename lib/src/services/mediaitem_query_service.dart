import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/models/video.model.dart';
import 'package:talker/talker.dart';

class MediaitemQueryService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _path = 'mediaItems';
  final Talker _talker = Talker();

  Future<MediaItem?> getRandomMediaItem() async {
    // find number of media items with filter isFound = true
    final DataSnapshot snapshot =
        await _db.child(_path).orderByChild('isFound').equalTo(true).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    if (data.isEmpty) {
      _talker.info('No media items found');
      return null;
    }

    final int count = data.length;

    // get a random number between 0 and count
    Random random = Random();
    int randomIndex = random.nextInt(count);

    // get the media item at the random index
    MediaItem randomMediaItem = MediaItem.fromMap(
      data.keys.elementAt(randomIndex),
      data.values.elementAtOrNull(randomIndex),
    );

    return randomMediaItem;
  }

  Future<List<MediaItem>> getRandomMediaItemsByGenre(
      String genre, int limit, String type) async {
    final DataSnapshot snapshot =
        await _db.child(_path).orderByChild('isFound').equalTo(true).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    // Filter items where genre array contains the requested genre AND type matches
    final filteredData = data.entries.where((entry) {
      final List<dynamic> genres =
          (entry.value['genre'] as List<dynamic>?) ?? [];
      final String itemType = entry.value['type'] as String? ?? '';
      return genres.contains(genre) && itemType == type;
    }).toList();

    // Shuffle the filtered data
    filteredData.shuffle();

    // Take first 'limit' items after shuffling
    final randomizedData = filteredData.take(limit);

    return randomizedData
        .map((e) => MediaItem.fromMap(e.key, e.value))
        .toList();
  }

  Future<List<MediaItem>> searchMediaItems(String searchTerm,
      {int page = 0, int limit = 20}) async {
    final DataSnapshot snapshot =
        await _db.child(_path).orderByChild('isFound').equalTo(true).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    // Clean up search term: remove punctuation and convert to lowercase
    final cleanSearchTerm = searchTerm
        .toLowerCase()
        .replaceAll(RegExp(r'[.,:]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    // Split into words for individual matching
    final searchWords = cleanSearchTerm.split(' ');

    if (searchWords.isEmpty) {
      return [];
    }

    // Filter items where title contains any of the search words
    final filteredData = data.entries.where((entry) {
      final String title = (entry.value['title'] as String? ?? '')
          .toLowerCase()
          .replaceAll(RegExp(r'[.,:]'), ' ')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      return searchWords.every((word) => title.contains(word));
    }).toList();

    // Apply pagination
    final start = page * limit;
    final paginatedData = filteredData.skip(start).take(limit);

    return paginatedData.map((e) => MediaItem.fromMap(e.key, e.value)).toList();
  }

  Future<List<(String, String, List<MediaItem>)>> getMediaItemsByGenre(
      List<String> genres, List<String> types) async {
    final DataSnapshot snapshot =
        await _db.child(_path).orderByChild('isFound').equalTo(true).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    List<(String, String, List<MediaItem>)> result = [];

    for (String genre in genres) {
      for (String type in types) {
        final filteredData = data.entries.where((entry) {
          final List<dynamic> genres =
              (entry.value['genre'] as List<dynamic>?) ?? [];
          final String itemType = entry.value['type'] as String? ?? '';
          return genres.contains(genre) && itemType == type;
        }).toList();
        filteredData.shuffle();
        result.add((
          genre,
          type,
          filteredData
              .take(10)
              .map((e) => MediaItem.fromMap(e.key, e.value))
              .toList()
        ));
      }
    }

    return result;
  }

  Future<List<Video>> getListOfUrls(String mediaItemId) async {
    final start = DateTime.now();
    try {
      final DataSnapshot snapshot =
          await _db.child(_path).child(mediaItemId).get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      MediaItem mediaItem = MediaItem.fromMap(mediaItemId, data);

      final RetryClient client = RetryClient(Client());
      String token = await getToken(client);

      final videos = await getVideosFromChildren(
          mediaItem.driveId, mediaItem.onedriveItemId, token);

      return videos;
    } catch (e) {
      _talker.error(e);
      _talker.error(StackTrace.current);
      return [];
    } finally {
      final end = DateTime.now();
      _talker.info('Time taken: ${end.difference(start).inSeconds} seconds');
    }
  }

  Future<List<Video>> getVideosFromChildren(
      String driveId, String itemId, String token) async {
    List<Video> videos = [];
    final children = await getAllChildren(driveId, itemId, token);
    final videoFormats = [
      'video/mp4',
      'video/mpeg',
      'video/avi',
      'video/wmv',
      'video/mov',
      'video/flv',
      'video/webm',
      'video/mkv'
    ];
    for (var child in children) {
      if (child['file'] != null &&
          videoFormats.contains(child['file']['mimeType'])) {
        String downloadUrl;
        if (child['@microsoft.graph.downloadUrl'] != null) {
          downloadUrl = child['@microsoft.graph.downloadUrl'];
        } else if (child['@content.downloadUrl'] != null) {
          downloadUrl = child['@content.downloadUrl'];
        } else {
          continue;
        }
        Video video = Video(
          url: downloadUrl,
          title: child['name'],
          id: child['id'],
        );
        videos.add(video);
      } else if (child['folder'] != null) {
        videos.addAll(await getVideosFromChildren(driveId, child['id'], token));
      }
    }
    return videos;
  }

  Future<List<dynamic>> getAllChildren(
      String driveId, String itemId, String token) async {
    final RetryClient client = RetryClient(Client());
    String nextLink =
        'https://graph.microsoft.com/beta/drives/$driveId/items/$itemId/children';
    List<dynamic> children = [];
    do {
      final Response res = await client.get(Uri.parse(nextLink),
          headers: {'Authorization': 'Bearer $token'});
      final d = jsonDecode(res.body);
      children.addAll(d['value']);

      if (d['@odata.nextLink'] != null) {
        nextLink = d['@odata.nextLink'];
      } else {
        nextLink = '';
      }
    } while (nextLink.isNotEmpty);
    return children;
  }

  Future<String> getToken(RetryClient client) async {
    String clientId = dotenv.env['CLIENT_ID'] ?? '';
    String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
    String tenantId = dotenv.env['TENANT_ID'] ?? '';

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

    return data['access_token'];
  }

  Future<List<MediaItem>> getMediaItemsByLetter(String letter,
      {int page = 0, int limit = 12}) async {
    final DataSnapshot snapshot =
        await _db.child(_path).orderByChild('isFound').equalTo(true).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    // Filter items where title starts with the letter
    final filteredData = data.entries.where((entry) {
      final String title = (entry.value['title'] as String? ?? '').trim();
      return title.toUpperCase().startsWith(letter);
    }).toList();

    // Apply pagination
    final start = page * limit;
    final paginatedData = filteredData.skip(start).take(limit);

    return paginatedData.map((e) => MediaItem.fromMap(e.key, e.value)).toList();
  }

  Future<MediaItem?> getMediaItemById(String id) async {
    final DataSnapshot snapshot = await _db.child('$_path/$id').get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    return MediaItem.fromMap(id, data);
  }
}
