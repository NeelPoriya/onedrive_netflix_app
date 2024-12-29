import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class MediaDetailsPage extends StatefulWidget {
  const MediaDetailsPage({
    super.key,
  });

  @override
  State<MediaDetailsPage> createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  final MediaitemQueryService _mediaItemQueryService = MediaitemQueryService();
  MediaItem? _mediaItem;
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadMediaItem();
      _initialized = true;
    }
  }

  Future<void> _loadMediaItem() async {
    final mediaId = GoRouterState.of(context).pathParameters['mediaId'];
    if (mediaId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final item = await _mediaItemQueryService.getMediaItemById(mediaId);
    if (mounted) {
      setState(() {
        _mediaItem = item;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_mediaItem == null) {
      return const Scaffold(
        body: Center(child: Text('Media not found')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _mediaItem!.backdropImage.isEmpty
                  ? 'https://picsum.photos/seed/picsum/1920/1080'
                  : Constants.tmdbImageEndpoint + _mediaItem!.backdropImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(150),
                    Colors.black.withAlpha(100),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        _mediaItem!.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            _mediaItem!.type.toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _mediaItem!.releaseDate.year.toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 16),
                          if (_mediaItem!.voteAverage > 0) ...[
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _mediaItem!.voteAverage.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _mediaItem!.genre.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: Colors.red.withAlpha(100),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _mediaItem!.tmdbOverview,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withAlpha(150),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            autofocus: true,
                            onPressed: () {
                              GoRouter.of(context)
                                  .push('/play/${_mediaItem!.id}');
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Play',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
