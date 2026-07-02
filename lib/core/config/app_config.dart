class AppConfig {
  AppConfig._();

  static const String appName = 'HmxCloud';
  static const String appVersion = '1.1.0';

  static const int maxFileSize = 10 * 1024 * 1024;
  static const int maxImageDimension = 1920;
  static const int imageQuality = 80;

  static const String imgbbUploadUrl = 'https://api.imgbb.com/1/upload';
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration cacheExpiry = Duration(hours: 1);
}
