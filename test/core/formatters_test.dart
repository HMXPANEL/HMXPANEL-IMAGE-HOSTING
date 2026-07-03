import 'package:flutter_test/flutter_test.dart';
import 'package:hmxcloud_app/core/utils/formatters.dart';

void main() {
  group('Formatters.bytes', () {
    test('formats 0 bytes', () {
      expect(Formatters.bytes(0), '0 B');
    });

    test('formats bytes to KB', () {
      expect(Formatters.bytes(1024), contains('KB'));
    });

    test('formats bytes to MB', () {
      expect(Formatters.bytes(1048576), contains('MB'));
    });
  });

  group('Formatters.maskApiKey', () {
    test('masks long key showing last 4 chars', () {
      final result = Formatters.maskApiKey('abcdefghijkl');
      expect(result, '••••••••hijkl');
    });

    test('masks entirely for short key', () {
      expect(Formatters.maskApiKey('1234'), '••••••••');
    });
  });

}
