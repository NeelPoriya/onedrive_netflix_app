import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';
import 'package:go_router/go_router.dart';

class AlphabeticalListScreen extends StatefulWidget {
  const AlphabeticalListScreen({super.key});

  @override
  State<AlphabeticalListScreen> createState() => _AlphabeticalListScreenState();
}

class _AlphabeticalListScreenState extends State<AlphabeticalListScreen>
    with SingleTickerProviderStateMixin {
  final MediaitemQueryService _mediaItemQueryService = MediaitemQueryService();
  final ScrollController _scrollController = ScrollController();
  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  int _currentPage = 0;
  bool _hasMoreItems = true;
  String? _selectedLetter;
  String? _animatingLetter;
  AnimationController? _animationController;
  int? _selectedItemIndex;
  bool _isItemPressed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (!_isLoading && _hasMoreItems && _selectedLetter != null) {
      setState(() => _isLoading = true);

      final newItems = await _mediaItemQueryService.getMediaItemsByLetter(
        _selectedLetter!,
        page: _currentPage + 1,
        limit: 12,
      );

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreItems = false;
        } else {
          _mediaItems.addAll(newItems);
          _currentPage++;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _onLetterSelected(String letter) async {
    setState(() => _animatingLetter = letter);
    _animationController?.forward(from: 0).then((_) {
      setState(() => _animatingLetter = null);
    });

    setState(() {
      _selectedLetter = letter;
      _mediaItems = [];
      _currentPage = 0;
      _hasMoreItems = true;
      _isLoading = true;
    });

    final items = await _mediaItemQueryService.getMediaItemsByLetter(
      letter,
      page: 0,
      limit: 12,
    );

    setState(() {
      _mediaItems = items;
      _hasMoreItems = items.length == 12;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      constraints: BoxConstraints(
        minHeight: screenHeight,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 56),
            const Text(
              'A-Z List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // A-Z Buttons
            SizedBox(
              height: 100, // Height for two rows
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 13, // Half of 26 for two rows
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 26,
                itemBuilder: (context, index) {
                  final letter = String.fromCharCode(65 + index);
                  return Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.select ||
                            event.logicalKey ==
                                LogicalKeyboardKey.gameButtonA) {
                          _onLetterSelected(letter);
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    onFocusChange: (value) {
                      if (value) {
                        _scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        final isAnimating = _animatingLetter == letter;

                        return AnimatedBuilder(
                          animation: _animationController!,
                          builder: (context, child) {
                            final scale = isAnimating
                                ? Curves.elasticOut
                                    .transform(_animationController!.value)
                                : hasFocus
                                    ? 1.1
                                    : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: TextButton(
                                onPressed: () => _onLetterSelected(letter),
                                style: TextButton.styleFrom(
                                  backgroundColor: _selectedLetter == letter
                                      ? Colors.red
                                      : hasFocus
                                          ? Colors.red.withAlpha(100)
                                          : Colors.transparent,
                                  foregroundColor: _selectedLetter == letter
                                      ? Colors.black
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(letter),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedLetter != null) ...[
              // Grid of results
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 16 / 9,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _mediaItems.length,
                      itemBuilder: (context, index) {
                        final item = _mediaItems[index];
                        return Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey ==
                                      LogicalKeyboardKey.enter ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.select ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.gameButtonA) {
                                if (!context.mounted) {
                                  return KeyEventResult.ignored;
                                }
                                GoRouter.of(context).push('/media/${item.id}');
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              // Calculate actual item height including spacing
                              final width = (MediaQuery.of(context).size.width -
                                      48 -
                                      (3 * 16)) /
                                  4;
                              final itemHeight = width / (16 / 9) +
                                  16; // height + mainAxisSpacing
                              final rowIndex = index ~/ 4;

                              // Calculate target scroll position to center the row
                              final screenHeight =
                                  MediaQuery.of(context).size.height;
                              final topOffset = 56 +
                                  100 +
                                  20; // SizedBox heights + GridView height + spacing
                              final targetScroll = (rowIndex * itemHeight) -
                                  (screenHeight - topOffset) / 2 +
                                  itemHeight / 2;

                              _scrollController.animateTo(
                                targetScroll.clamp(
                                  0,
                                  _scrollController.position.maxScrollExtent,
                                ),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _selectedItemIndex = index;
                                    _isItemPressed = true;
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    if (mounted) {
                                      setState(() {
                                        _isItemPressed = false;
                                        _selectedItemIndex = null;
                                      });
                                      // Navigate to details page
                                      if (!context.mounted) return;
                                      GoRouter.of(context)
                                          .push('/media/${item.id}');
                                    }
                                  });
                                },
                                child: AnimatedScale(
                                  scale: _isItemPressed &&
                                          _selectedItemIndex == index
                                      ? 0.9 // Pressed state
                                      : hasFocus
                                          ? 1.1 // Focused state
                                          : 1.0, // Normal state
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: hasFocus
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            item.backdropImage.isEmpty
                                                ? 'https://placehold.co/600x400'
                                                : Constants
                                                        .tmdbImageEndpointW500 +
                                                    item.backdropImage,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withAlpha(128),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                item.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
