import 'package:flutter_test/flutter_test.dart';
import 'package:hmxcloud_app/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('returns error for empty email', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@sub.example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns null for valid password', () {
      expect(Validators.password('password123'), isNull);
    });

    test('returns error for empty password', () {
      expect(Validators.password(''), isNotNull);
    });

    test('returns error for short password', () {
      expect(Validators.password('12345'), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('password', 'password'), isNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('password1', 'password2'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('returns null for valid name', () {
      expect(Validators.name('John Doe'), isNull);
    });

    test('returns error for empty name', () {
      expect(Validators.name(''), isNotNull);
    });

    test('returns error for short name', () {
      expect(Validators.name('A'), isNotNull);
    });
  });

  group('Validators.apiKeyName', () {
    test('returns null for valid key name', () {
      expect(Validators.apiKeyName('My Key'), isNull);
    });

    test('returns error for empty key name', () {
      expect(Validators.apiKeyName(''), isNotNull);
    });
  });

  group('Validators.apiKeyValue', () {
    test('returns null for valid key value', () {
      expect(Validators.apiKeyValue('abc12345'), isNull);
    });

    test('returns error for empty key', () {
      expect(Validators.apiKeyValue(''), isNotNull);
    });

    test('returns error for very short key', () {
      expect(Validators.apiKeyValue('ab'), isNotNull);
    });
  });
}
