import 'package:flutter_test/flutter_test.dart';
import 'package:hmxcloud_app/features/upload/domain/upload_model.dart';

void main() {
  group('Upload model', () {
    test('creates Upload with correct values', () {
      final now = DateTime.now();
      final upload = Upload(
        id: 'test-id',
        url: 'https://example.com/image.jpg',
        fileName: 'image.jpg',
        size: 1024,
        timestamp: now,
      );

      expect(upload.id, 'test-id');
      expect(upload.url, 'https://example.com/image.jpg');
      expect(upload.fileName, 'image.jpg');
      expect(upload.size, 1024);
      expect(upload.timestamp, now);
      expect(upload.displayUrl, isNull);
      expect(upload.deleteUrl, isNull);
      expect(upload.expiration, isNull);
    });

    test('copyWith creates a new Upload with updated id', () {
      final upload = Upload(
        id: 'old-id',
        url: 'https://example.com/image.jpg',
        fileName: 'image.jpg',
        size: 1024,
        timestamp: DateTime.now(),
      );

      final updated = upload.copyWith(id: 'new-id');
      expect(updated.id, 'new-id');
      expect(updated.url, upload.url);
    });
  });
}
