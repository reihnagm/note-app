import 'dart:math';

class NanoID {
  static const String _alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_';
  static const int _defaultSize = 21;

  static String generate([int size = _defaultSize]) {
    final random = Random.secure();
    final buffer = StringBuffer();
    
    for (var i = 0; i < size; i++) {
      buffer.write(_alphabet[random.nextInt(_alphabet.length)]);
    }

    return buffer.toString();
  }
}