import 'package:iapp_player/src/hls/hls_parser/exception.dart';
import 'package:iapp_player/src/hls/hls_parser/mime_types.dart';

/// 提供HLS解析的通用工具方法
class LibUtil {
  /// 缓存xs:dateTime格式正则表达式
  static final RegExp _xsDateTimeRegExp = RegExp(
      '(\\d\\d\\d\\d)\\-(\\d\\d)\\-(\\d\\d)[Tt](\\d\\d):(\\d\\d):(\\d\\d)([\\.,](\\d+))?([Zz]|((\\+|\\-)(\\d?\\d):?(\\d\\d)))?');

  /// 检查字节列表是否以指定前缀开头
  static bool startsWith(List<int> source, List<int> checker) {
    if (source.length < checker.length) return false;
    for (int i = 0; i < checker.length; i++) {
      if (source[i] != checker[i]) return false;
    }
    return true;
  }

  /// 判断字符是否为Unicode 6.2空白字符
  static bool isWhitespace(int rune) =>
      (rune >= 0x0009 && rune <= 0x000D) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00A0 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      (rune >= 0x2000 && rune <= 0x200A) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;

  /// 移除字符串中的空白字符
  static String excludeWhiteSpace(String string) {
    final buffer = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      final codeUnit = string.codeUnitAt(i);
      if (!isWhitespace(codeUnit)) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  /// 判断字符是否为换行符
  static bool isLineBreak(int codeUnit) =>
      codeUnit == '\n'.codeUnitAt(0) || codeUnit == '\r'.codeUnitAt(0);

  /// 提取指定轨道类型的编码列表
  static String? getCodecsOfType(String? codecs, int trackType) {
    if (codecs == null) return null;
    final codecsList = Util.splitCodecs(codecs);
    final filteredCodecs = <String>[];
    for (final codec in codecsList) {
      if (trackType == MimeTypes.getTrackTypeOfCodec(codec)) {
        filteredCodecs.add(codec);
      }
    }
    return filteredCodecs.isEmpty ? null : filteredCodecs.join(',');
  }

  /// 解析xs:dateTime格式字符串为毫秒时间戳
  static int parseXsDateTime(String value) {
    final matchList = _xsDateTimeRegExp.allMatches(value).toList();
    if (matchList.isEmpty) {
      throw ParserException('无效日期/时间格式: $value');
    }
    final match = matchList[0];
    int timezoneShift;
    if (match.group(9) == null || match.group(9)!.toLowerCase() == 'z') {
      timezoneShift = 0;
    } else {
      timezoneShift = int.parse(match.group(12)!) * 60 + int.parse(match.group(13)!);
      if (match.group(11) == '-') timezoneShift *= -1;
    }

    final DateTime dateTime = DateTime.utc(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!));

    int time = dateTime.millisecondsSinceEpoch;
    if (timezoneShift != 0) {
      time -= timezoneShift * 60000;
    }
    return time;
  }

  /// 将毫秒时间转换为微秒，处理源结束时间
  static int msToUs(int timeMs) =>
      timeMs == Util.timeEndOfSource ? timeMs : timeMs * 1000;
}

/// 定义轨道类型、标志位及编码处理工具
class Util {
  /// 缓存编码分割正则表达式
  static final RegExp _codecSplitRegExp = RegExp('(\\s*,\\s*)');

  /// 默认轨道选择标志
  static const int selectionFlagDefault = 1;
  /// 强制轨道选择标志
  static const int selectionFlagForced = 1 << 1; // 2
  /// 自动选择轨道标志
  static const int selectionFlagAutoSelect = 1 << 2; // 4
  /// 描述视频内容的角色标志
  static const int roleFlagDescribesVideo = 1 << 9;
  /// 描述音乐和声音的角色标志
  static const int roleFlagDescribesMusicAndSound = 1 << 10;
  /// 转录对话的角色标志
  static const int roleFlagTranscribesDialog = 1 << 12;
  /// 易读内容的角色标志
  static const int roleFlagEasyToRead = 1 << 13;

  /// 未知轨道类型
  static const int trackTypeUnknown = -1;
  /// 默认未知类型轨道
  static const int trackTypeDefault = 0;
  /// 音频轨道类型
  static const int trackTypeAudio = 1;
  /// 视频轨道类型
  static const int trackTypeVideo = 2;
  /// 文本轨道类型
  static const int trackTypeText = 3;
  /// 元数据轨道类型
  static const int trackTypeMetadata = 4;
  /// 相机运动轨道类型
  static const int trackTypeCameraMotion = 5;
  /// 空轨道类型
  static const int trackTypeNone = 6;

  /// 源结束时间标志
  static const int timeEndOfSource = 0;

  /// 分割编码字符串为列表
  static List<String> splitCodecs(String? codecs) =>
      codecs?.isNotEmpty != true ? <String>[] : codecs!.trim().split(_codecSplitRegExp);

  /// 检查数字指定位是否置位
  static bool checkBitPositionIsSet(int number, int bitPosition) =>
      (number & (1 << (bitPosition - 1))) > 0;
}

/// 定义内容加密类型常量
class CencType {
  /// CENC加密类型
  static const String cenc = 'TYPE_CENC';
  /// CBCS加密类型
  static const String cnbs = 'TYPE_CBCS';
}
