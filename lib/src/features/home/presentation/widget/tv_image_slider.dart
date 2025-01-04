import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';
import 'package:go_router/go_router.dart';

class TVImageSlider extends StatefulWidget {
  final ScrollController homeScrollController;
  final String genre;
  final String type;
  final String title;
  final List<MediaItem> mediaItems;
  const TVImageSlider({
    super.key,
    required this.homeScrollController,
    required this.genre,
    required this.type,
    required this.title,
    required this.mediaItems,
  });

  @override
  State<TVImageSlider> createState() => _TVImageSliderState();
}

class _TVImageSliderState extends State<TVImageSlider> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  final int _paddingItems = 10;
  final double _itemTotalWidth = 250.0 + 16.0;
  bool _isFocused = false;
  int? _longPressIndex;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final maxScrollExtent =
          (_itemTotalWidth * widget.mediaItems.length + 1) - _itemTotalWidth;
      if (_scrollController.offset > maxScrollExtent) {
        _scrollController.jumpTo(maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onKeyPressed(LogicalKeyboardKey key, FocusNode node) {
    if (key == LogicalKeyboardKey.arrowRight &&
        _selectedIndex < widget.mediaItems.length - 1) {
      setState(() {
        _selectedIndex++;
      });
      _scrollController.animateTo(
        _selectedIndex * _itemTotalWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (key == LogicalKeyboardKey.arrowLeft && _selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });
      _scrollController.animateTo(
        _selectedIndex * _itemTotalWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (key == LogicalKeyboardKey.arrowUp) {
      // pass the focus to upside
      if (node.focusInDirection(TraversalDirection.up)) {}
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (node.focusInDirection(TraversalDirection.down)) {}
    } else if ((key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.gameButtonA) &&
        _selectedIndex < widget.mediaItems.length) {
      // Navigate to media details
      context.push('/media/${widget.mediaItems[_selectedIndex].id}');
    }
  }

  void _scrollToCenter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the RenderBox of the current slider
      RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // Get the position of this slider relative to the viewport
        final position = renderBox.localToGlobal(Offset.zero);

        // Get the screen height
        final screenHeight = MediaQuery.of(context).size.height;

        // Calculate target offset to center this slider
        final targetOffset = widget.homeScrollController.offset +
            position.dy -
            (screenHeight / 2) +
            (renderBox.size.height / 2);

        // Animate to the target position
        widget.homeScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return const SizedBox.shrink(); // Return nothing if no items
    }

    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                _onKeyPressed(event.logicalKey, node);
              }
              return KeyEventResult.handled;
            },
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
                if (hasFocus) {
                  _scrollToCenter();
                }
              });
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.mediaItems.length + _paddingItems,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    _scrollController.animateTo(
                      _selectedIndex * _itemTotalWidth,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    if (index < widget.mediaItems.length) {
                      context.push('/media/${widget.mediaItems[index].id}');
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _longPressIndex = index;
                    });
                  },
                  onLongPressEnd: (_) {
                    setState(() {
                      _longPressIndex = null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 250,
                    height: 150,
                    child: index < widget.mediaItems.length
                        ? AnimatedScale(
                            scale: (_isFocused && _selectedIndex == index) ||
                                    _longPressIndex == index
                                ? 1.05
                                : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      widget.mediaItems[index].backdropImage
                                              .isEmpty
                                          ? 'https://picsum.photos/seed/picsum/1920/1080'
                                          : Constants.tmdbImageEndpointW500 +
                                              widget.mediaItems[index]
                                                  .backdropImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (_longPressIndex == index)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withAlpha(150),
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: AnimatedOpacity(
                                        opacity: _longPressIndex == index
                                            ? 1.0
                                            : 0.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Text(
                                          widget.mediaItems[index].title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: _isFocused ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: AnimatedSlide(
                  offset: Offset(0, _isFocused ? 0 : 0.5),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: 250,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.mediaItems.isNotEmpty && _selectedIndex >= 0
                            ? widget.mediaItems[_selectedIndex].title
                            : '',
                        key: ValueKey<int>(_selectedIndex),
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
