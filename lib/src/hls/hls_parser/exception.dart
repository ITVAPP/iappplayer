/// 解析异常基类
class ParserException implements Exception {
  ParserException(this.message);

  /// 异常信息
  final String message;

  @override
  String toString() => 'ParserException: $message';
}

/// 无法识别的输入格式异常
class UnrecognizedInputFormatException extends ParserException {
  UnrecognizedInputFormatException(String message, this.uri) : super(message);

  /// 关联的URI
  final Uri? uri;
}
