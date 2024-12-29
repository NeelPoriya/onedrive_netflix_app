import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/models/video.model.dart';
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

  @override
  void initState() {
    super.initState();
    _playPauseFocusNode.addListener(_onFocusChange);
    _skipBackFocusNode.addListener(_onFocusChange);
    _skipForwardFocusNode.addListener(_onFocusChange);
    _speedFocusNode.addListener(_onFocusChange);
    _backFocusNode.addListener(_onFocusChange);
    _nextEpisodeFocusNode.addListener(_onFocusChange);
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
    _playPauseFocusNode.removeListener(_onFocusChange);
    _skipBackFocusNode.removeListener(_onFocusChange);
    _skipForwardFocusNode.removeListener(_onFocusChange);
    _speedFocusNode.removeListener(_onFocusChange);
    _backFocusNode.removeListener(_onFocusChange);
    _nextEpisodeFocusNode.removeListener(_onFocusChange);
    _playPauseFocusNode.dispose();
    _skipBackFocusNode.dispose();
    _skipForwardFocusNode.dispose();
    _speedFocusNode.dispose();
    _backFocusNode.dispose();
    _nextEpisodeFocusNode.dispose();
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

  void _handleNextEpisode() async {
    setState(() {
      _currentEpisode++;
    });

    if (_currentEpisode >= _episodes.length) {
      _currentEpisode = 0;
    }

    _talker.info(
        'Loading video: ${_episodes[_currentEpisode].title} ${_episodes[_currentEpisode].url}');

    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(_episodes[_currentEpisode].url)
    );

    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();
    _resetControlsTimer();
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
      setState(() {
        _currentEpisode = 0;
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

      _talker.info('Loading video: ${videos[_currentEpisode].url}');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_episodes[_currentEpisode].url),
      );

      await _videoPlayerController!.initialize();
      await _videoPlayerController!.play();
      _resetControlsTimer();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading video: $e';
      });
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
          if (event is KeyDownEvent) {
            _resetControlsTimer();

            // check if none of the focus nodes are focused
            if (!_playPauseFocusNode.hasFocus &&
                !_skipBackFocusNode.hasFocus &&
                !_skipForwardFocusNode.hasFocus &&
                !_speedFocusNode.hasFocus &&
                !_backFocusNode.hasFocus &&
                !_nextEpisodeFocusNode.hasFocus) {
              _playPauseFocusNode.requestFocus();
              setState(() {});
            }
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
                                  // TODO: Implement next episode functionality
                                  _handleNextEpisode();
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
                                  _handleNextEpisode();
                                }, // Disabled for now
                              ),
                            ),
                          ),
                        ),

                        // Progress Bar
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: VideoProgressIndicator(
                            _videoPlayerController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white12,
                            ),
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
