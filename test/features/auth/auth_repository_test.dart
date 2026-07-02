import 'package:flutter_test/flutter_test.dart';
import 'package:hmxcloud_app/features/auth/data/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    test('authRepositoryProvider is defined', () {
      expect(authRepositoryProvider, isNotNull);
    });
  });
}
