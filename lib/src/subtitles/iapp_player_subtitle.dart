import 'package:iapp_player/src/core/iapp_player_utils.dart';

/// 字幕数据处理类，解析字幕内容与时间
class IAppPlayerSubtitle {
  static const String timerSeparator = ' --> ';
  final int? index;
  final Duration? start;
  final Duration? end;
  final List<String>? texts;

  IAppPlayerSubtitle._({this.index, this.start, this.end, this.texts});

  /// 解析字幕字符串为对象
  factory IAppPlayerSubtitle(String value, bool isWebVTT) {
    try {
      final scanner = value.split('\n');
      if (scanner.length == 2) {
        return _handle2LinesSubtitles(scanner);
      }
      if (scanner.length > 2) {
        return _handle3LinesAndMoreSubtitles(scanner, isWebVTT);
      }
      return IAppPlayerSubtitle._();
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 创建已解析的字幕对象
  factory IAppPlayerSubtitle.create({
    required int index,
    required Duration start,
    required Duration end,
    required List<String> texts,
  }) {
    return IAppPlayerSubtitle._(
      index: index,
      start: start,
      end: end,
      texts: texts,
    );
  }

  /// 解析两行字幕格式
  static IAppPlayerSubtitle _handle2LinesSubtitles(List<String> scanner) {
    try {
      final timeSplit = scanner[0].split(timerSeparator);
      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      final texts = scanner.sublist(1, scanner.length);

      return IAppPlayerSubtitle._(index: -1, start: start, end: end, texts: texts);
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 解析三行及以上字幕格式
  static IAppPlayerSubtitle _handle3LinesAndMoreSubtitles(List<String> scanner, bool isWebVTT) {
    try {
      int? index = -1;
      List<String> timeSplit = [];
      int firstLineOfText = 0;
      if (scanner[0].contains(timerSeparator)) {
        timeSplit = scanner[0].split(timerSeparator);
        firstLineOfText = 1;
      } else {
        index = int.tryParse(scanner[0]);
        timeSplit = scanner[1].split(timerSeparator);
        firstLineOfText = 2;
      }

      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      final texts = scanner.sublist(firstLineOfText, scanner.length);
      return IAppPlayerSubtitle._(index: index, start: start, end: end, texts: texts);
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 将时间字符串转换为Duration
  static Duration _stringToDuration(String value) {
    try {
      final trimmedValue = value.trim();
      final componentValue = trimmedValue.contains(' ') ? trimmedValue.substring(0, trimmedValue.indexOf(' ')) : trimmedValue;
      final component = componentValue.split(':');

      if (component.length == 2) {
        component.insert(0, "00");
      } else if (component.length != 3) {
        return const Duration();
      }

      final secondsComponent = component[2];
      final int separatorIndex = secondsComponent.indexOf(',');
      final String secsStr;
      final String millisStr;

      if (separatorIndex != -1) {
        secsStr = secondsComponent.substring(0, separatorIndex);
        millisStr = secondsComponent.substring(separatorIndex + 1);
      } else {
        final dotIndex = secondsComponent.indexOf('.');
        if (dotIndex != -1) {
          secsStr = secondsComponent.substring(0, dotIndex);
          millisStr = secondsComponent.substring(dotIndex + 1);
        } else {
          return const Duration();
        }
      }

      final hours = int.tryParse(component[0]);
      final minutes = int.tryParse(component[1]);
      final seconds = int.tryParse(secsStr);
      final milliseconds = int.tryParse(millisStr);

      if (hours == null || minutes == null || seconds == null || milliseconds == null) {
        return const Duration();
      }

      return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds);
    } catch (exception) {
      return const Duration();
    }
  }

  @override
  String toString() {
    return 'IAppPlayerSubtitle{index: $index, start: $start, end: $end, texts: $texts}';
  }
}
