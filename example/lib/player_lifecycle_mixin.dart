import 'package:flutter/material.dart';
import 'package:iapp_player/iapp_player.dart';

// 播放器生命周期管理Mixin - 统一处理初始化、释放和状态管理
mixin PlayerLifecycleMixin<T extends StatefulWidget> on State<T> {
  IAppPlayerController? _controller;
  IAppPlayerPlaylistController? _playlistController;
  bool _isLoading = true;
  bool _isPlaying = false;
  String? _errorMessage;
  
  // 子类可以访问的getter
  IAppPlayerController? get controller => _controller;
  IAppPlayerPlaylistController? get playlistController => _playlistController;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get errorMessage => _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayerSafely();
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  // 安全的初始化播放器
  Future<void> _initializePlayerSafely() async {
    try {
      await initializePlayer();
    } catch (e) {
      print('播放器初始化失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '播放器初始化失败，请检查网络连接';
        });
      }
    }
  }

  // 子类必须实现的初始化方法
  Future<void> initializePlayer();

  // 统一的播放器配置创建方法
  Future<void> createPlayer(IAppPlayerConfig config) async {
    final result = await config.create();
    
    if (mounted) {
      setState(() {
        _controller = result.activeController;
        _playlistController = result.playlistController;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  // 统一的事件处理
  void handlePlayerEvent(IAppPlayerEvent event) {
    switch (event.iappPlayerEventType) {
      case IAppPlayerEventType.initialized:
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
          });
        }
        onPlayerInitialized();
        break;
      
      case IAppPlayerEventType.play:
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
        break;
      
      case IAppPlayerEventType.pause:
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
        break;
      
      case IAppPlayerEventType.error:
        final error = event.parameters?['error'] as String?;
        if (mounted) {
          setState(() {
            _errorMessage = error ?? '播放出错';
            _isLoading = false;
          });
        }
        break;
      
      default:
        // 让子类处理其他事件
        handleCustomEvent(event);
    }
  }

  // 子类可以重写的钩子方法
  void onPlayerInitialized() {}
  void handleCustomEvent(IAppPlayerEvent event) {}

  // 播放/暂停切换
  void togglePlayPause() {
    if (_controller == null || _isLoading) return;
    
    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  // 全屏切换
  void toggleFullscreen() {
    if (_controller == null || _isLoading) return;
    
    if (_controller!.isFullScreen) {
      _controller!.exitFullScreen();
    } else {
      _controller!.enterFullScreen();
    }
  }

  // 重试播放
  Future<void> retryPlay() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    await _releasePlayer();
    await _initializePlayerSafely();
  }

  // 释放播放器资源
  Future<void> _releasePlayer() async {
    try {
      if (_controller != null) {
        // 停止播放
        if (_controller!.isPlaying() ?? false) {
          await _controller!.pause();
        }
        
        // 释放控制器
        _controller!.dispose();
        _controller = null;
      }
      
      // 释放播放列表控制器
      _playlistController?.dispose();
      _playlistController = null;
    } catch (e) {
      print('播放器释放失败: $e');
    }
  }

  // 更新加载状态
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  // 更新错误信息
  void setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }
}

// 带播放列表功能的生命周期管理
mixin PlaylistLifecycleMixin<T extends StatefulWidget> on PlayerLifecycleMixin<T> {
  int _currentIndex = 0;
  bool _shuffleMode = false;

  int get currentIndex => _currentIndex;
  bool get shuffleMode => _shuffleMode;

  @override
  void handleCustomEvent(IAppPlayerEvent event) {
    switch (event.iappPlayerEventType) {
      case IAppPlayerEventType.changedPlaylistItem:
        final index = event.parameters?['index'] as int?;
        if (index != null && mounted) {
          setState(() {
            _currentIndex = index;
          });
          onPlaylistItemChanged(index);
        }
        break;
      
      case IAppPlayerEventType.changedPlaylistShuffle:
        final shuffle = event.parameters?['shuffleMode'] as bool?;
        if (shuffle != null && mounted) {
          setState(() {
            _shuffleMode = shuffle;
          });
        }
        break;
      
      default:
        super.handleCustomEvent(event);
    }
  }

  // 子类可以重写的钩子
  void onPlaylistItemChanged(int index) {}

  // 播放上一个
  void playPrevious() {
    if (playlistController == null || isLoading) return;
    playlistController!.playPrevious();
    _updateIndexAfterDelay();
  }

  // 播放下一个
  void playNext() {
    if (playlistController == null || isLoading) return;
    playlistController!.playNext();
    _updateIndexAfterDelay();
  }

  // 切换播放模式
  void toggleShuffleMode() {
    if (playlistController == null) return;
    playlistController!.toggleShuffleMode();
  }

  // 播放指定索引
  void playAtIndex(int index) {
    if (playlistController == null) return;
    playlistController!.setupDataSource(index);
    _updateIndexAfterDelay();
  }

  // 延迟更新索引（确保切换完成）
  void _updateIndexAfterDelay() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (playlistController != null && mounted) {
        final newIndex = playlistController!.currentDataSourceIndex;
        if (newIndex != _currentIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        }
      }
    });
  }
}