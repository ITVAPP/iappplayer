import 'package:flutter/material.dart';
import 'main.dart'; // 导入主文件以使用共享组件

// 音乐播放列表示例
class MusicPlaylistExample extends StatefulWidget {
  const MusicPlaylistExample({Key? key}) : super(key: key);

  @override
  State<MusicPlaylistExample> createState() => _MusicPlaylistExampleState();
}

class _MusicPlaylistExampleState extends State<MusicPlaylistExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  IAppPlayerController? _controller;
  IAppPlayerPlaylistController? _playlistController;
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _shuffleMode = false;
  final _assetCache = AssetCache();

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 使用缓存批量读取LRC歌词文件
    final lyrics1 = await _assetCache.loadString('assets/lyrics/song1.lrc');
    final lyrics2 = await _assetCache.loadString('assets/lyrics/song2.lrc');
    final lyrics3 = await _assetCache.loadString('assets/lyrics/song3.lrc');
    
    // 使用正确的本地资源路径 - 播放器现在支持asset路径
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'assets/music/song1.mp3',
        'assets/music/song2.mp3',
        'assets/music/song3.mp3',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'],
      imageUrls: [
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
      ],
      subtitleContents: [lyrics1, lyrics2, lyrics3],
      audioOnly: true,
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
          final index = event.parameters?['index'] as int?;
          if (index != null) {
            setState(() {
              _currentIndex = index;
            });
          }
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
          final shuffleMode = event.parameters?['shuffleMode'] as bool?;
          if (shuffleMode != null) {
            setState(() {
              _shuffleMode = shuffleMode;
            });
          }
        }
      },
      shuffleMode: false,
      loopVideos: true,
      autoDetectFullscreenDeviceOrientation: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    if (mounted) {
      setState(() {
        _controller = result.activeController;
        _playlistController = result.playlistController;
      });
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  Future<void> _releasePlayer() async {
    try {
      // 移除全局缓存清理
      _playlistController?.dispose();
      _controller = null;
      _playlistController = null;
    } catch (e) {
      print('Player cleanup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSongs = _playlistController?.dataSourceList.length ?? 0;
    final titles = ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('音乐列表'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // 减少顶部间距
              // 音乐封面区域
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfa709a).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                      ),
                      child: _controller != null
                          ? IAppPlayer(controller: _controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15), // 减少间距
              // 当前歌曲信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      _currentIndex < titles.length ? titles[_currentIndex] : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / $totalSongs • ${_shuffleMode ? "随机播放" : "顺序播放"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 控制按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放控制按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一首
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playPrevious()
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放/暂停
                        _buildCircleButton(
                          onPressed: _controller != null && !_isLoading
                              ? () {
                                  if (_controller!.isPlaying() ?? false) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                }
                              : null,
                          icon: (_controller?.isPlaying() ?? false)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          isPrimary: true,
                        ),
                        // 下一首
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playNext()
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 模式切换按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: _shuffleMode ? '切换到顺序播放' : '切换到随机播放',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 80 : 60,
      height: isPrimary ? 80 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPrimary ? LinearGradient(
          colors: [
            const Color(0xFFfa709a),
            const Color(0xFFfee140),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: const Color(0xFFfa709a).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 28,
            ),
          ),
        ),
      ),
    );
  }
}
