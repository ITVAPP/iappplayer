import 'dart:convert';
import 'dart:typed_data';

/// ClearKey辅助类，用于生成密钥
class IAppPlayerClearKeyUtils {
  /// 字节掩码
  static final _byteMask = BigInt.from(0xff);

  /// 根据键值对生成ClearKey，键值需为HEX格式
  static String generateKey(Map<String, String> keys,
      {String type = "temporary"}) {
    final Map keyMap = <String, dynamic>{"type": type};
    keyMap["keys"] = <Map<String, String>>[];
    keys.forEach((key, value) => keyMap["keys"]
        .add({"kty": "oct", "kid": _base64(key), "k": _base64(value)}));

    return jsonEncode(keyMap);
  }

  /// 将HEX字符串转换为Base64
  static String _base64(String source) {
    return base64
        .encode(_encodeBigInt(BigInt.parse(source, radix: 16)))
        .replaceAll("=", "");
  }

  /// 将大整数编码为字节数组
  static Uint8List _encodeBigInt(BigInt number) {
    var passedNumber = number;
    final int size = (number.bitLength + 7) >> 3;

    final result = Uint8List(size);
    int pos = size - 1;
    for (int i = 0; i < size; i++) {
      result[pos--] = (passedNumber & _byteMask).toInt();
      passedNumber = passedNumber >> 8;
    }
    return result;
  }
}
