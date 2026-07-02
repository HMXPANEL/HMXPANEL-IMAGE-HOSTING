import 'package:flutter_test/flutter_test.dart';
import 'package:hmxcloud_app/features/upload/domain/api_key_model.dart';

void main() {
  group('ApiKey model', () {
    test('creates ApiKey with correct values', () {
      final now = DateTime.now();
      final key = ApiKey(
        id: 'key-id',
        service: 'imgbb',
        name: 'My Key',
        key: 'abc123key',
        active: true,
        createdAt: now,
      );

      expect(key.id, 'key-id');
      expect(key.service, 'imgbb');
      expect(key.name, 'My Key');
      expect(key.key, 'abc123key');
      expect(key.active, isTrue);
      expect(key.createdAt, now);
      expect(key.description, isNull);
    });

    test('copyWith creates a new ApiKey with overridden values', () {
      final key = ApiKey(
        id: 'key-id',
        service: 'imgbb',
        name: 'My Key',
        key: 'abc123key',
        active: false,
        createdAt: DateTime.now(),
      );

      final updated = key.copyWith(active: true);
      expect(updated.active, isTrue);
      expect(updated.id, key.id);
      expect(updated.name, key.name);
    });
  });
}
