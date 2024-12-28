import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/tv_image_slider.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/hero_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaitemQueryService mediaItemQueryService = MediaitemQueryService();
  final ScrollController _scrollController = ScrollController();
  MediaItem? heroMediaItem;
  List<(String, String, List<MediaItem>)> mediaItemsByGenre = [];

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

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Hero Section
          SizedBox(
            height: screenHeight,
            child: Stack(
              children: [
                if (heroMediaItem != null)
                  Positioned.fill(
                    top: 0,
                    child: HeroMediaItem(
                        mediaItem: heroMediaItem!,
                        scrollController: _scrollController),
                  ),
              ],
            ),
          ),
          // Genre Sliders
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                mediaItemsByGenre.length, // Double the count for movies and TV
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
    );
  }

  void _loadData() async {
    MediaItem? item = await mediaItemQueryService.getRandomMediaItem();
    if (mounted) {
      setState(() {
        heroMediaItem = item;
      });
    }

    mediaItemsByGenre = await mediaItemQueryService
        .getMediaItemsByGenre(genres, ['movie', 'tv']);
    if (mounted) {
      setState(() {
        mediaItemsByGenre = mediaItemsByGenre;
      });
    }
  }
}
