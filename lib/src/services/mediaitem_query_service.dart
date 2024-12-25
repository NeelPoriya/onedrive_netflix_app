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
      String genre, int limit) async {
    final DataSnapshot snapshot = await _db.child(_path).get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    // Filter items where genre array contains the requested genre
    final filteredData = data.entries.where((entry) {
      final List<dynamic> genres =
          (entry.value['genre'] as List<dynamic>?) ?? [];
      return genres.contains(genre);
    }).take(limit);

    return filteredData.map((e) => MediaItem.fromMap(e.key, e.value)).toList();
  }
}
