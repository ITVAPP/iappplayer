import 'dart:async';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/video_player/video_player_platform_interface.dart';
import 'package:flutter/material.dart';

/// 视频进度条
class IAppPlayerProgressBar extends StatefulWidget {
  IAppPlayerProgressBar(
    this.controller,
    this.iappPlayerController, {
    IAppPlayerProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    this.onTapDown,
    Key? key,
  })  : colors = colors ?? IAppPlayerProgressColors(),
        super(key: key);

  /// 视频播放控制器
  final VideoPlayerController? controller;
  /// 播放器控制器
  final IAppPlayerController? iappPlayerController;
  /// 进度条颜色配置
  final IAppPlayerProgressColors colors;
  /// 拖拽开始回调
  final Function()? onDragStart;
  /// 拖拽结束回调
  final Function()? onDragEnd;
  /// 拖拽更新回调
  final Function()? onDragUpdate;
  /// 点击回调
  final Function()? onTapDown;

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState
    extends State<IAppPlayerProgressBar> {
  /// 控制器监听器
  late VoidCallback listener;
  /// 拖拽前是否在播放
  bool _controllerWasPlaying = false;
  
  /// 最新拖拽偏移量
  Offset? _latestDraggableOffset;
  
  /// 容器宽度缓存
  double? _containerWidth;
  
  /// 是否正在拖拽
  bool _isDragging = false;
  
  /// 是否悬停（仅Web/桌面端有效）
  bool _isHovering = false;

  /// 获取视频播放控制器
  VideoPlayerController? get controller => widget.controller;

  /// 获取播放器控制器
  IAppPlayerController? get iappPlayerController =>
      widget.iappPlayerController;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
    controller!.addListener(listener);
  }

  @override
  void deactivate() {
    controller!.removeListener(listener);
    super.deactivate();
  }

  /// 寻址到相对位置
  void _seekToRelativePosition(Offset globalPosition, double containerWidth) {
    controller!.seekTo(_calcRelativePosition(
      controller!.value.duration!,
      globalPosition,
      containerWidth,
    ));
  }

  /// 计算相对位置
  Duration _calcRelativePosition(
    Duration videoDuration,
    Offset globalPosition,
    double containerWidth,
  ) {
    final box = context.findRenderObject()! as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = (tapPos.dx / containerWidth).clamp(0, 1);
    final Duration position = videoDuration * relative;
    return position;
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否是直播流
    final bool isLive = iappPlayerController?.isLiveStream() ?? false;
    // 直播流时禁用拖拽，但保留进度条显示
    final bool enableProgressBarDrag = !isLive && iappPlayerController!
        .iappPlayerConfiguration.controlsConfiguration.enableProgressBarDrag;

    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;
        
        // 进度条容器高度
        final containerHeight = 12.0;
            
        final progressBar = MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: enableProgressBarDrag ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Container(
            height: containerHeight,
            width: constraints.maxWidth,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(constraints.maxWidth, containerHeight),
              painter: _ProgressBarPainter(
                value: controller!.value,
                colors: widget.colors,
                draggableValue: _latestDraggableOffset != null && _containerWidth != null
                    ? _calcRelativePosition(
                        controller!.value.duration!,
                        _latestDraggableOffset!,
                        _containerWidth!,
                      )
                    : null,
                containerHeight: containerHeight,
                isDragging: _isDragging,
                isHovering: _isHovering,
                isLive: isLive,
              ),
            ),
          ),
        );

        // 直播流时返回禁用交互的进度条
        if (!enableProgressBarDrag) {
          return progressBar;
        }

        return GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            if (!controller!.value.initialized) {
              return;
            }

            setState(() => _isDragging = true);
            _controllerWasPlaying = controller!.value.isPlaying;
            if (_controllerWasPlaying) {
              controller!.pause();
            }

            if (widget.onDragStart != null) {
              widget.onDragStart!();
            }
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (!controller!.value.initialized || _containerWidth == null) {
              return;
            }

            _latestDraggableOffset = details.globalPosition;
            listener();

            if (widget.onDragUpdate != null) {
              widget.onDragUpdate!();
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            setState(() => _isDragging = false);
            
            if (_controllerWasPlaying) {
              controller!.play();
            }

            if (_latestDraggableOffset != null && _containerWidth != null) {
              _seekToRelativePosition(_latestDraggableOffset!, _containerWidth!);
              _latestDraggableOffset = null;
            }

            if (widget.onDragEnd != null) {
              widget.onDragEnd!();
            }
          },
          onTapDown: (TapDownDetails details) {
            if (!controller!.value.initialized || _containerWidth == null) {
              return;
            }
            _seekToRelativePosition(details.globalPosition, _containerWidth!);
            if (widget.onTapDown != null) {
              widget.onTapDown!();
            }
          },
          child: progressBar,
        );
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.value,
    required this.colors,
    this.draggableValue,
    required this.containerHeight,
    required this.isDragging,
    required this.isHovering,
    required this.isLive,
  });

  /// 当前播放值
  final VideoPlayerValue value;
  /// 进度条颜色
  final IAppPlayerProgressColors colors;
  /// 拖拽值
  final Duration? draggableValue;
  /// 容器高度
  final double containerHeight;
  /// 是否正在拖拽
  final bool isDragging;
  /// 是否悬停
  final bool isHovering;
  /// 是否直播
  final bool isLive;

  @override
  bool shouldRepaint(_ProgressBarPainter oldPainter) {
    return oldPainter.value != value ||
           oldPainter.draggableValue != draggableValue ||
           oldPainter.isDragging != isDragging ||
           oldPainter.isHovering != isHovering;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // YouTube风格：动态进度条高度
    final baseHeight = (isDragging || isHovering) ? 6.0 : 4.0;
    final height = isLive ? 4.0 : baseHeight; // 直播时固定高度
    final baseOffset = size.height / 2 - height / 2;

    // 绘制背景
    final backgroundPaint = isLive 
        ? (Paint()..color = Colors.white.withOpacity(0.3)) 
        : colors.backgroundPaint;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + height),
        ),
        Radius.circular(height / 2),
      ),
      backgroundPaint,
    );
    
    // 直播流显示红色进度条
    if (isLive) {
      // 绘制动态的直播进度效果
      final livePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(0.0, baseOffset),
            Offset(size.width, baseOffset + height),
          ),
          Radius.circular(height / 2),
        ),
        livePaint,
      );
      return;
    }
    
    if (!value.initialized || value.duration == null) {
      return;
    }
    
    // 使用拖拽值或当前播放位置
    final double playedPartPercent = (draggableValue != null
            ? draggableValue!.inMilliseconds
            : value.position.inMilliseconds) /
        value.duration!.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    
    // 绘制缓冲区域
    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration!) * size.width;
      final double end = range.endFraction(value.duration!) * size.width;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + height),
          ),
          Radius.circular(height / 2),
        ),
        colors.bufferedPaint,
      );
    }
    
    // 绘制已播放区域
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + height),
        ),
        Radius.circular(height / 2),
      ),
      colors.playedPaint,
    );
    
    // YouTube风格手柄：悬停或拖拽时显示
    if ((isDragging || isHovering)) {
      final handleRadius = 8.0;
      
      // 手柄阴影
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(playedPart, baseOffset + height / 2),
        handleRadius + 2,
        shadowPaint,
      );
      
      // 手柄本体
      canvas.drawCircle(
        Offset(playedPart, baseOffset + height / 2),
        handleRadius,
        colors.handlePaint,
      );
    }
  }
}
