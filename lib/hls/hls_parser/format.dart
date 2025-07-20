import 'drm_init_data.dart';
import 'metadata.dart';
import 'util.dart';

/// 媒体格式类
class Format {
  Format({
    this.id,
    this.label,
    this.selectionFlags,
    this.roleFlags,
    this.bitrate,
    this.averageBitrate,
    this.codecs,
    this.metadata,
    this.containerMimeType,
    this.sampleMimeType,
    this.drmInitData,
    this.subsampleOffsetUs,
    this.width,
    this.height,
    this.frameRate,
    this.channelCount,
    String? language,
    this.accessibilityChannel,
    this.isDefault,
  }) : language = language?.toLowerCase();

  /// 创建视频容器格式
  factory Format.createVideoContainerFormat({
    String? id,
    String? label,
    String? containerMimeType,
    String? sampleMimeType,
    required String? codecs,
    int? bitrate,
    int? averageBitrate,
    required int? width,
    required int? height,
    required double? frameRate,
    int selectionFlags = Util.selectionFlagDefault,
    int? roleFlags,
    bool? isDefault,
  }) =>
      Format(
        id: id,
        label: label,
        selectionFlags: selectionFlags,
        bitrate: bitrate,
        averageBitrate: averageBitrate,
        codecs: codecs,
        containerMimeType: containerMimeType,
        sampleMimeType: sampleMimeType,
        width: width,
        height: height,
        frameRate: frameRate,
        roleFlags: roleFlags,
        isDefault: isDefault,
      );

  /// 格式标识符，未知或不适用时为null
  final String? id;

  /// 可读标签，未知或不适用时为null
  final String? label;

  /// 轨道选择标志
  final int? selectionFlags;

  /// 轨道角色标志
  final int? roleFlags;

  /// 平均带宽
  final int? bitrate;

  /// 每秒平均比特率，未知或不适用时为null
  final int? averageBitrate;

  /// RFC 6381描述的编解码器，未知或不适用时为null
  final String? codecs;

  /// 元数据，未知或不适用时为null
  final Metadata? metadata;

  /// 容器MIME类型，未知或不适用时为null
  final String? containerMimeType;

  /// 样本流MIME类型，未知或不适用时为null
  final String? sampleMimeType;

  /// 受保护流的DRM初始化数据，否则为null
  final DrmInitData? drmInitData;

  /// 子样本时间戳偏移量
  final int? subsampleOffsetUs;

  /// 视频宽度（像素），未知或不适用时为null
  final int? width;

  /// 视频高度（像素），未知或不适用时为null
  final int? height;

  /// 每秒帧率，未知或不适用时为null
  final double? frameRate;

  /// 音频通道数，未知或不适用时为null
  final int? channelCount;

  /// 视频语言，未知或不适用时为null
  final String? language;

  /// 可访问性通道，未知或不适用时为null
  final int? accessibilityChannel;

  /// 是否为默认轨道，未知或不适用时为null
  final bool? isDefault;

  /// 复制格式并更新元数据
  Format copyWithMetadata(Metadata metadata) => Format(
        id: id,
        label: label,
        selectionFlags: selectionFlags,
        roleFlags: roleFlags,
        bitrate: bitrate,
        averageBitrate: averageBitrate,
        codecs: codecs,
        metadata: metadata,
        containerMimeType: containerMimeType,
        sampleMimeType: sampleMimeType,
        drmInitData: drmInitData,
        subsampleOffsetUs: subsampleOffsetUs,
        width: width,
        height: height,
        frameRate: frameRate,
        channelCount: channelCount,
        language: language,
        accessibilityChannel: accessibilityChannel,
      );
}
