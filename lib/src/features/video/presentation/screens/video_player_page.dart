import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/models/history.model.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/models/video.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:onedrive_netflix/src/utils/collection_names.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/services/mediaitem_query_service.dart';
import 'package:talker/talker.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final DatabaseService _databaseService = DatabaseService();
  VideoPlayerController? _videoPlayerController;
  List<Video> _episodes = [];
  final Talker _talker = Talker();
  final MediaitemQueryService _mediaItemQueryService = MediaitemQueryService();
  bool _initialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = false;
  Timer? _hideTimer;
  double _currentSpeed = 1.0;
  int _currentEpisode = 0;
  final List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  final FocusNode _playPauseFocusNode = FocusNode();
  final FocusNode _skipBackFocusNode = FocusNode();
  final FocusNode _skipForwardFocusNode = FocusNode();
  final FocusNode _speedFocusNode = FocusNode();
  final FocusNode _backFocusNode = FocusNode();
  final FocusNode _nextEpisodeFocusNode = FocusNode();
  final FocusNode _moreEpisodesFocusNode = FocusNode();
  final FocusNode _subtitlesFocusNode = FocusNode();
  Timer? _watchHistoryTimer;

  @override
  void initState() {
    super.initState();
    _playPauseFocusNode.addListener(_onFocusChange);
    _skipBackFocusNode.addListener(_onFocusChange);
    _skipForwardFocusNode.addListener(_onFocusChange);
    _speedFocusNode.addListener(_onFocusChange);
    _backFocusNode.addListener(_onFocusChange);
    _nextEpisodeFocusNode.addListener(_onFocusChange);
    _moreEpisodesFocusNode.addListener(_onFocusChange);
    _subtitlesFocusNode.addListener(_onFocusChange);
    _playPauseFocusNode.requestFocus();
  }

  void _onFocusChange() {
    setState(() {
      // This empty setState will trigger a rebuild with the new focus state
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _hideTimer?.cancel();
    _watchHistoryTimer?.cancel();
    _playPauseFocusNode.removeListener(_onFocusChange);
    _skipBackFocusNode.removeListener(_onFocusChange);
    _skipForwardFocusNode.removeListener(_onFocusChange);
    _speedFocusNode.removeListener(_onFocusChange);
    _backFocusNode.removeListener(_onFocusChange);
    _nextEpisodeFocusNode.removeListener(_onFocusChange);
    _moreEpisodesFocusNode.removeListener(_onFocusChange);
    _subtitlesFocusNode.removeListener(_onFocusChange);
    _playPauseFocusNode.dispose();
    _skipBackFocusNode.dispose();
    _skipForwardFocusNode.dispose();
    _speedFocusNode.dispose();
    _backFocusNode.dispose();
    _nextEpisodeFocusNode.dispose();
    _moreEpisodesFocusNode.dispose();
    _subtitlesFocusNode.dispose();
    super.dispose();
  }

  void _resetControlsTimer() {
    _hideTimer?.cancel();
    setState(() => _showControls = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoPlayerController?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null) return;
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    });
    _resetControlsTimer();
  }

  void _skipBackward() {
    if (_videoPlayerController == null) return;
    final newPosition =
        _videoPlayerController!.value.position - const Duration(seconds: 10);
    _videoPlayerController!.seekTo(newPosition);
    _resetControlsTimer();
  }

  void _skipForward() {
    if (_videoPlayerController == null) return;
    final newPosition =
        _videoPlayerController!.value.position + const Duration(seconds: 10);
    _videoPlayerController!.seekTo(newPosition);
    _resetControlsTimer();
  }

  void _changeSpeed() {
    if (_videoPlayerController == null) return;
    final currentIndex = _availableSpeeds.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % _availableSpeeds.length;
    setState(() {
      _currentSpeed = _availableSpeeds[nextIndex];
      _videoPlayerController!.setPlaybackSpeed(_currentSpeed);
    });
    _resetControlsTimer();
  }

  void _goBack() {
    context.pop();
  }

  void _handleNextEpisode(int episodeIndex) async {
    if (episodeIndex == _currentEpisode) return;

    // Save current progress before switching episodes
    await _updateWatchHistory();

    setState(() {
      _currentEpisode = episodeIndex;
    });

    if (_currentEpisode >= _episodes.length) {
      _currentEpisode = 0;
    }

    _talker.info(
        'Loading video: ${_episodes[_currentEpisode].title} ${_episodes[_currentEpisode].url}');

    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_episodes[_currentEpisode].url));

    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();

    // Restart the watch history timer
    _watchHistoryTimer?.cancel();
    _watchHistoryTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateWatchHistory(),
    );

    _resetControlsTimer();
  }

  void _showEpisodesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => EpisodesBottomSheet(
        episodes: _episodes,
        currentEpisode: _currentEpisode,
        onEpisodeSelected: (index) {
          Navigator.pop(context);
          _handleNextEpisode(index);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final mediaId = GoRouterState.of(context).pathParameters['mediaId'] ?? '';
      _loadVideo(mediaId);
      _initialized = true;
    }
  }

  Future<void> _loadVideo(String mediaId) async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      final videos = await _mediaItemQueryService.getListOfUrls(mediaId);
      User? getUser = await GlobalAuthService.instance.getUser();

      // getting watch history for current user for this media item
      final watchHistory = await _databaseService.getDataWithFilter(
          CollectionNames.watchHistory,
          'mediaId_userId',
          '${mediaId}_${getUser!.id}');

      setState(() {
        _episodes = videos;
      });

      if (!mounted) return;

      if (videos.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No videos found for this item';
        });
        return;
      }

      // Set initial episode and position based on watch history
      int startEpisode = 0;
      Duration startPosition = Duration.zero;

      if (watchHistory.value != null) {
        final historyData = watchHistory.value as Map<dynamic, dynamic>;
        String id = historyData.keys.first;
        Map<dynamic, dynamic> values = historyData.values.first;
        final history = History.fromMap(id, values);

        // Find the episode index that matches the saved onedriveItemId
        final savedEpisodeIndex = _episodes
            .indexWhere((episode) => episode.id == history.onedriveItemId);

        if (savedEpisodeIndex != -1) {
          startEpisode = savedEpisodeIndex;
          startPosition = Duration(seconds: history.timestamp);
        }
      }

      setState(() {
        _currentEpisode = startEpisode;
      });

      _talker.info('Loading video: ${videos[_currentEpisode].url}');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_episodes[_currentEpisode].url),
      );

      await _videoPlayerController!.initialize();
      await _videoPlayerController!.seekTo(startPosition);
      await _videoPlayerController!.play();

      // Start the watch history timer
      _watchHistoryTimer?.cancel();
      _watchHistoryTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _updateWatchHistory(),
      );

      _resetControlsTimer();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage =
            'Error loading video: $e\nStack Trace: ${StackTrace.current}';
      });
    }
  }

  Future<void> _updateWatchHistory() async {
    if (_videoPlayerController == null || !mounted) return;

    final mediaId = GoRouterState.of(context).pathParameters['mediaId'] ?? '';
    final user = await GlobalAuthService.instance.getUser();
    if (user == null) return;

    final currentPosition = _videoPlayerController!.value.position.inSeconds;

    // First try to get existing watch history
    final watchHistory = await _databaseService.getDataWithFilter(
        CollectionNames.watchHistory,
        'mediaId_userId',
        '${mediaId}_${user.id}');

    History history;
    if (watchHistory.value != null) {
      final historyData = watchHistory.value as Map<dynamic, dynamic>;
      String id = historyData.keys.first;
      Map<dynamic, dynamic> values = historyData.values.first;
      // Update existing history
      history = History.fromMap(id, values);
      history.userId = user.id;
      history.lastWatchedAt = DateTime.now();
      history.onedriveItemId = _episodes[_currentEpisode].id;
      history.timestamp = currentPosition;
      history.modifiedAt = DateTime.now();

      await _databaseService.updateData(
          '${CollectionNames.watchHistory}/$id', history.toJson());
    } else {
      // Create new history if none exists
      history = History()
        ..mediaId_userId = '${mediaId}_${user.id}'
        ..lastWatchedAt = DateTime.now()
        ..userId = user.id
        ..onedriveItemId = _episodes[_currentEpisode].id
        ..timestamp = currentPosition
        ..createdAt = DateTime.now()
        ..modifiedAt = DateTime.now();

      await _databaseService.saveData(
          CollectionNames.watchHistory, history.toJson());
    }
  }

  BoxDecoration _getFocusDecoration(bool hasFocus, {bool isCircular = true}) {
    return BoxDecoration(
      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircular ? null : BorderRadius.circular(20),
      color: hasFocus ? Colors.white.withAlpha(40) : Colors.transparent,
      border: hasFocus
          ? Border.all(color: Colors.white.withAlpha(20), width: 2)
          : Border.all(color: Colors.white.withAlpha(0), width: 2),
    );
  }

  Color _getFocusTextColor(bool hasFocus) {
    return hasFocus ? Colors.white : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          _resetControlsTimer();

          // check if none of the focus nodes are focused
          if (!_playPauseFocusNode.hasFocus &&
              !_skipBackFocusNode.hasFocus &&
              !_skipForwardFocusNode.hasFocus &&
              !_speedFocusNode.hasFocus &&
              !_backFocusNode.hasFocus &&
              !_nextEpisodeFocusNode.hasFocus &&
              !_moreEpisodesFocusNode.hasFocus &&
              !_subtitlesFocusNode.hasFocus) {
            _playPauseFocusNode.requestFocus();
            setState(() {});
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _resetControlsTimer(),
          onTapUp: (_) => _resetControlsTimer(),
          onTapCancel: () => _resetControlsTimer(),
          onPanStart: (_) => _resetControlsTimer(),
          onPanUpdate: (_) => _resetControlsTimer(),
          onPanEnd: (_) => _resetControlsTimer(),
          child: MouseRegion(
            onHover: (_) => _resetControlsTimer(),
            onEnter: (_) => _resetControlsTimer(),
            child: Stack(
              children: [
                if (_videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  )
                else if (_hasError)
                  Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),

                // Custom Controls Overlay
                if (_showControls && _videoPlayerController != null)
                  Container(
                    color: Colors.black54,
                    child: Stack(
                      children: [
                        // Back Button (Top Left)
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Focus(
                            focusNode: _backFocusNode,
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent) {
                                _resetControlsTimer();
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.select ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.gameButtonA) {
                                  _goBack();
                                  return KeyEventResult.handled;
                                }

                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowRight) {
                                  _speedFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  _skipBackFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration:
                                  _getFocusDecoration(_backFocusNode.hasFocus),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                color:
                                    _getFocusTextColor(_backFocusNode.hasFocus),
                                onPressed: _goBack,
                              ),
                            ),
                          ),
                        ),

                        // Center Controls
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Skip Backward Button
                              Focus(
                                focusNode: _skipBackFocusNode,
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent) {
                                    _resetControlsTimer();
                                    if (event.logicalKey ==
                                            LogicalKeyboardKey.select ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.gameButtonA) {
                                      _skipBackward();
                                      return KeyEventResult.handled;
                                    }

                                    if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowLeft ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.arrowUp) {
                                      _backFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowRight) {
                                      _playPauseFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown) {
                                      _moreEpisodesFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: _getFocusDecoration(
                                      _skipBackFocusNode.hasFocus),
                                  child: IconButton(
                                    iconSize: 40,
                                    icon: const Icon(Icons.replay_10),
                                    color: _getFocusTextColor(
                                        _skipBackFocusNode.hasFocus),
                                    onPressed: _skipBackward,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              // Play/Pause Button
                              Focus(
                                focusNode: _playPauseFocusNode,
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent) {
                                    _resetControlsTimer();
                                    if (event.logicalKey ==
                                            LogicalKeyboardKey.select ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.gameButtonA) {
                                      _togglePlayPause();
                                      return KeyEventResult.handled;
                                    }

                                    if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowLeft) {
                                      _skipBackFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowRight) {
                                      _skipForwardFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowUp) {
                                      _speedFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown) {
                                      _moreEpisodesFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                                onFocusChange: (value) {
                                  if (value) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: _getFocusDecoration(
                                      _playPauseFocusNode.hasFocus),
                                  child: IconButton(
                                    iconSize: 56,
                                    icon: Icon(
                                      _videoPlayerController!.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    color: _getFocusTextColor(
                                        _playPauseFocusNode.hasFocus),
                                    onPressed: _togglePlayPause,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              // Skip Forward Button
                              Focus(
                                focusNode: _skipForwardFocusNode,
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent) {
                                    _resetControlsTimer();
                                    if (event.logicalKey ==
                                            LogicalKeyboardKey.select ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.gameButtonA) {
                                      _skipForward();
                                      return KeyEventResult.handled;
                                    }

                                    if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowLeft) {
                                      _playPauseFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowUp) {
                                      _speedFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown) {
                                      _subtitlesFocusNode.requestFocus();
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: _getFocusDecoration(
                                      _skipForwardFocusNode.hasFocus),
                                  child: IconButton(
                                    iconSize: 40,
                                    icon: const Icon(Icons.forward_10),
                                    color: _getFocusTextColor(
                                        _skipForwardFocusNode.hasFocus),
                                    onPressed: _skipForward,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Speed Control (Top Right)
                        Positioned(
                          top: 20,
                          right: 80,
                          child: Focus(
                            focusNode: _speedFocusNode,
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent) {
                                _resetControlsTimer();
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.select ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.gameButtonA) {
                                  _changeSpeed();
                                  return KeyEventResult.handled;
                                }

                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowLeft) {
                                  _backFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowRight) {
                                  _nextEpisodeFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  _skipForwardFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: _getFocusDecoration(
                                  _speedFocusNode.hasFocus,
                                  isCircular: false),
                              child: TextButton(
                                onPressed: _changeSpeed,
                                child: Text(
                                  '${_currentSpeed}x',
                                  style: TextStyle(
                                    color: _getFocusTextColor(
                                        _speedFocusNode.hasFocus),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Next Episode Button (Top Right)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Focus(
                            focusNode: _nextEpisodeFocusNode,
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent) {
                                _resetControlsTimer();
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.select ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.gameButtonA) {
                                  _handleNextEpisode(_currentEpisode + 1);
                                  return KeyEventResult.handled;
                                }

                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowLeft) {
                                  _speedFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  _skipForwardFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: _getFocusDecoration(
                                  _nextEpisodeFocusNode.hasFocus),
                              child: IconButton(
                                icon: const Icon(Icons.skip_next),
                                color: Colors.white54,
                                onPressed: () {
                                  _handleNextEpisode(_currentEpisode + 1);
                                },
                              ),
                            ),
                          ),
                        ),

                        // Progress Bar
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _videoPlayerController!,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.white24,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Focus(
                                    focusNode: _moreEpisodesFocusNode,
                                    onKeyEvent: (node, event) {
                                      if (event is KeyDownEvent) {
                                        _resetControlsTimer();
                                        if (event.logicalKey ==
                                                LogicalKeyboardKey.select ||
                                            event.logicalKey ==
                                                LogicalKeyboardKey.enter ||
                                            event.logicalKey ==
                                                LogicalKeyboardKey
                                                    .gameButtonA) {
                                          _showEpisodesBottomSheet();
                                          return KeyEventResult.handled;
                                        }

                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowRight) {
                                          _subtitlesFocusNode.requestFocus();
                                          return KeyEventResult.handled;
                                        } else if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowUp) {
                                          _playPauseFocusNode.requestFocus();
                                          return KeyEventResult.handled;
                                        }
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                    child: Container(
                                      decoration: _getFocusDecoration(
                                        _moreEpisodesFocusNode.hasFocus,
                                        isCircular: false,
                                      ),
                                      child: TextButton.icon(
                                        icon: Icon(
                                          Icons.list,
                                          color: _getFocusTextColor(
                                              _moreEpisodesFocusNode.hasFocus),
                                        ),
                                        label: Text(
                                          'More Episodes',
                                          style: TextStyle(
                                            color: _getFocusTextColor(
                                                _moreEpisodesFocusNode
                                                    .hasFocus),
                                          ),
                                        ),
                                        onPressed: _showEpisodesBottomSheet,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Focus(
                                    focusNode: _subtitlesFocusNode,
                                    onKeyEvent: (node, event) {
                                      if (event is KeyDownEvent) {
                                        _resetControlsTimer();
                                        if (event.logicalKey ==
                                                LogicalKeyboardKey.select ||
                                            event.logicalKey ==
                                                LogicalKeyboardKey.enter ||
                                            event.logicalKey ==
                                                LogicalKeyboardKey
                                                    .gameButtonA) {
                                          // TODO: Implement subtitles functionality
                                          return KeyEventResult.handled;
                                        }

                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowLeft) {
                                          _moreEpisodesFocusNode.requestFocus();
                                          return KeyEventResult.handled;
                                        } else if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowUp) {
                                          _skipForwardFocusNode.requestFocus();
                                          return KeyEventResult.handled;
                                        }
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                    child: Container(
                                      decoration: _getFocusDecoration(
                                        _subtitlesFocusNode.hasFocus,
                                        isCircular: false,
                                      ),
                                      child: TextButton.icon(
                                        icon: Icon(
                                          Icons.subtitles,
                                          color: _getFocusTextColor(
                                              _subtitlesFocusNode.hasFocus),
                                        ),
                                        label: Text(
                                          'Subtitles',
                                          style: TextStyle(
                                            color: _getFocusTextColor(
                                                _subtitlesFocusNode.hasFocus),
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO: Implement subtitles functionality
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EpisodesBottomSheet extends StatefulWidget {
  final List<Video> episodes;
  final int currentEpisode;
  final Function(int) onEpisodeSelected;

  const EpisodesBottomSheet({
    super.key,
    required this.episodes,
    required this.currentEpisode,
    required this.onEpisodeSelected,
  });

  @override
  State<EpisodesBottomSheet> createState() => _EpisodesBottomSheetState();
}

class _EpisodesBottomSheetState extends State<EpisodesBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  int _focusedIndex = 0;
  static const double _verticalPadding = 12.0;
  static const double _itemContentHeight = 24.0; // Height of text/icon
  static const double _headerHeight = 52.0; // Height of the "Episodes" header

  @override
  void initState() {
    super.initState();
    _focusedIndex = widget.currentEpisode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(_focusedIndex);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double get _itemHeight => _verticalPadding * 2 + _itemContentHeight;

  double get _totalHeight {
    final itemsHeight = widget.episodes.length * _itemHeight;
    return _headerHeight +
        itemsHeight.clamp(0, 400); // Max height of 400 + header
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final targetOffset = index * _itemHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      height: _totalHeight,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Episodes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                final episode = widget.episodes[index];
                final isSelected = index == widget.currentEpisode;

                return Focus(
                  autofocus: isSelected,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      setState(() {
                        _focusedIndex = index;
                      });
                      _scrollToIndex(index);
                    }
                  },
                  onKeyEvent: (node, event) {
                    if (event is! KeyDownEvent) return KeyEventResult.ignored;
                    if (event.logicalKey == LogicalKeyboardKey.select ||
                        event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
                      widget.onEpisodeSelected(index);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Builder(
                    builder: (context) {
                      final isFocused = Focus.of(context).hasFocus;

                      return InkWell(
                        onTap: () => widget.onEpisodeSelected(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isFocused
                                ? Colors.white.withAlpha(150)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.play_arrow,
                                  color: Colors.red,
                                  size: 20,
                                )
                              else
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(150),
                                    fontSize: 16,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  episode.title,
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.red : Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
