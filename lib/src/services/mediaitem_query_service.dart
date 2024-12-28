import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
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
