import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/tv_image_slider.dart';
import 'package:onedrive_netflix/src/models/history.model.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/hero_content.dart';
import 'package:onedrive_netflix/src/utils/collection_names.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaitemQueryService mediaItemQueryService = MediaitemQueryService();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService databaseService = DatabaseService();
  MediaItem? heroMediaItem;
  List<(String, String, List<MediaItem>)> mediaItemsByGenre = [];
  List<MediaItem> historyMediaItems = [];
  bool _isHeroLoading = true;
  bool _isGenreLoading = true;

  final List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentry',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isHeroLoading = true;
          _isGenreLoading = true;
          historyMediaItems = [];
        });
        return _loadData();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            SizedBox(
              height: screenHeight,
              child: Stack(
                children: [
                  if (_isHeroLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (heroMediaItem != null)
                    Positioned.fill(
                      top: 0,
                      child: HeroMediaItem(
                          mediaItem: heroMediaItem!,
                          scrollController: _scrollController),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (historyMediaItems.isNotEmpty)
              TVImageSlider(
                  homeScrollController: _scrollController,
                  genre: 'Continue Watching',
                  type: '',
                  title: 'Continue Watching',
                  mediaItems: historyMediaItems),
            // Genre Sliders
            if (_isGenreLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mediaItemsByGenre.length,
                itemBuilder: (context, index) {
                  return TVImageSlider(
                    homeScrollController: _scrollController,
                    genre: mediaItemsByGenre[index].$1,
                    type: mediaItemsByGenre[index].$2,
                    title:
                        '${mediaItemsByGenre[index].$1} ${mediaItemsByGenre[index].$2 == 'movie' ? 'Movies' : 'TV Shows'}',
                    mediaItems: mediaItemsByGenre[index].$3,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    // Load hero media item
    MediaItem? item = await mediaItemQueryService.getRandomMediaItem();
    if (mounted) {
      setState(() {
        heroMediaItem = item;
        _isHeroLoading = false;
      });
    }

    await mediaItemQueryService.getListOfUrls('-OExJl8rdkfvza1nICNL');

    // Load genre media items
    mediaItemsByGenre = await mediaItemQueryService
        .getMediaItemsByGenre(genres, ['movie', 'tv']);
    if (mounted) {
      setState(() {
        mediaItemsByGenre = mediaItemsByGenre;
      });
    }

    // Load history items
    List<History> history = [];
    final snapshot =
        await databaseService.getData(CollectionNames.watchHistory);

    if (snapshot.value == null) {
      return;
    }

    final historyData = snapshot.value as Map<dynamic, dynamic>;
    historyData.forEach((key, value) {
      history.add(History.fromMap(key, value));
    });

    history.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    // only keep the first 10 items
    history = history.take(10).toList();

    for (var item in history) {
      final mediaId = item.mediaId_userId.split('_')[0];
      final mediaItem = await mediaItemQueryService.getMediaItemById(mediaId);
      if (mediaItem != null) {
        historyMediaItems.add(mediaItem);
      }
    }

    if (mounted) {
      setState(() {
        historyMediaItems = historyMediaItems;
        _isGenreLoading = false;
      });
    }
  }
}
