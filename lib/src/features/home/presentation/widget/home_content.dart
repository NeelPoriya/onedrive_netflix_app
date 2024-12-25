import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/hero_content.dart';
import 'package:talker/talker.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  MediaitemQueryService mediaItemQueryService = MediaitemQueryService();
  final _talker = Talker();

  MediaItem? heroMediaItem;
  List<MediaItem> actionItems = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenHeight, // 80% of screen height
              child: Stack(
                children: [
                  // Hero Content
                  if (heroMediaItem != null)
                    Positioned.fill(
                      child: HeroMediaItem(mediaItem: heroMediaItem!),
                    ),

                  // Top Navigation Icons
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon:
                                const Icon(Icons.search, color: Colors.white)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.settings,
                                color: Colors.white)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications,
                                color: Colors.white)),
                        IconButton(
                            onPressed: () {},
                            icon:
                                const Icon(Icons.person, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: ListView(
        children: [
          // Add more carousels here
        ],
      ),
    );
  }

  void _loadData() async {
    MediaItem? item = await mediaItemQueryService.getRandomMediaItem();
    setState(() {
      heroMediaItem = item;
    });

    List<MediaItem> items =
        await mediaItemQueryService.getRandomMediaItemsByGenre('Action', 10);
    setState(() {
      actionItems = items;
    });
  }
}
