import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

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

  @override
  void initState() {
    super.initState();
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
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 250,
                    child: index < widget.mediaItems.length
                        ? AnimatedScale(
                            scale: _isFocused && _selectedIndex == index
                                ? 1.05
                                : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                Constants.tmdbImageEndpointW500 +
                                    widget.mediaItems[index].backdropImage,
                                fit: BoxFit.cover,
                              ),
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
            children: [
              Text(
                widget.mediaItems.isNotEmpty && _selectedIndex >= 0
                    ? widget.mediaItems[_selectedIndex].title
                    : '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
      ],
    );
  }
}
