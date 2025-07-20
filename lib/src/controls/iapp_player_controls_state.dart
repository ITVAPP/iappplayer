import 'dart:io';
import 'dart:math';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/controls/iapp_player_clickable_widget.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 播放器控件状态基类
abstract class IAppPlayerControlsState<T extends StatefulWidget>
    extends State<T> {
  // 最小缓冲时间（毫秒），低于此值显示加载指示器
  static const int _bufferingInterval = 20000;

  // 获取播放器控制器
  IAppPlayerController? get iappPlayerController;

  // 获取播放器控件配置
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration;

  // 获取最新视频播放值
  VideoPlayerValue? get latestValue;

  // 控件是否隐藏
  bool controlsNotVisible = true;

  // 取消并重启定时器
  void cancelAndRestartTimer();

  // 判断视频是否播放结束
  bool isVideoFinished(VideoPlayerValue? videoPlayerValue) {
    return videoPlayerValue?.position != null &&
        videoPlayerValue?.duration != null &&
        videoPlayerValue!.position.inMilliseconds != 0 &&
        videoPlayerValue.duration!.inMilliseconds != 0 &&
        videoPlayerValue.position >= videoPlayerValue.duration!;
  }

  // 快退指定时间
  void skipBack() {
    if (latestValue != null) {
      cancelAndRestartTimer();
      final beginning = const Duration().inMilliseconds;
      final skip = (latestValue!.position -
              Duration(
                  milliseconds: iappPlayerControlsConfiguration
                      .backwardSkipTimeInMilliseconds))
          .inMilliseconds;
      iappPlayerController!
          .seekTo(Duration(milliseconds: max(skip, beginning)));
    }
  }

  // 快进指定时间
  void skipForward() {
    if (latestValue != null) {
      cancelAndRestartTimer();
      final end = latestValue!.duration!.inMilliseconds;
      final skip = (latestValue!.position +
              Duration(
                  milliseconds: iappPlayerControlsConfiguration
                      .forwardSkipTimeInMilliseconds))
          .inMilliseconds;
      iappPlayerController!.seekTo(Duration(milliseconds: min(skip, end)));
    }
  }

  // 显示更多选项模态框
  void onShowMoreClicked() {
    _showModalBottomSheet([_buildMoreOptionsList()]);
  }

  // 构建更多选项列表
  Widget _buildMoreOptionsList() {
    final translations = iappPlayerController!.translations;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            if (iappPlayerControlsConfiguration.enablePlaybackSpeed)
              _buildMenuItemRow(
                icon: iappPlayerControlsConfiguration.playbackSpeedIcon,
                text: translations.overflowMenuPlaybackSpeed,
                onTap: () {
                  Navigator.of(context).pop();
                  _showSpeedChooserWidget();
                },
              ),
            if (iappPlayerControlsConfiguration.enableSubtitles)
              _buildMenuItemRow(
                icon: iappPlayerControlsConfiguration.subtitlesIcon,
                text: translations.overflowMenuSubtitles,
                onTap: () {
                  Navigator.of(context).pop();
                  _showSubtitlesSelectionWidget();
                },
              ),
            if (iappPlayerControlsConfiguration.enableQualities)
              _buildMenuItemRow(
                icon: iappPlayerControlsConfiguration.qualitiesIcon,
                text: translations.overflowMenuQuality,
                onTap: () {
                  Navigator.of(context).pop();
                  _showQualitiesSelectionWidget();
                },
              ),
            if (iappPlayerControlsConfiguration.enableAudioTracks)
              _buildMenuItemRow(
                icon: iappPlayerControlsConfiguration.audioTracksIcon,
                text: translations.overflowMenuAudioTracks,
                onTap: () {
                  Navigator.of(context).pop();
                  _showAudioTracksSelectionWidget();
                },
              ),
            if (iappPlayerControlsConfiguration
                .overflowMenuCustomItems.isNotEmpty)
              ...iappPlayerControlsConfiguration.overflowMenuCustomItems.map(
                (customItem) => _buildMenuItemRow(
                  icon: customItem.icon,
                  text: customItem.title,
                  onTap: () {
                    Navigator.of(context).pop();
                    customItem.onClicked.call();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  // 构建通用菜单项行
  Widget _buildMenuItemRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return IAppPlayerClickableWidget(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(
              icon,
              color: iappPlayerControlsConfiguration.overflowMenuIconsColor,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: _getOverflowMenuElementTextStyle(false),
            ),
          ],
        ),
      ),
    );
  }

  // 构建通用选择行
  Widget _buildSelectionRow({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return IAppPlayerClickableWidget(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
              visible: isSelected,
              child: Icon(
                Icons.check_outlined,
                color: iappPlayerControlsConfiguration.overflowModalTextColor,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  // 显示播放速度选择器
  void _showSpeedChooserWidget() {
    _showModalBottomSheet([
      _buildSpeedRow(0.25),
      _buildSpeedRow(0.5),
      _buildSpeedRow(0.75),
      _buildSpeedRow(1.0),
      _buildSpeedRow(1.25),
      _buildSpeedRow(1.5),
      _buildSpeedRow(1.75),
      _buildSpeedRow(2.0),
    ]);
  }

  // 构建播放速度选择行
  Widget _buildSpeedRow(double value) {
    final bool isSelected =
        iappPlayerController!.videoPlayerController!.value.speed == value;

    return _buildSelectionRow(
      text: "$value x",
      isSelected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        iappPlayerController!.setSpeed(value);
      },
    );
  }

  // 判断视频是否处于加载状态
  bool isLoading(VideoPlayerValue? latestValue) {
    if (latestValue != null) {
      if (!latestValue.isPlaying && latestValue.duration == null) {
        return true;
      }

      final Duration position = latestValue.position;

      Duration? bufferedEndPosition;
      if (latestValue.buffered.isNotEmpty == true) {
        bufferedEndPosition = latestValue.buffered.last.end;
      }

      if (bufferedEndPosition != null) {
        final difference = bufferedEndPosition - position;

        if (latestValue.isPlaying &&
            latestValue.isBuffering &&
            difference.inMilliseconds < _bufferingInterval) {
          return true;
        }
      }
    }
    return false;
  }

  // 显示字幕选择器
  void _showSubtitlesSelectionWidget() {
    final subtitles =
        List.of(iappPlayerController!.iappPlayerSubtitlesSourceList);
    final noneSubtitlesElementExists = subtitles.firstWhereOrNull(
            (source) => source.type == IAppPlayerSubtitlesSourceType.none) !=
        null;
    if (!noneSubtitlesElementExists) {
      subtitles.add(IAppPlayerSubtitlesSource(
          type: IAppPlayerSubtitlesSourceType.none));
    }

    _showModalBottomSheet(
        subtitles.map((source) => _buildSubtitlesSourceRow(source)).toList());
  }

  // 构建字幕源选择行
  Widget _buildSubtitlesSourceRow(IAppPlayerSubtitlesSource subtitlesSource) {
    final selectedSourceType =
        iappPlayerController!.iappPlayerSubtitlesSource;
    final bool isSelected = (subtitlesSource == selectedSourceType) ||
        (subtitlesSource.type == IAppPlayerSubtitlesSourceType.none &&
            subtitlesSource.type == selectedSourceType!.type);

    return _buildSelectionRow(
      text: subtitlesSource.type == IAppPlayerSubtitlesSourceType.none
          ? iappPlayerController!.translations.generalNone
          : subtitlesSource.name ??
              iappPlayerController!.translations.generalDefault,
      isSelected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        iappPlayerController!.setupSubtitleSource(subtitlesSource);
      },
    );
  }

  // 显示质量选择器
  void _showQualitiesSelectionWidget() {
    final List<String> asmsTrackNames =
        iappPlayerController!.iappPlayerDataSource!.asmsTrackNames ?? [];
    final List<IAppPlayerAsmsTrack> asmsTracks =
        iappPlayerController!.iappPlayerAsmsTracks;
    final List<Widget> children = [];
    for (var index = 0; index < asmsTracks.length; index++) {
      final track = asmsTracks[index];

      String? preferredName;
      if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
        preferredName = iappPlayerController!.translations.qualityAuto;
      } else {
        preferredName =
            asmsTrackNames.length > index ? asmsTrackNames[index] : null;
      }
      children.add(_buildTrackRow(asmsTracks[index], preferredName));
    }

    final resolutions =
        iappPlayerController!.iappPlayerDataSource!.resolutions;
    resolutions?.forEach((key, value) {
      children.add(_buildResolutionSelectionRow(key, value));
    });

    if (children.isEmpty) {
      children.add(
        _buildTrackRow(IAppPlayerAsmsTrack.defaultTrack(),
            iappPlayerController!.translations.qualityAuto),
      );
    }

    _showModalBottomSheet(children);
  }

  // 构建轨道选择行
  Widget _buildTrackRow(IAppPlayerAsmsTrack track, String? preferredName) {
    final int width = track.width ?? 0;
    final int height = track.height ?? 0;
    final int bitrate = track.bitrate ?? 0;
    final String mimeType = (track.mimeType ?? '').replaceAll('video/', '');
    final String trackName = preferredName ??
        "${width}x$height ${IAppPlayerUtils.formatBitrate(bitrate)} $mimeType";

    final IAppPlayerAsmsTrack? selectedTrack =
        iappPlayerController!.iappPlayerAsmsTrack;
    final bool isSelected = selectedTrack != null && selectedTrack == track;

    return _buildSelectionRow(
      text: trackName,
      isSelected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        iappPlayerController!.setTrack(track);
      },
    );
  }

  // 构建分辨率选择行
  Widget _buildResolutionSelectionRow(String name, String url) {
    final bool isSelected =
        url == iappPlayerController!.iappPlayerDataSource!.url;
    return _buildSelectionRow(
      text: name,
      isSelected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        iappPlayerController!.setResolution(url);
      },
    );
  }

  // 显示音频轨道选择器
  void _showAudioTracksSelectionWidget() {
    final List<IAppPlayerAsmsAudioTrack>? asmsTracks =
        iappPlayerController!.iappPlayerAsmsAudioTracks;
    final List<Widget> children = [];
    final IAppPlayerAsmsAudioTrack? selectedAsmsAudioTrack =
        iappPlayerController!.iappPlayerAsmsAudioTrack;
    if (asmsTracks != null) {
      for (var index = 0; index < asmsTracks.length; index++) {
        final bool isSelected = selectedAsmsAudioTrack != null &&
            selectedAsmsAudioTrack == asmsTracks[index];
        children.add(_buildAudioTrackRow(asmsTracks[index], isSelected));
      }
    }

    if (children.isEmpty) {
      children.add(
        _buildAudioTrackRow(
          IAppPlayerAsmsAudioTrack(
            label: iappPlayerController!.translations.generalDefault,
          ),
          true,
        ),
      );
    }

    _showModalBottomSheet(children);
  }

  // 构建音频轨道选择行
  Widget _buildAudioTrackRow(
      IAppPlayerAsmsAudioTrack audioTrack, bool isSelected) {
    return _buildSelectionRow(
      text: audioTrack.label!,
      isSelected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        iappPlayerController!.setAudioTrack(audioTrack);
      },
    );
  }

  // 获取溢出菜单文本样式
  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected
          ? iappPlayerControlsConfiguration.overflowModalTextColor
          : iappPlayerControlsConfiguration.overflowModalTextColor
              .withOpacity(0.7),
    );
  }

  // 显示模态底页
  void _showModalBottomSheet(List<Widget> children) {
    final useRootNavigator =
        iappPlayerController?.iappPlayerConfiguration.useRootNavigator ?? false;
    
    Widget buildContent(BuildContext context) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: iappPlayerControlsConfiguration.overflowModalColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      );
    }

    if (Platform.isAndroid) {
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        useRootNavigator: useRootNavigator,
        builder: buildContent,
      );
    } else {
      showCupertinoModalPopup<void>(
        barrierColor: Colors.transparent,
        context: context,
        useRootNavigator: useRootNavigator,
        builder: buildContent,
      );
    }
  }

  // 构建从左到右方向性控件
  Widget buildLTRDirectionality(Widget child) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }

  // 更改控件可见性状态
  void changePlayerControlsNotVisible(bool notVisible) {
    setState(() {
      if (notVisible) {
        iappPlayerController?.postEvent(
            IAppPlayerEvent(IAppPlayerEventType.controlsHiddenStart));
      }
      controlsNotVisible = notVisible;
    });
  }
}
