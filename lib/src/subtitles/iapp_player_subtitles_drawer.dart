import 'dart:async';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// 字幕绘制组件，管理字幕显示与样式
class IAppPlayerSubtitlesDrawer extends StatefulWidget {
  final List<IAppPlayerSubtitle> subtitles;
  final IAppPlayerController iappPlayerController;
  final IAppPlayerSubtitlesConfiguration? iappPlayerSubtitlesConfiguration;

  const IAppPlayerSubtitlesDrawer({
    Key? key,
    required this.subtitles,
    required this.iappPlayerController,
    this.iappPlayerSubtitlesConfiguration,
  }) : super(key: key);

  @override
  _IAppPlayerSubtitlesDrawerState createState() => _IAppPlayerSubtitlesDrawerState();
}

/// 字幕绘制状态管理
class _IAppPlayerSubtitlesDrawerState extends State<IAppPlayerSubtitlesDrawer> {
  TextStyle? _innerTextStyle;
  TextStyle? _outerTextStyle;
  VideoPlayerValue? _latestValue;
  IAppPlayerSubtitlesConfiguration? _configuration;
  bool _isListenerAdded = false;
  int _lastSubtitleIndex = -1;
  bool _subtitlesSorted = false;
  IAppPlayerSubtitle? _currentSubtitle;
  Duration? _lastPosition;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
    _tryAddListener();
    _initializeTextStyles();
    _checkSubtitlesSorted();
  }

  /// 检查字幕是否按时间排序
  void _checkSubtitlesSorted() {
    final subtitles = widget.iappPlayerController.subtitlesLines;
    _subtitlesSorted = true;

    for (int i = 1; i < subtitles.length; i++) {
      final prev = subtitles[i - 1];
      final curr = subtitles[i];

      if (prev.start != null && curr.start != null && prev.start!.compareTo(curr.start!) > 0) {
        _subtitlesSorted = false;
        break;
      }
    }
  }

  /// 初始化字幕配置
  void _initializeConfiguration() {
    _configuration = widget.iappPlayerSubtitlesConfiguration ?? setupDefaultConfiguration();
  }

  /// 初始化文本样式
  void _initializeTextStyles() {
    if (_configuration == null) return;

    List<Shadow>? shadows = _configuration!.textShadows;
    if (shadows == null && _configuration!.outlineEnabled) {
      shadows = IAppPlayerSubtitlesConfiguration.defaultShadows;
    }

    _innerTextStyle = TextStyle(
        fontFamily: _configuration!.fontFamily,
        color: _configuration!.fontColor,
        fontSize: _configuration!.fontSize,
        fontWeight: _configuration!.fontWeight,
        decoration: _configuration!.textDecoration,
        height: _configuration!.height,
        letterSpacing: _configuration!.letterSpacing,
        shadows: shadows);

    if (_configuration!.outlineEnabled && _configuration!.textShadows == null) {
      _outerTextStyle = TextStyle(
          fontSize: _configuration!.fontSize,
          fontFamily: _configuration!.fontFamily,
          height: _configuration!.height,
          letterSpacing: _configuration!.letterSpacing,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _configuration!.outlineSize
            ..color = _configuration!.outlineColor);
    } else {
      _outerTextStyle = null;
    }
  }

  /// 添加播放器监听器
  void _tryAddListener() {
    final videoPlayerController = widget.iappPlayerController.videoPlayerController;
    if (videoPlayerController != null && !_isListenerAdded) {
      videoPlayerController.addListener(_updateState);
      _isListenerAdded = true;
      _updateState();
    }
  }

  /// 移除播放器监听器
  void _tryRemoveListener() {
    final videoPlayerController = widget.iappPlayerController.videoPlayerController;
    if (videoPlayerController != null && _isListenerAdded) {
      videoPlayerController.removeListener(_updateState);
      _isListenerAdded = false;
    }
  }

  @override
  void didUpdateWidget(IAppPlayerSubtitlesDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.iappPlayerController != widget.iappPlayerController) {
      _tryRemoveListener();
      _tryAddListener();
      _checkSubtitlesSorted();
      _currentSubtitle = null;
      _lastPosition = null;
      _lastSubtitleIndex = -1;
    }

    if (oldWidget.iappPlayerSubtitlesConfiguration != widget.iappPlayerSubtitlesConfiguration) {
      _initializeConfiguration();
      _initializeTextStyles();
    }
  }

  @override
  void dispose() {
    _tryRemoveListener();
    super.dispose();
  }

  /// 更新播放器状态
  void _updateState() {
    if (!mounted) return;

    final videoPlayerController = widget.iappPlayerController.videoPlayerController;
    if (videoPlayerController != null) {
      final newValue = videoPlayerController.value;
      final newPosition = newValue.position;

      if (_lastPosition != null && newPosition != null && (newPosition - _lastPosition!).abs() < const Duration(milliseconds: 50)) {
        return;
      }

      bool needUpdate = false;
      if (_currentSubtitle != null && newPosition != null) {
        if (_currentSubtitle!.start != null && _currentSubtitle!.end != null &&
            _currentSubtitle!.start! <= newPosition && _currentSubtitle!.end! >= newPosition) {
          return;
        }
        needUpdate = true;
      } else if (_currentSubtitle == null && newPosition != null) {
        needUpdate = true;
      }

      if (_latestValue != newValue || needUpdate) {
        setState(() {
          _latestValue = newValue;
          _lastPosition = newPosition;
          _currentSubtitle = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isListenerAdded) {
      _tryAddListener();
    }

    if (widget.iappPlayerController.videoPlayerController == null || _configuration == null || _innerTextStyle == null) {
      return const SizedBox.shrink();
    }

    if (widget.iappPlayerController.iappPlayerControlsConfiguration.enableSubtitles == false) {
      return const SizedBox.shrink();
    }

    if (_currentSubtitle == null) {
      _currentSubtitle = _getSubtitleAtCurrentPosition();
    }

    final IAppPlayerSubtitle? subtitle = _currentSubtitle;
    widget.iappPlayerController.renderedSubtitle = subtitle;

    final List<String> subtitles = subtitle?.texts ?? [];
    if (subtitles.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> textWidgets = subtitles.map((text) => _buildSubtitleTextWidget(text)).toList();

    return Padding(
      padding: EdgeInsets.only(
          left: _configuration?.leftPadding ?? 0,
          right: _configuration?.rightPadding ?? 0,
          bottom: _configuration?.bottomPadding ?? 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: textWidgets,
      ),
    );
  }

  /// 获取当前播放位置的字幕
  IAppPlayerSubtitle? _getSubtitleAtCurrentPosition() {
    if (_latestValue == null || _latestValue!.position == null) {
      return null;
    }

    final Duration position = _latestValue!.position;
    final subtitles = widget.iappPlayerController.subtitlesLines;

    if (subtitles.isEmpty) {
      return null;
    }

    return _subtitlesSorted ? _getSubtitleOptimized(position, subtitles) : _getSubtitleLinear(position, subtitles);
  }

  /// 查找当前字幕（已排序）
  IAppPlayerSubtitle? _getSubtitleOptimized(Duration position, List<IAppPlayerSubtitle> subtitles) {
    try {
      if (_lastSubtitleIndex >= 0 && _lastSubtitleIndex < subtitles.length) {
        final lastSubtitle = subtitles[_lastSubtitleIndex];
        if (lastSubtitle.start != null && lastSubtitle.end != null &&
            lastSubtitle.start! <= position && lastSubtitle.end! >= position) {
          return lastSubtitle;
        }
      }

      int left = 0;
      int right = subtitles.length - 1;

      while (left <= right) {
        int mid = left + ((right - left) >> 1);
        final subtitle = subtitles[mid];

        if (subtitle.start == null || subtitle.end == null) {
          left = mid + 1;
          continue;
        }

        if (subtitle.start! <= position && subtitle.end! >= position) {
          _lastSubtitleIndex = mid;
          return subtitle;
        } else if (subtitle.end! < position) {
          left = mid + 1;
        } else {
          right = mid - 1;
        }
      }

      _lastSubtitleIndex = -1;
    } catch (e) {
      _lastSubtitleIndex = -1;
    }

    return null;
  }

  /// 线性查找当前字幕
  IAppPlayerSubtitle? _getSubtitleLinear(Duration position, List<IAppPlayerSubtitle> subtitles) {
    try {
      for (int i = 0; i < subtitles.length; i++) {
        final subtitle = subtitles[i];
        if (subtitle.start != null && subtitle.end != null &&
            subtitle.start! <= position && subtitle.end! >= position) {
          _lastSubtitleIndex = i;
          return subtitle;
        }
      }
      _lastSubtitleIndex = -1;
    } catch (e) {
      _lastSubtitleIndex = -1;
    }

    return null;
  }

  /// 构建字幕文本组件
  Widget _buildSubtitleTextWidget(String subtitleText) {
    if (_configuration == null) {
      return const SizedBox.shrink();
    }

    return Row(children: [
      Expanded(
        child: Align(
          alignment: _configuration?.alignment ?? Alignment.bottomCenter,
          child: _getTextWithStroke(subtitleText),
        ),
      ),
    ]);
  }

  /// 构建带描边的字幕文本
  Widget _getTextWithStroke(String subtitleText) {
    if (_configuration == null || _innerTextStyle == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: _configuration?.backgroundColor ?? Colors.transparent,
      child: _shouldUseOldOutlineStyle()
          ? Stack(
              children: [
                if (_outerTextStyle != null) _buildHtmlWidget(subtitleText, _outerTextStyle!),
                _buildHtmlWidget(subtitleText, _innerTextStyle!)
              ],
            )
          : _buildHtmlWidget(subtitleText, _innerTextStyle!),
    );
  }

  /// 判断是否使用描边样式
  bool _shouldUseOldOutlineStyle() {
    return _configuration != null &&
        _configuration!.outlineEnabled &&
        _configuration!.textShadows == null &&
        _outerTextStyle != null;
  }

  /// 构建HTML字幕组件
  Widget _buildHtmlWidget(String text, TextStyle textStyle) {
    try {
      return HtmlWidget(text, textStyle: textStyle);
    } catch (e) {
      return Text(text, style: textStyle);
    }
  }

  /// 设置默认字幕配置
  IAppPlayerSubtitlesConfiguration setupDefaultConfiguration() {
    return const IAppPlayerSubtitlesConfiguration();
  }
}
