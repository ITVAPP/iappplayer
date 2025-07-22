import 'dart:async';
import 'dart:math';
import 'package:iapp_player/iapp_player.dart';

/// 播放列表控制器，管理播放器播放列表
class IAppPlayerPlaylistController {
  /// 播放列表数据源
  final List<IAppPlayerDataSource> _iappPlayerDataSourceList;
  /// 播放器通用配置
  final IAppPlayerConfiguration iappPlayerConfiguration;
  /// 播放列表配置
  final IAppPlayerPlaylistConfiguration iappPlayerPlaylistConfiguration;
  /// 播放器控制器实例
  IAppPlayerController? _iappPlayerController;
  /// 当前播放数据源索引
  int _currentDataSourceIndex = 0;
  /// 下一视频切换监听订阅
  StreamSubscription? _nextVideoTimeStreamSubscription;
  /// 是否正在切换下一视频
  bool _changingToNextVideo = false;
  /// 随机数生成器
  final Random _random = Random();
  /// 随机播放模式状态
  bool _shuffleMode = false;
  
  /// 获取随机播放模式状态
  bool get shuffleMode => _shuffleMode;
  
  /// 获取数据源列表（只读）
  List<IAppPlayerDataSource> get dataSourceList => 
      List.unmodifiable(_iappPlayerDataSourceList);
  
  /// 是否有上一个视频
  bool get hasPrevious {
    if (_dataSourceLength <= 1) {
      return false;
    }
    return _currentDataSourceIndex > 0 || iappPlayerPlaylistConfiguration.loopVideos;
  }
  
  /// 是否有下一个视频
  bool get hasNext {
    if (_dataSourceLength <= 1) {
      return false;
    }
    return _currentDataSourceIndex < _dataSourceLength - 1 || iappPlayerPlaylistConfiguration.loopVideos;
  }
  
  /// 构造函数，初始化播放列表数据源及配置
  IAppPlayerPlaylistController(
    this._iappPlayerDataSourceList, {
    this.iappPlayerConfiguration = const IAppPlayerConfiguration(),
    this.iappPlayerPlaylistConfiguration =
        const IAppPlayerPlaylistConfiguration(),
  }) : assert(_iappPlayerDataSourceList.isNotEmpty,
            "播放列表数据源不能为空") {
    // 从配置初始化随机模式
    _shuffleMode = iappPlayerPlaylistConfiguration.shuffleMode;
    _setup();
  }
  
  /// 初始化控制器及监听器
  void _setup() {
    _iappPlayerController ??= IAppPlayerController(
      iappPlayerConfiguration,
      iappPlayerPlaylistConfiguration: iappPlayerPlaylistConfiguration,
    );
    // 设置播放列表控制器引用
    _iappPlayerController!.playlistController = this;
    
    var initialStartIndex = iappPlayerPlaylistConfiguration.initialStartIndex;
    if (initialStartIndex >= _iappPlayerDataSourceList.length) {
      initialStartIndex = 0;
    }
    _currentDataSourceIndex = initialStartIndex;
    setupDataSource(_currentDataSourceIndex);
    _iappPlayerController!.addEventsListener(_handleEvent);
    _nextVideoTimeStreamSubscription =
        _iappPlayerController!.nextVideoTimeStream.listen((time) {
      if (time != null && time == 0) {
        _onVideoChange();
      }
    });
  }
  
  /// 设置新数据源列表，暂停当前视频并初始化新列表
  void setupDataSourceList(List<IAppPlayerDataSource> dataSourceList) {
    assert(dataSourceList.isNotEmpty, "播放列表数据源不能为空");
    _iappPlayerController?.pause();
    _iappPlayerDataSourceList.clear();
    _iappPlayerDataSourceList.addAll(dataSourceList);
    _setup();
  }
  
  /// 处理播放器发出的视频切换信号，设置新数据源
  void _onVideoChange() {
    if (_changingToNextVideo) {
      return;
    }
    final int nextDataSourceId = _getNextDataSourceIndex();
    if (nextDataSourceId == -1) {
      return;
    }
    if (_iappPlayerController!.isFullScreen) {
      _iappPlayerController!.exitFullScreen();
    }

    _changingToNextVideo = true;
    setupDataSource(nextDataSourceId);
    _changingToNextVideo = false;
  
    // 发送带有索引的事件
    _iappPlayerController!.postEvent(
      IAppPlayerEvent(
        IAppPlayerEventType.changedPlaylistItem,
        parameters: {'index': nextDataSourceId},
      ),
    );
  }
  
  /// 处理播放器事件，控制下一视频计时器启动
  void _handleEvent(IAppPlayerEvent iappPlayerEvent) {
    if (iappPlayerEvent.iappPlayerEventType ==
        IAppPlayerEventType.finished) {
      if (_getNextDataSourceIndex() != -1) {
        _iappPlayerController!.startNextVideoTimer();
      }
    }
    
    // 处理切换随机模式事件
    if (iappPlayerEvent.iappPlayerEventType ==
        IAppPlayerEventType.togglePlaylistShuffle) {
      toggleShuffleMode();
    }
  }
  
  /// 根据索引设置数据源，索引需合法
  void setupDataSource(int index) {
    assert(
        index >= 0 && index < _iappPlayerDataSourceList.length,
        "索引需大于等于0且小于数据源列表长度");
    if (index < _dataSourceLength) {
      _currentDataSourceIndex = index;
      _iappPlayerController!.setupDataSource(_iappPlayerDataSourceList[index]);
    }
  }
  
  /// 获取下一数据源索引，支持循环播放和随机播放
  int _getNextDataSourceIndex() {
    // 如果只有一个数据源
    if (_dataSourceLength <= 1) {
      return iappPlayerPlaylistConfiguration.loopVideos ? 0 : -1;
    }
    
    // 随机播放模式 - 使用内部状态而不是配置
    if (_shuffleMode) {
      // 如果只有两个数据源，直接切换到另一个
      if (_dataSourceLength == 2) {
        return _currentDataSourceIndex == 0 ? 1 : 0;
      }
      
      // 多个数据源时，随机选择一个不同的
      int nextIndex;
      do {
        nextIndex = _random.nextInt(_dataSourceLength);
      } while (nextIndex == _currentDataSourceIndex);
      
      return nextIndex;
    }
    
    // 顺序播放模式（原有逻辑）
    final currentIndex = _currentDataSourceIndex;
    if (currentIndex + 1 < _dataSourceLength) {
      return currentIndex + 1;
    } else {
      if (iappPlayerPlaylistConfiguration.loopVideos) {
        return 0;
      } else {
        return -1;
      }
    }
  }
  
  /// 获取上一个数据源索引
  int _getPreviousDataSourceIndex() {
    // 如果只有一个数据源
    if (_dataSourceLength <= 1) {
      return iappPlayerPlaylistConfiguration.loopVideos ? 0 : -1;
    }
    
    // 随机播放模式 - 在随机模式下，"上一曲"功能返回到前一个索引
    // 这样用户可以在列表中前后导航
    if (_shuffleMode) {
      final currentIndex = _currentDataSourceIndex;
      if (currentIndex > 0) {
        return currentIndex - 1;
      } else {
        if (iappPlayerPlaylistConfiguration.loopVideos) {
          return _dataSourceLength - 1;
        } else {
          return -1;
        }
      }
    }
    
    // 顺序播放模式
    final currentIndex = _currentDataSourceIndex;
    if (currentIndex > 0) {
      return currentIndex - 1;
    } else {
      if (iappPlayerPlaylistConfiguration.loopVideos) {
        return _dataSourceLength - 1;
      } else {
        return -1;
      }
    }
  }
  
  /// 播放上一个数据源
  void playPrevious() {
    if (_changingToNextVideo) {
      return;
    }
    final int previousDataSourceId = _getPreviousDataSourceIndex();
    if (previousDataSourceId == -1) {
      return;
    }
    if (_iappPlayerController!.isFullScreen) {
      _iappPlayerController!.exitFullScreen();
    }
  
    _changingToNextVideo = true;
    setupDataSource(previousDataSourceId);
    _changingToNextVideo = false;
  }

  /// 播放下一个数据源
  void playNext() {
    if (_changingToNextVideo) {
      return;
    }
    final int nextDataSourceId = _getNextDataSourceIndex();
    if (nextDataSourceId == -1) {
      return;
    }
    if (_iappPlayerController!.isFullScreen) {
      _iappPlayerController!.exitFullScreen();
    }
  
    _changingToNextVideo = true;
    setupDataSource(nextDataSourceId);
    _changingToNextVideo = false;
  }
  
  /// 切换随机播放模式
  void toggleShuffleMode() {
    _shuffleMode = !_shuffleMode;
    // 发送事件通知UI更新，携带当前状态
    _iappPlayerController?.postEvent(
      IAppPlayerEvent(
        IAppPlayerEventType.changedPlaylistShuffle,
        parameters: {'shuffleMode': _shuffleMode},
      ),
    );
  }
  
  /// 获取当前播放数据源索引
  int get currentDataSourceIndex => _currentDataSourceIndex;
  
  /// 获取数据源列表长度
  int get _dataSourceLength => _iappPlayerDataSourceList.length;
  
  /// 获取播放器控制器实例
  IAppPlayerController? get iappPlayerController => _iappPlayerController;
  
  /// 清理控制器资源
  Future<void> dispose() async {
    // 1. 取消订阅
    await _nextVideoTimeStreamSubscription?.cancel();
    _nextVideoTimeStreamSubscription = null;
    
    // 2. 释放内部播放器控制器
    if (_iappPlayerController != null) {
      // 先移除事件监听器
      _iappPlayerController!.removeEventsListener(_handleEvent);
      
      // 释放播放器控制器
      await _iappPlayerController!.dispose(forceDispose: true);
      _iappPlayerController = null;
    }
    
    // 3. 清理数据
    _iappPlayerDataSourceList.clear();
    
    // 4. 重置状态
    _currentDataSourceIndex = 0;
    _changingToNextVideo = false;
    _shuffleMode = false;
  }
}
