import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IAppPlayerUtils {
  // 缓存发布模式标志
  static final bool _isReleaseMode = kReleaseMode;
  
  // 格式化比特率为 bit/s、KBit/s 或 MBit/s 单位
  static String formatBitrate(int bitrate) {
    if (bitrate < 1000) {
      return "$bitrate bit/s";
    }
    if (bitrate < 1000000) {
      final kbit = (bitrate / 1000).floor();
      return "~$kbit KBit/s";
    }
    final mbit = (bitrate / 1000000).floor();
    return "~$mbit MBit/s";
  }
  
  // 格式化时长为 HH:MM:SS 格式
  // 使用 StringBuffer 优化字符串拼接
  static String formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    final minutes = seconds ~/ 60;
    seconds = seconds % 60;
    
    final buffer = StringBuffer();
    
    // 小时部分
    if (hours > 0) {
      if (hours < 10) buffer.write('0');
      buffer.write('$hours:');
    }
    
    // 分钟部分
    if (minutes < 10) buffer.write('0');
    buffer.write('$minutes:');
    
    // 秒部分
    if (seconds < 10) buffer.write('0');
    buffer.write('$seconds');
    
    return buffer.toString();
  }
  
  // 计算屏幕宽高比，返回较大值除以较小值的比例
  static double calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return width > height ? width / height : height / width;
  }
  
  // 记录调试日志，仅在非发布模式下打印
  static void log(String logMessage) {
    return; // 禁用日志，需要时注释此行
    // 缓存发布模式标志
    if (!_isReleaseMode) {
      // ignore: avoid_print
      print(logMessage);
    }
  }
}
