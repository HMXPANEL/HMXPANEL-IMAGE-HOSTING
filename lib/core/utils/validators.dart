import '../errors/exceptions.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name too short';
    }
    return null;
  }

  static String? apiKeyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? apiKeyValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'API Key is required';
    }
    if (value.trim().length < 4) {
      return 'Invalid API Key';
    }
    return null;
  }

  static void validateOrThrow({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? apiKeyName,
    String? apiKeyValue,
  }) {
    if (email != null) {
      final err = Validators.email(email);
      if (err != null) throw ValidationException(err);
    }
    if (password != null) {
      final err = Validators.password(password);
      if (err != null) throw ValidationException(err);
    }
    if (confirmPassword != null && password != null) {
      final err = Validators.confirmPassword(confirmPassword, password);
      if (err != null) throw ValidationException(err);
    }
    if (name != null) {
      final err = Validators.name(name);
      if (err != null) throw ValidationException(err);
    }
    if (apiKeyName != null) {
      final err = Validators.apiKeyName(apiKeyName);
      if (err != null) throw ValidationException(err);
    }
    if (apiKeyValue != null) {
      final err = Validators.apiKeyValue(apiKeyValue);
      if (err != null) throw ValidationException(err);
    }
  }
}
