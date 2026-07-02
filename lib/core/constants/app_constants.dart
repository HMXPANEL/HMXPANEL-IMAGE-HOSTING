class AppConstants {
  AppConstants._();

  static const String appName = 'HmxCloud';
  static const String appVersion = '1.1.0';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';

  static const List<String> supportedServices = [
    'imgbb',
    'imgkit',
    'cloudinary',
    'imgur',
    'postimage',
    'custom',
  ];

  static const Map<String, String> serviceLabels = {
    'imgbb': 'ImgBB',
    'imgkit': 'ImgKit',
    'cloudinary': 'Cloudinary',
    'imgur': 'Imgur',
    'postimage': 'PostImage',
    'custom': 'Custom',
  };
}
