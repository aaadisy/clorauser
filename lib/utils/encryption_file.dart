import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

const String secretKey = "ADD_RENDOM_SECRET_KEY_HERE";
const String ivKey = "ADD_RENDOM_IV_KEY_HERE";

class Encryption {
  static final Encryption instance = Encryption.init();

  late IV _iv;
  late Encrypter _encryption;

  Encryption.init() {
    final keyUtf8 = utf8.encode(secretKey);
    final ivUtf8 = utf8.encode(ivKey);
    final key = sha256.convert(keyUtf8).toString().substring(0, 32);
    final iv = sha256.convert(ivUtf8).toString().substring(0, 16);
    _iv = IV.fromUtf8(iv);
    _encryption = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  }

  /// this function encrypt data
  String encrypt(String value) {
    return _encryption.encrypt(value, iv: _iv).base64;
  }

  /// decrypt data
  String decrypt(String base64value) {
    final encrypted = Encrypted.fromBase64(base64value);
    return _encryption.decrypt(encrypted, iv: _iv);
  }
}
