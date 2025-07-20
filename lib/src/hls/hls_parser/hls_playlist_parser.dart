import 'dart:convert';
import 'dart:typed_data';
import 'package:iapp_player/src/hls/hls_parser/drm_init_data.dart';
import 'package:iapp_player/src/hls/hls_parser/exception.dart';
import 'package:iapp_player/src/hls/hls_parser/format.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_master_playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_media_playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_track_metadata_entry.dart';
import 'package:iapp_player/src/hls/hls_parser/metadata.dart';
import 'package:iapp_player/src/hls/hls_parser/mime_types.dart';
import 'package:iapp_player/src/hls/hls_parser/playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/rendition.dart';
import 'package:iapp_player/src/hls/hls_parser/scheme_data.dart';
import 'package:iapp_player/src/hls/hls_parser/segment.dart';
import 'package:iapp_player/src/hls/hls_parser/util.dart';
import 'package:iapp_player/src/hls/hls_parser/variant.dart';
import 'package:iapp_player/src/hls/hls_parser/variant_info.dart';
import 'package:collection/collection.dart' show IterableExtension;

// HLS播放列表解析器，处理主播放列表和媒体播放列表
class HlsPlaylistParser {
  HlsPlaylistParser(this.masterPlaylist);

  // 创建解析器实例，允许可选的主播放列表
  factory HlsPlaylistParser.create({HlsMasterPlaylist? masterPlaylist}) {
    masterPlaylist ??= HlsMasterPlaylist();
    return HlsPlaylistParser(masterPlaylist);
  }

  // 定义M3U播放列表相关常量
  static const String playlistHeader = '#EXTM3U'; // 播放列表头部标记
  static const String tagPrefix = '#EXT'; // 扩展标签前缀
  static const String tagVersion = '#EXT-X-VERSION'; // 版本标签
  static const String tagPlaylistType = '#EXT-X-PLAYLIST-TYPE'; // 播放列表类型标签
  static const String tagDefine = '#EXT-X-DEFINE'; // 变量定义标签
  static const String tagStreamInf = '#EXT-X-STREAM-INF'; // 流信息标签
  static const String tagMedia = '#EXT-X-MEDIA'; // 媒体标签
  static const String tagTargetDuration = '#EXT-X-TARGETDURATION'; // 目标持续时间标签
  static const String tagDiscontinuity = '#EXT-X-DISCONTINUITY'; // 不连续标签
  static const String tagDiscontinuitySequence = '#EXT-X-DISCONTINUITY-SEQUENCE'; // 不连续序列标签
  static const String tagProgramDateTime = '#EXT-X-PROGRAM-DATE-TIME'; // 节目时间标签
  static const String tagInitSegment = '#EXT-X-MAP'; // 初始化段标签
  static const String tagIndependentSegments = '#EXT-X-INDEPENDENT-SEGMENTS'; // 独立段标签
  static const String tagMediaDuration = '#EXTINF'; // 媒体持续时间标签
  static const String tagMediaSequence = '#EXT-X-MEDIA-SEQUENCE'; // 媒体序列标签
  static const String tagStart = '#EXT-X-START'; // 开始时间偏移标签
  static const String tagEndList = '#EXT-X-ENDLIST'; // 播放列表结束标签
  static const String tagKey = '#EXT-X-KEY'; // 加密密钥标签
  static const String tagSessionKey = '#EXT-X-SESSION-KEY'; // 会话密钥标签
  static const String tagByteRange = '#EXT-X-BYTERANGE'; // 字节范围标签
  static const String tagGap = '#EXT-X-GAP'; // 间隙标签
  static const String typeAudio = 'AUDIO'; // 音频类型
  static const String typeVideo = 'VIDEO'; // 视频类型
  static const String typeSubtitles = 'SUBTITLES'; // 字幕类型
  static const String typeClosedCaptions = 'CLOSED-CAPTIONS'; // 隐藏字幕类型
  static const String methodNone = 'NONE'; // 无加密方法
  static const String methodAes128 = 'AES-128'; // AES-128加密方法
  static const String methodSampleAes = 'SAMPLE-AES'; // 样本AES加密方法
  static const String methodSampleAesCenc = 'SAMPLE-AES-CENC'; // CENC样本AES加密
  static const String methodSampleAesCtr = 'SAMPLE-AES-CTR'; // CTR样本AES加密
  static const String keyFormatPlayReady = 'com.microsoft.playready'; // PlayReady密钥格式
  static const String keyFormatIdentity = 'identity'; // 身份密钥格式
  static const String keyFormatWidevinePsshBinary = 'urn:uuid:edef8ba9-79d6-4ace-a3c8-27dcd51d21ed'; // Widevine PSSH二进制格式
  static const String keyFormatWidevinePsshJson = 'com.widevine'; // Widevine PSSH JSON格式
  static const String booleanTrue = 'YES'; // 布尔值真
  static const String booleanFalse = 'NO'; // 布尔值假
  static const String attrClosedCaptionsNone = 'CLOSED-CAPTIONS=NONE'; // 无隐藏字幕属性

  // 预编译正则表达式，提升解析效率
  static final RegExp regexpAverageBandwidthPattern = RegExp('AVERAGE-BANDWIDTH=(\\d+)\\b'); // 平均带宽正则
  static final RegExp regexpVideoPattern = RegExp('VIDEO="(.+?)"'); // 视频组ID正则
  static final RegExp regexpAudioPattern = RegExp('AUDIO="(.+?)"'); // 音频组ID正则
  static final RegExp regexpSubtitlesPattern = RegExp('SUBTITLES="(.+?)"'); // 字幕组ID正则
  static final RegExp regexpClosedCaptionsPattern = RegExp('CLOSED-CAPTIONS="(.+?)"'); // 隐藏字幕组ID正则
  static final RegExp regexpBandwidthPattern = RegExp('[^-]BANDWIDTH=(\\d+)\\b'); // 带宽正则
  static final RegExp regexpChannelsPattern = RegExp('CHANNELS="(.+?)"'); // 声道正则
  static final RegExp regexpCodecsPattern = RegExp('CODECS="(.+?)"'); // 编解码器正则
  static final RegExp regexpResolutionsPattern = RegExp('RESOLUTION=(\\d+x\\d+)'); // 分辨率正则
  static final RegExp regexpFrameRatePattern = RegExp('FRAME-RATE=([\\d\\.]+)\\b'); // 帧率正则
  static final RegExp regexpTargetDurationPattern = RegExp('$tagTargetDuration:(\\d+)\\b'); // 目标持续时间正则
  static final RegExp regexpVersionPattern = RegExp('$tagVersion:(\\d+)\\b'); // 版本正则
  static final RegExp regexpPlaylistTypePattern = RegExp('$tagPlaylistType:(.+)\\b'); // 播放列表类型正则
  static final RegExp regexpMediaSequencePattern = RegExp('$tagMediaSequence:(\\d+)\\b'); // 媒体序列正则
  static final RegExp regexpMediaDurationPattern = RegExp('$tagMediaDuration:([\\d\\.]+)\\b'); // 媒体持续时间正则
  static final RegExp regexpMediaTitlePattern = RegExp('$tagMediaDuration:[\\d\\.]+\\b,(.+)'); // 媒体标题正则
  static final RegExp regexpTimeOffsetPattern = RegExp('TIME-OFFSET=(-?[\\d\\.]+)\\b'); // 时间偏移正则
  static final RegExp regexpByteRangePattern = RegExp('$tagByteRange:(\\d+(?:@\\d+)?)\\b'); // 字节范围正则
  static final RegExp regexpAttrByteRangePattern = RegExp('BYTERANGE="(\\d+(?:@\\d+)?)\\b"'); // 属性字节范围正则
  static final RegExp regexpMethodPattern = 
      RegExp('METHOD=($methodNone|$methodAes128|$methodSampleAes|$methodSampleAesCenc|$methodSampleAesCtr)\\s*(?:,|\$)'); // 加密方法正则
  static final RegExp regexpKeyFormatPattern = RegExp('KEYFORMAT="(.+?)"'); // 密钥格式正则
  static final RegExp regexpKeyFormatVersionsPattern = RegExp('KEYFORMATVERSIONS="(.+?)"'); // 密钥格式版本正则
  static final RegExp regexpUriPattern = RegExp('URI="(.+?)"'); // URI正则
  static final RegExp regexpIvPattern = RegExp('IV=([^,.*]+)'); // 初始化向量正则
  static final RegExp regexpTypePattern = 
      RegExp('TYPE=($typeAudio|$typeVideo|$typeSubtitles|$typeClosedCaptions)'); // 媒体类型正则
  static final RegExp regexpLanguagePattern = RegExp('LANGUAGE="(.+?)"'); // 语言正则
  static final RegExp regexpNamePattern = RegExp('NAME="(.+?)"'); // 名称正则
  static final RegExp regexpGroupIdPattern = RegExp('GROUP-ID="(.+?)"'); // 组ID正则
  static final RegExp regexpCharacteristicsPattern = RegExp('CHARACTERISTICS="(.+?)"'); // 特性正则
  static final RegExp regexpInStreamIdPattern = RegExp('INSTREAM-ID="((?:CC|SERVICE)\\d+)"'); // 流内ID正则
  static final RegExp regexpAutoSelectPattern = 
      RegExp(_compileBooleanAttrPattern('AUTOSELECT')); // 自动选择正则
  static final RegExp regexpDefaultPattern = 
      RegExp(_compileBooleanAttrPattern('DEFAULT')); // 默认选择正则
  static final RegExp regexpForcedPattern = 
      RegExp(_compileBooleanAttrPattern('FORCED')); // 强制选择正则
  static final RegExp regexpValuePattern = RegExp('VALUE="(.+?)"'); // 值正则
  static final RegExp regexpImportPattern = RegExp('IMPORT="(.+?)"'); // 导入正则
  static final RegExp regexpVariableReferencePattern = RegExp('\\{\\\$([a-zA-Z0-9\\-_]+)\\}'); // 变量引用正则

  // 正则表达式字符串常量，用于后续查找
  static const String regexpAverageBandwidth = 'AVERAGE-BANDWIDTH=(\\d+)\\b';
  static const String regexpVideo = 'VIDEO="(.+?)"';
  static const String regexpAudio = 'AUDIO="(.+?)"';
  static const String regexpSubtitles = 'SUBTITLES="(.+?)"';
  static const String regexpClosedCaptions = 'CLOSED-CAPTIONS="(.+?)"';
  static const String regexpBandwidth = '[^-]BANDWIDTH=(\\d+)\\b';
  static const String regexpChannels = 'CHANNELS="(.+?)"';
  static const String regexpCodecs = 'CODECS="(.+?)"';
  static const String regexpResolutions = 'RESOLUTION=(\\d+x\\d+)';
  static const String regexpFrameRate = 'FRAME-RATE=([\\d\\.]+)\\b';
  static const String regexpTargetDuration = '$tagTargetDuration:(\\d+)\\b';
  static const String regexpVersion = '$tagVersion:(\\d+)\\b';
  static const String regexpPlaylistType = '$tagPlaylistType:(.+)\\b';
  static const String regexpMediaSequence = '$tagMediaSequence:(\\d+)\\b';
  static const String regexpMediaDuration = '$tagMediaDuration:([\\d\\.]+)\\b';
  static const String regexpMediaTitle = '$tagMediaDuration:[\\d\\.]+\\b,(.+)';
  static const String regexpTimeOffset = 'TIME-OFFSET=(-?[\\d\\.]+)\\b';
  static const String regexpByteRange = '$tagByteRange:(\\d+(?:@\\d+)?)\\b';
  static const String regexpAttrByteRange = 'BYTERANGE="(\\d+(?:@\\d+)?)\\b"';
  static const String regexpMethod =
      'METHOD=($methodNone|$methodAes128|$methodSampleAes|$methodSampleAesCenc|$methodSampleAesCtr)\\s*(?:,|\$)';
  static const String regexpKeyFormat = 'KEYFORMAT="(.+?)"';
  static const String regexpKeyFormatVersions = 'KEYFORMATVERSIONS="(.+?)"';
  static const String regexpUri = 'URI="(.+?)"';
  static const String regexpIv = 'IV=([^,.*]+)';
  static const String regexpType =
      'TYPE=($typeAudio|$typeVideo|$typeSubtitles|$typeClosedCaptions)';
  static const String regexpLanguage = 'LANGUAGE="(.+?)"';
  static const String regexpName = 'NAME="(.+?)"';
  static const String regexpGroupId = 'GROUP-ID="(.+?)"';
  static const String regexpCharacteristics = 'CHARACTERISTICS="(.+?)"';
  static const String regexpInStreamId = 'INSTREAM-ID="((?:CC|SERVICE)\\d+)"';
  static const String regexpValue = 'VALUE="(.+?)"';
  static const String regexpImport = 'IMPORT="(.+?)"';
  static const String regexpVariableReference = '\\{\\\$([a-zA-Z0-9\\-_]+)\\}';
  static final String regexpAutoSelect = _compileBooleanAttrPattern('AUTOSELECT');
  static final String regexpDefault = _compileBooleanAttrPattern('DEFAULT');
  static final String regexpForced = _compileBooleanAttrPattern('FORCED');

  final HlsMasterPlaylist masterPlaylist;

  // 解析字符串形式的播放列表
  Future<HlsPlaylist> parseString(Uri? uri, String inputString) async {
    final List<String> lines = const LineSplitter().convert(inputString);
    return parse(uri, lines);
  }

  // 解析播放列表行，区分主播放列表和媒体播放列表
  Future<HlsPlaylist> parse(Uri? uri, List<String> inputLineList) async {
    final List<String> lineList = inputLineList
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // 验证播放列表头部
    if (!_checkPlaylistHeader(lineList[0])) {
      throw UnrecognizedInputFormatException(
          'Input does not start with the #EXTM3U header.', uri);
    }

    final List<String> extraLines = lineList.getRange(1, lineList.length).toList();

    bool? isMasterPlayList;
    for (final line in extraLines) {
      if (line.startsWith(tagStreamInf)) {
        isMasterPlayList = true;
        break;
      } else if (line.startsWith(tagTargetDuration) ||
          line.startsWith(tagMediaSequence) ||
          line.startsWith(tagMediaDuration) ||
          line.startsWith(tagKey) ||
          line.startsWith(tagByteRange) ||
          line == tagDiscontinuity ||
          line == tagDiscontinuitySequence ||
          line == tagEndList) {
        isMasterPlayList = false;
      }
    }
    if (isMasterPlayList == null) {
      throw const FormatException("extraLines doesn't have valid tag");
    }

    return isMasterPlayList
        ? _parseMasterPlaylist(extraLines.iterator, uri.toString())
        : _parseMediaPlaylist(masterPlaylist, extraLines, uri.toString());
  }

  // 编译布尔属性正则表达式
  static String _compileBooleanAttrPattern(String attribute) =>
      '$attribute=($booleanFalse|$booleanTrue)';

  // 检查播放列表头部是否有效
  static bool _checkPlaylistHeader(String string) {
    List<int> codeUnits = LibUtil.excludeWhiteSpace(string).codeUnits;

    if (codeUnits[0] == 0xEF) {
      if (LibUtil.startsWith(codeUnits, [0xEF, 0xBB, 0xBF])) {
        return false;
      }
      codeUnits = codeUnits.getRange(5, codeUnits.length - 1).toList();
    }

    if (!LibUtil.startsWith(codeUnits, playlistHeader.runes.toList())) {
      return false;
    }

    return true;
  }

  // 解析主播放列表
  HlsMasterPlaylist _parseMasterPlaylist(
      Iterator<String> extraLines, String baseUri) {
    final List<String> tags = [];
    final List<String> mediaTags = [];
    final List<DrmInitData> sessionKeyDrmInitData = [];
    final List<Variant> variants = [];
    final List<Rendition> videos = [];
    final List<Rendition> audios = [];
    final List<Rendition> subtitles = [];
    final List<Rendition> closedCaptions = [];
    final Map<Uri, List<VariantInfo>> urlToVariantInfos = {};
    Format? muxedAudioFormat;
    bool noClosedCaptions = false;
    bool hasIndependentSegmentsTag = false;
    List<Format>? muxedCaptionFormats;
    final Map<String?, String> variableDefinitions = {};

    while (extraLines.moveNext()) {
      final String line = extraLines.current;

      if (line.startsWith(tagDefine)) {
        // 解析变量定义
        final String? key = _parseStringAttr(
            source: line,
            pattern: regexpName,
            variableDefinitions: variableDefinitions);
        final String? val = _parseStringAttr(
            source: line,
            pattern: regexpValue,
            variableDefinitions: variableDefinitions);
        if (key == null) {
          throw ParserException("Couldn't match $regexpName in $line");
        }
        if (val == null) {
          throw ParserException("Couldn't match $regexpValue in $line");
        }
        variableDefinitions[key] = val;
      } else if (line == tagIndependentSegments) {
        // 标记独立段
        hasIndependentSegmentsTag = true;
      } else if (line.startsWith(tagMedia)) {
        // 收集媒体标签
        mediaTags.add(line);
      } else if (line.startsWith(tagSessionKey)) {
        // 解析会话密钥
        final String? keyFormat = _parseStringAttr(
            source: line,
            pattern: regexpKeyFormat,
            defaultValue: keyFormatIdentity,
            variableDefinitions: variableDefinitions);
        final SchemeData? schemeData = _parseDrmSchemeData(
            line: line,
            keyFormat: keyFormat,
            variableDefinitions: variableDefinitions);

        if (schemeData != null) {
          final String? method = _parseStringAttr(
              source: line,
              pattern: regexpMethod,
              variableDefinitions: variableDefinitions);
          final String scheme = _parseEncryptionScheme(method);
          final DrmInitData drmInitData = DrmInitData(
              schemeType: scheme,
              schemeData: [schemeData]);
          sessionKeyDrmInitData.add(drmInitData);
        }
      } else if (line.startsWith(tagStreamInf)) {
        // 解析流信息
        noClosedCaptions |= line.contains(attrClosedCaptionsNone);
        final int bitrate = int.parse(
            _parseStringAttr(source: line, pattern: regexpBandwidth)!);
        int averageBitrate = 0;
        final String? averageBandwidthString = _parseStringAttr(
            source: line,
            pattern: regexpAverageBandwidth,
            variableDefinitions: variableDefinitions);
        if (averageBandwidthString != null) {
          averageBitrate = int.parse(averageBandwidthString);
        }
        final String? codecs = _parseStringAttr(
            source: line,
            pattern: regexpCodecs,
            variableDefinitions: variableDefinitions);
        final String? resolutionString = _parseStringAttr(
            source: line,
            pattern: regexpResolutions,
            variableDefinitions: variableDefinitions);
        int? width;
        int? height;
        if (resolutionString != null) {
          final List<String> widthAndHeight = resolutionString.split('x');
          width = int.parse(widthAndHeight[0]);
          height = int.parse(widthAndHeight[1]);
          if (width <= 0 || height <= 0) {
            width = null;
            height = null;
          }
        }

        double? frameRate;
        final String? frameRateString = _parseStringAttr(
            source: line,
            pattern: regexpFrameRate,
            variableDefinitions: variableDefinitions);
        if (frameRateString != null) {
          frameRate = double.parse(frameRateString);
        }
        final String? videoGroupId = _parseStringAttr(
            source: line,
            pattern: regexpVideo,
            variableDefinitions: variableDefinitions);
        final String? audioGroupId = _parseStringAttr(
            source: line,
            pattern: regexpAudio,
            variableDefinitions: variableDefinitions);
        final String? subtitlesGroupId = _parseStringAttr(
            source: line,
            pattern: regexpSubtitles,
            variableDefinitions: variableDefinitions);
        final String? closedCaptionsGroupId = _parseStringAttr(
            source: line,
            pattern: regexpClosedCaptions,
            variableDefinitions: variableDefinitions);

        extraLines.moveNext();

        final String referenceUri = _parseStringAttr(
            source: extraLines.current,
            variableDefinitions: variableDefinitions)!;
        final Uri uri = Uri.parse(baseUri).resolve(referenceUri);

        final Format format = Format.createVideoContainerFormat(
            id: variants.length.toString(),
            containerMimeType: MimeTypes.applicationM3u8,
            codecs: codecs,
            bitrate: bitrate,
            averageBitrate: averageBitrate,
            width: width,
            height: height,
            frameRate: frameRate);

        variants.add(Variant(
          url: uri,
          format: format,
          videoGroupId: videoGroupId,
          audioGroupId: audioGroupId,
          subtitleGroupId: subtitlesGroupId,
          captionGroupId: closedCaptionsGroupId,
        ));

        List<VariantInfo>? variantInfosForUrl = urlToVariantInfos[uri];
        if (variantInfosForUrl == null) {
          variantInfosForUrl = [];
          urlToVariantInfos[uri] = variantInfosForUrl;
        }

        variantInfosForUrl.add(VariantInfo(
          bitrate: bitrate != 0 ? bitrate : averageBitrate,
          videoGroupId: videoGroupId,
          audioGroupId: audioGroupId,
          subtitleGroupId: subtitlesGroupId,
          captionGroupId: closedCaptionsGroupId,
        ));
      }
    }

    // 去重变体
    final List<Variant> deduplicatedVariants = [];
    final Set<Uri> urlsInDeduplicatedVariants = {};
    for (int i = 0; i < variants.length; i++) {
      final Variant variant = variants[i];
      if (urlsInDeduplicatedVariants.add(variant.url)) {
        assert(variant.format.metadata == null);
        final HlsTrackMetadataEntry hlsMetadataEntry =
            HlsTrackMetadataEntry(variantInfos: urlToVariantInfos[variant.url]);
        final Metadata metadata = Metadata([hlsMetadataEntry]);
        deduplicatedVariants.add(
            variant.copyWithFormat(variant.format.copyWithMetadata(metadata)));
      }
    }

    // 解析媒体标签
    for (final line in mediaTags) {
      final String? groupId = _parseStringAttr(
          source: line,
          pattern: regexpGroupId,
          variableDefinitions: variableDefinitions);
      final String? name = _parseStringAttr(
          source: line,
          pattern: regexpName,
          variableDefinitions: variableDefinitions);
      final String? referenceUri = _parseStringAttr(
          source: line,
          pattern: regexpUri,
          variableDefinitions: variableDefinitions);

      Uri uri = Uri.parse(baseUri);
      if (referenceUri != null) uri = uri.resolve(referenceUri);

      final String? language = _parseStringAttr(
          source: line,
          pattern: regexpLanguage,
          variableDefinitions: variableDefinitions);
      final int selectionFlags = _parseSelectionFlags(line);
      final int roleFlags = _parseRoleFlags(line, variableDefinitions);
      final String formatId = '$groupId:$name';
      Format format;
      final HlsTrackMetadataEntry entry = HlsTrackMetadataEntry(
          groupId: groupId, name: name, variantInfos: <VariantInfo>[]);
      final Metadata metadata = Metadata([entry]);

      switch (_parseStringAttr(
          source: line,
          pattern: regexpType,
          variableDefinitions: variableDefinitions)) {
        case typeVideo:
          {
            final Variant? variant =
                variants.firstWhereOrNull((it) => it.videoGroupId == groupId);
            String? codecs;
            int? width;
            int? height;
            double? frameRate;
            if (variant != null) {
              final Format variantFormat = variant.format;
              codecs = LibUtil.getCodecsOfType(
                  variantFormat.codecs, Util.trackTypeVideo);
              width = variantFormat.width;
              height = variantFormat.height;
              frameRate = variantFormat.frameRate;
            }
            final String? sampleMimeType =
                codecs != null ? MimeTypes.getMediaMimeType(codecs) : null;

            format = Format.createVideoContainerFormat(
                    id: formatId,
                    label: name,
                    containerMimeType: MimeTypes.applicationM3u8,
                    sampleMimeType: sampleMimeType,
                    codecs: codecs,
                    width: width,
                    height: height,
                    frameRate: frameRate,
                    selectionFlags: selectionFlags,
                    roleFlags: roleFlags)
                .copyWithMetadata(metadata);

            videos.add(Rendition(
              url: uri,
              format: format,
              groupId: groupId,
              name: name,
            ));
            break;
          }
        case typeAudio:
          {
            final Variant? variant =
                _getVariantWithAudioGroup(variants, groupId);
            final String? codecs = variant != null
                ? LibUtil.getCodecsOfType(
                    variant.format.codecs, Util.trackTypeAudio)
                : null;
            final int? channelCount =
                _parseChannelsAttribute(line, variableDefinitions);
            final String? sampleMimeType =
                codecs != null ? MimeTypes.getMediaMimeType(codecs) : null;
            final Format format = Format(
              id: formatId,
              label: name,
              containerMimeType: MimeTypes.applicationM3u8,
              sampleMimeType: sampleMimeType,
              codecs: codecs,
              channelCount: channelCount,
              selectionFlags: selectionFlags,
              roleFlags: roleFlags,
              language: language,
            );

            if (uri == null) {
              muxedAudioFormat = format;
            } else {
              audios.add(Rendition(
                url: uri,
                format: format.copyWithMetadata(metadata),
                groupId: groupId,
                name: name,
              ));
            }
            break;
          }
        case typeSubtitles:
          {
            final Format format = Format(
                    id: formatId,
                    label: name,
                    containerMimeType: MimeTypes.applicationM3u8,
                    sampleMimeType: MimeTypes.textVtt,
                    selectionFlags: selectionFlags,
                    roleFlags: roleFlags,
                    language: language)
                .copyWithMetadata(metadata);
            subtitles.add(Rendition(
              url: uri,
              format: format,
              groupId: groupId,
              name: name,
            ));
            break;
          }
        case typeClosedCaptions:
          {
            final String instreamId = _parseStringAttr(
                source: line,
                pattern: regexpInStreamId,
                variableDefinitions: variableDefinitions)!;
            String mimeType;
            int accessibilityChannel;
            if (instreamId.startsWith('CC')) {
              mimeType = MimeTypes.applicationCea608;
              accessibilityChannel = int.parse(instreamId.substring(2));
            } else /* starts with SERVICE */ {
              mimeType = MimeTypes.applicationCea708;
              accessibilityChannel = int.parse(instreamId.substring(7));
            }
            muxedCaptionFormats ??= [];
            muxedCaptionFormats!.add(Format(
              id: formatId,
              label: name,
              sampleMimeType: mimeType,
              selectionFlags: selectionFlags,
              roleFlags: roleFlags,
              language: language,
              accessibilityChannel: accessibilityChannel,
            ));
            break;
          }
        default:
          break;
      }
    }

    if (noClosedCaptions) {
      muxedCaptionFormats = [];
    }

    // 创建主播放列表对象
    return HlsMasterPlaylist(
        baseUri: baseUri,
        tags: tags,
        variants: deduplicatedVariants,
        videos: videos,
        audios: audios,
        subtitles: subtitles,
        closedCaptions: closedCaptions,
        muxedAudioFormat: muxedAudioFormat,
        muxedCaptionFormats: muxedCaptionFormats,
        hasIndependentSegments: hasIndependentSegmentsTag,
        variableDefinitions: variableDefinitions,
        sessionKeyDrmInitData: sessionKeyDrmInitData);
  }

  // 解析字符串属性，替换变量引用
  static String? _parseStringAttr({
    required String? source,
    String? pattern,
    String? defaultValue,
    Map<String?, String?>? variableDefinitions,
  }) {
    String? value;
    if (pattern == null) {
      value = source;
    } else {
      final regex = _getCompiledRegex(pattern);
      value = regex.firstMatch(source!)?.group(1);
      value ??= defaultValue;
    }

    return value?.replaceAllMapped(
        regexpVariableReferencePattern,
        (Match match) => variableDefinitions![match.group(1)] ??=
            value!.substring(match.start, match.end));
  }

  // 获取预编译正则表达式
  static RegExp _getCompiledRegex(String pattern) {
    switch (pattern) {
      case regexpAverageBandwidth:
        return regexpAverageBandwidthPattern;
      case regexpVideo:
        return regexpVideoPattern;
      case regexpAudio:
        return regexpAudioPattern;
      case regexpSubtitles:
        return regexpSubtitlesPattern;
      case regexpClosedCaptions:
        return regexpClosedCaptionsPattern;
      case regexpBandwidth:
        return regexpBandwidthPattern;
      case regexpChannels:
        return regexpChannelsPattern;
      case regexpCodecs:
        return regexpCodecsPattern;
      case regexpResolutions:
        return regexpResolutionsPattern;
      case regexpFrameRate:
        return regexpFrameRatePattern;
      case regexpTargetDuration:
        return regexpTargetDurationPattern;
      case regexpVersion:
        return regexpVersionPattern;
      case regexpPlaylistType:
        return regexpPlaylistTypePattern;
      case regexpMediaSequence:
        return regexpMediaSequencePattern;
      case regexpMediaDuration:
        return regexpMediaDurationPattern;
      case regexpMediaTitle:
        return regexpMediaTitlePattern;
      case regexpTimeOffset:
        return regexpTimeOffsetPattern;
      case regexpByteRange:
        return regexpByteRangePattern;
      case regexpAttrByteRange:
        return regexpAttrByteRangePattern;
      case regexpMethod:
        return regexpMethodPattern;
      case regexpKeyFormat:
        return regexpKeyFormatPattern;
      case regexpKeyFormatVersions:
        return regexpKeyFormatVersionsPattern;
      case regexpUri:
        return regexpUriPattern;
      case regexpIv:
        return regexpIvPattern;
      case regexpType:
        return regexpTypePattern;
      case regexpLanguage:
        return regexpLanguagePattern;
      case regexpName:
        return regexpNamePattern;
      case regexpGroupId:
        return regexpGroupIdPattern;
      case regexpCharacteristics:
        return regexpCharacteristicsPattern;
      case regexpInStreamId:
        return regexpInStreamIdPattern;
      case regexpValue:
        return regexpValuePattern;
      case regexpImport:
        return regexpImportPattern;
      default:
        return RegExp(pattern);
    }
  }

  // 解析DRM方案数据
  static SchemeData? _parseDrmSchemeData(
      {String? line,
      String? keyFormat,
      Map<String?, String?>? variableDefinitions}) {
    final String? keyFormatVersions = _parseStringAttr(
      source: line,
      pattern: regexpKeyFormatVersions,
      defaultValue: '1',
      variableDefinitions: variableDefinitions,
    );

    if (keyFormatWidevinePsshBinary == keyFormat) {
      final String uriString = _parseStringAttr(
          source: line,
          pattern: regexpUri,
          variableDefinitions: variableDefinitions)!;
      final Uint8List data = _getBase64FromUri(uriString);
      return SchemeData(
          mimeType: MimeTypes.videoMp4,
          data: data);
    } else if (keyFormatWidevinePsshJson == keyFormat) {
      return SchemeData(
          mimeType: MimeTypes.hls,
          data: const Utf8Encoder().convert(line!));
    } else if (keyFormatPlayReady == keyFormat && '1' == keyFormatVersions) {
      final String uriString = _parseStringAttr(
          source: line,
          pattern: regexpUri,
          variableDefinitions: variableDefinitions)!;
      final Uint8List data = _getBase64FromUri(uriString);
      return SchemeData(mimeType: MimeTypes.videoMp4, data: data);
    }

    return null;
  }

  // 解析选择标志
  static int _parseSelectionFlags(String line) {
    int flags = 0;

    if (parseOptionalBooleanAttribute(
        line: line,
        pattern: regexpDefault,
        defaultValue: false)) flags |= Util.selectionFlagDefault;
    if (parseOptionalBooleanAttribute(
        line: line,
        pattern: regexpForced,
        defaultValue: false)) flags |= Util.selectionFlagForced;
    if (parseOptionalBooleanAttribute(
        line: line,
        pattern: regexpAutoSelect,
        defaultValue: false)) flags |= Util.selectionFlagAutoSelect;
    return flags;
  }

  // 解析可选布尔属性
  static bool parseOptionalBooleanAttribute({
    required String line,
    required String pattern,
    required bool defaultValue,
  }) {
    final regex = _getCompiledRegex(pattern);
    final List<Match> list = regex.allMatches(line).toList();
    final ret = list.isEmpty
        ? defaultValue
        : line
            .substring(list.first.start, list.first.end)
            .contains(booleanTrue);
    return ret;
  }

  // 解析角色标志
  static int _parseRoleFlags(
      String line, Map<String?, String> variableDefinitions) {
    final String? concatenatedCharacteristics = _parseStringAttr(
        source: line,
        pattern: regexpCharacteristics,
        variableDefinitions: variableDefinitions);
    if (concatenatedCharacteristics?.isEmpty != false) return 0;
    final List<String> characteristics =
        concatenatedCharacteristics!.split(',');
    int roleFlags = 0;
    if (characteristics.contains('public.accessibility.describes-video')) {
      roleFlags |= Util.roleFlagDescribesVideo;
    }

    if (characteristics
        .contains('public.accessibility.transcribes-spoken-dialog')) {
      roleFlags |= Util.roleFlagTranscribesDialog;
    }

    if (characteristics
        .contains('public.accessibility.describes-music-and-sound')) {
      roleFlags |= Util.roleFlagDescribesMusicAndSound;
    }

    if (characteristics.contains('public.easy-to-read')) {
      roleFlags |= Util.roleFlagEasyToRead;
    }

    return roleFlags;
  }

  // 解析声道属性
  static int? _parseChannelsAttribute(
      String line, Map<String?, String> variableDefinitions) {
    final String? channelsString = _parseStringAttr(
        source: line,
        pattern: regexpChannels,
        variableDefinitions: variableDefinitions);
    return channelsString != null
        ? int.parse(channelsString.split('/')[0])
        : null;
  }

  // 获取具有指定音频组的变体
  static Variant? _getVariantWithAudioGroup(
      List<Variant> variants, String? groupId) {
    for (final variant in variants) {
      if (variant.audioGroupId == groupId) return variant;
    }
    return null;
  }

  // 解析加密方案
  static String _parseEncryptionScheme(String? method) =>
      methodSampleAesCenc == method || methodSampleAesCtr == method
          ? CencType.cenc
          : CencType.cnbs;

  // 从URI获取Base64数据
  static Uint8List _getBase64FromUri(String uriString) {
    final String uriPre = uriString.substring(uriString.indexOf(',') + 1);
    return const Base64Decoder().convert(uriPre);
  }

  // 解析媒体播放列表
  static HlsMediaPlaylist _parseMediaPlaylist(HlsMasterPlaylist masterPlaylist,
      List<String> extraLines, String baseUri) {
    int playlistType = HlsMediaPlaylist.playlistTypeUnknown;
    int? startOffsetUs;
    int? mediaSequence;
    int? version;
    int? targetDurationUs;
    bool hasIndependentSegmentsTag = masterPlaylist.hasIndependentSegments;
    bool hasEndTag = false;
    int? segmentByteRangeOffset;
    Segment? initializationSegment;
    final Map<String?, String?> variableDefinitions = {};
    final List<Segment> segments = [];
    final List<String> tags = [];
    int? segmentByteRangeLength;
    int? segmentMediaSequence = 0;
    int? segmentDurationUs;
    String? segmentTitle;
    final Map<String?, SchemeData> currentSchemeDatas = {};
    DrmInitData? cachedDrmInitData;
    String? encryptionScheme;
    DrmInitData? playlistProtectionSchemes;
    bool hasDiscontinuitySequence = false;
    int playlistDiscontinuitySequence = 0;
    int? relativeDiscontinuitySequence;
    int? playlistStartTimeUs;
    int? segmentStartTimeUs;
    bool hasGapTag = false;

    String? fullSegmentEncryptionKeyUri;
    String? fullSegmentEncryptionIV;

    for (final line in extraLines) {
      if (line.startsWith(tagPrefix)) {
        tags.add(line);
      }

      if (line.startsWith(tagPlaylistType)) {
        // 解析播放列表类型
        final String? playlistTypeString = _parseStringAttr(
            source: line,
            pattern: regexpPlaylistType,
            variableDefinitions: variableDefinitions);
        if ('VOD' == playlistTypeString) {
          playlistType = HlsMediaPlaylist.playlistTypeVod;
        } else if ('EVENT' == playlistTypeString) {
          playlistType = HlsMediaPlaylist.playlistTypeEvent;
        }
      } else if (line.startsWith(tagStart)) {
        // 解析开始时间偏移
        final String string = _parseStringAttr(
            source: line,
            pattern: regexpTimeOffset,
            variableDefinitions: {})!;
        startOffsetUs = (double.parse(string) * 1000000).toInt();
      } else if (line.startsWith(tagInitSegment)) {
        // 解析初始化段
        final String? uri = _parseStringAttr(
            source: line,
            pattern: regexpUri,
            variableDefinitions: variableDefinitions);
        final String? byteRange = _parseStringAttr(
            source: line,
            pattern: regexpAttrByteRange,
            variableDefinitions: variableDefinitions);
        if (byteRange != null) {
          final List<String> splitByteRange = byteRange.split('@');
          segmentByteRangeLength = int.parse(splitByteRange[0]);
          if (splitByteRange.length > 1) {
            segmentByteRangeOffset = int.parse(splitByteRange[1]);
          }
        }

        if (fullSegmentEncryptionKeyUri != null &&
            fullSegmentEncryptionIV == null) {
          throw ParserException(
              'The encryption IV attribute must be present when an initialization segment is encrypted with METHOD=AES-128.');
        }

        initializationSegment = Segment(
            url: uri,
            byterangeOffset: segmentByteRangeOffset,
            byterangeLength: segmentByteRangeLength,
            fullSegmentEncryptionKeyUri: fullSegmentEncryptionKeyUri,
            encryptionIV: fullSegmentEncryptionIV);
        segmentByteRangeOffset = null;
        segmentByteRangeLength = null;
      } else if (line.startsWith(tagTargetDuration)) {
        // 解析目标持续时间
        targetDurationUs = int.parse(_parseStringAttr(
                source: line, pattern: regexpTargetDuration)!) *
            1000000;
      } else if (line.startsWith(tagMediaSequence)) {
        // 解析媒体序列
        mediaSequence = int.parse(
            _parseStringAttr(source: line, pattern: regexpMediaSequence)!);
        segmentMediaSequence = mediaSequence;
      } else if (line.startsWith(tagVersion)) {
        // 解析版本
        version =
            int.parse(_parseStringAttr(source: line, pattern: regexpVersion)!);
      } else if (line.startsWith(tagDefine)) {
        // 解析变量定义
        final String? importName = _parseStringAttr(
            source: line,
            pattern: regexpImport,
            variableDefinitions: variableDefinitions);
        if (importName != null) {
          final String? value = masterPlaylist.variableDefinitions[importName];
          if (value != null) {
            variableDefinitions[importName] = value;
          }
        } else {
          final String? key = _parseStringAttr(
              source: line,
              pattern: regexpName,
              variableDefinitions: variableDefinitions);
          final String? value = _parseStringAttr(
              source: line,
              pattern: regexpValue,
              variableDefinitions: variableDefinitions);
          variableDefinitions[key] = value;
        }
      } else if (line.startsWith(tagMediaDuration)) {
        // 解析媒体持续时间和标题
        final String string =
            _parseStringAttr(source: line, pattern: regexpMediaDuration)!;
        segmentDurationUs = (double.parse(string) * 1000000).toInt();
        segmentTitle = _parseStringAttr(
            source: line,
            pattern: regexpMediaTitle,
            defaultValue: '',
            variableDefinitions: variableDefinitions);
      } else if (line.startsWith(tagKey)) {
        // 解析加密密钥
        final String? method = _parseStringAttr(
            source: line,
            pattern: regexpMethod,
            variableDefinitions: variableDefinitions);
        final String? keyFormat = _parseStringAttr(
            source: line,
            pattern: regexpKeyFormat,
            defaultValue: keyFormatIdentity,
            variableDefinitions: variableDefinitions);
        fullSegmentEncryptionKeyUri = null;
        fullSegmentEncryptionIV = null;
        if (methodNone == method) {
          currentSchemeDatas.clear();
          cachedDrmInitData = null;
        } else {
          fullSegmentEncryptionIV = _parseStringAttr(
              source: line,
              pattern: regexpIv,
              variableDefinitions: variableDefinitions);
          if (keyFormatIdentity == keyFormat) {
            if (methodAes128 == method) {
              fullSegmentEncryptionKeyUri = _parseStringAttr(
                  source: line,
                  pattern: regexpUri,
                  variableDefinitions: variableDefinitions);
            }
          } else {
            encryptionScheme ??= _parseEncryptionScheme(method);
            final SchemeData? schemeData = _parseDrmSchemeData(
                line: line,
                keyFormat: keyFormat,
                variableDefinitions: variableDefinitions);
            if (schemeData != null) {
              cachedDrmInitData = null;
              currentSchemeDatas[keyFormat] = schemeData;
            }
          }
        }
      } else if (line.startsWith(tagByteRange)) {
        // 解析字节范围
        final String byteRange = _parseStringAttr(
            source: line,
            pattern: regexpByteRange,
            variableDefinitions: variableDefinitions)!;
        final List<String> splitByteRange = byteRange.split('@');
        segmentByteRangeLength = int.parse(splitByteRange[0]);
        if (splitByteRange.length > 1) {
          segmentByteRangeOffset = int.parse(splitByteRange[1]);
        }
      } else if (line.startsWith(tagDiscontinuitySequence)) {
        // 解析不连续序列
        hasDiscontinuitySequence = true;
        playlistDiscontinuitySequence =
            int.parse(line.substring(line.indexOf(':') + 1));
      } else if (line == tagDiscontinuity) {
        // 标记不连续
        relativeDiscontinuitySequence ??= 0;
        relativeDiscontinuitySequence++;
      } else if (line.startsWith(tagProgramDateTime)) {
        // 解析节目时间
        if (playlistStartTimeUs == null) {
          final int programDatetimeUs =
              LibUtil.parseXsDateTime(line.substring(line.indexOf(':') + 1));
          playlistStartTimeUs = programDatetimeUs - (segmentStartTimeUs ?? 0);
        }
      } else if (line == tagGap) {
        // 标记间隙
        hasGapTag = true;
      } else if (line == tagIndependentSegments) {
        // 标记独立段
        hasIndependentSegmentsTag = true;
      } else if (line == tagEndList) {
        // 标记播放列表结束
        hasEndTag = true;
      } else if (!line.startsWith('#')) {
        // 解析媒体段
        String? segmentEncryptionIV;
        if (fullSegmentEncryptionKeyUri == null) {
          segmentEncryptionIV = null;
        } else if (fullSegmentEncryptionIV != null) {
          segmentEncryptionIV = fullSegmentEncryptionIV;
        } else {
          segmentEncryptionIV = segmentMediaSequence!.toRadixString(16);
        }
        segmentMediaSequence = segmentMediaSequence! + 1;

        if (segmentByteRangeLength == null) segmentByteRangeOffset = null;
        if (cachedDrmInitData?.schemeData.isNotEmpty != true &&
            currentSchemeDatas.isNotEmpty) {
          final List<SchemeData> schemeDatas =
              currentSchemeDatas.values.toList();
          cachedDrmInitData = DrmInitData(
              schemeType: encryptionScheme, schemeData: schemeDatas);
          if (playlistProtectionSchemes == null) {
            final List<SchemeData> playlistSchemeDatas =
                schemeDatas.map((it) => it.copyWithData(null)).toList();
            playlistProtectionSchemes = DrmInitData(
                schemeType: encryptionScheme, schemeData: playlistSchemeDatas);
          }
        }

        final String? url = _parseStringAttr(
            source: line, variableDefinitions: variableDefinitions);
        segments.add(Segment(
            url: url,
            initializationSegment: initializationSegment,
            title: segmentTitle,
            durationUs: segmentDurationUs,
            relativeDiscontinuitySequence: relativeDiscontinuitySequence,
            relativeStartTimeUs: segmentStartTimeUs,
            drmInitData: cachedDrmInitData,
            fullSegmentEncryptionKeyUri: fullSegmentEncryptionKeyUri,
            encryptionIV: segmentEncryptionIV,
            byterangeOffset: segmentByteRangeOffset,
            byterangeLength: segmentByteRangeLength,
            hasGapTag: hasGapTag));

        if (segmentDurationUs != null) {
          segmentStartTimeUs ??= 0;
          segmentStartTimeUs += segmentDurationUs;
        }
        segmentDurationUs = null;
        segmentTitle = null;
        if (segmentByteRangeLength != null) {
          segmentByteRangeOffset ??= 0;
          segmentByteRangeOffset += segmentByteRangeLength;
        }

        segmentByteRangeLength = null;
        hasGapTag = false;
      }
    }

    // 创建媒体播放列表对象
    return HlsMediaPlaylist.create(
        playlistType: playlistType,
        baseUri: baseUri,
        tags: tags,
        startOffsetUs: startOffsetUs,
        startTimeUs: playlistStartTimeUs,
        hasDiscontinuitySequence: hasDiscontinuitySequence,
        discontinuitySequence: playlistDiscontinuitySequence,
        mediaSequence: mediaSequence,
        version: version,
        targetDurationUs: targetDurationUs,
        hasIndependentSegments: hasIndependentSegmentsTag,
        hasEndTag: hasEndTag,
        hasProgramDateTime: playlistStartTimeUs != null,
        protectionSchemes: playlistProtectionSchemes,
        segments: segments);
  }
}
