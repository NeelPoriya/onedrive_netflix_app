import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MediaitemQueryService _mediaItemQueryService = MediaitemQueryService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  int _currentPage = 0;
  String _lastSearchTerm = '';
  bool _hasMoreItems = true;
  bool _isSearching = false;
  int? _selectedItemIndex;
  bool _isItemPressed = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 500) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (!_isLoading && _hasMoreItems && _lastSearchTerm.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final newItems = await _mediaItemQueryService.searchMediaItems(
        _lastSearchTerm,
        page: _currentPage + 1,
        limit: 12,
      );

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreItems = false;
        } else {
          _searchResults.addAll(newItems);
          _currentPage++;
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _lastSearchTerm = '';
          _currentPage = 0;
          _hasMoreItems = true;
          _isSearching = false;
        });
        return;
      }

      final results = await _mediaItemQueryService.searchMediaItems(
        query,
        page: 0,
        limit: 12,
      );

      setState(() {
        _searchResults = results;
        _lastSearchTerm = query;
        _currentPage = 0;
        _hasMoreItems = results.length == 12;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 36,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          focusNode: _searchFocusNode,
                          onTapOutside: (event) {
                            if (_searchResults.isNotEmpty) {
                              _searchFocusNode.unfocus();
                              var node = FocusTraversalGroup.of(context)
                                  .findFirstFocusInDirection(
                                _searchFocusNode,
                                TraversalDirection.down,
                              );
                              if (node != null) {
                                FocusScope.of(context).requestFocus(node);
                              }
                              setState(() {});
                            }
                          },
                          onTap: () {
                            _searchFocusNode.requestFocus();
                          },
                          autofocus: true,
                          onEditingComplete: () {
                            if (_searchResults.isNotEmpty) {
                              _searchFocusNode.unfocus();
                              var node = FocusTraversalGroup.of(context)
                                  .findFirstFocusInDirection(
                                _searchFocusNode,
                                TraversalDirection.down,
                              );
                              if (node != null) {
                                FocusScope.of(context).requestFocus(node);
                              }
                              setState(() {});
                            }
                          },
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            labelText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Grid of search results
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
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return Focus(
                        key: Key('search_result_$index'),
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.enter ||
                                event.logicalKey == LogicalKeyboardKey.select ||
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
                            final targetScroll = rowIndex * itemHeight;

                            scrollController.animateTo(
                              targetScroll.clamp(
                                0,
                                scrollController.position.maxScrollExtent,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            setState(() {});
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
                                              ? 'https://picsum.photos/seed/picsum/1920/1080'
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
                                                  Colors.black.withAlpha(150),
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
            SizedBox(
              height: 36,
            ),
          ],
        ),
      ),
    );
  }
}
