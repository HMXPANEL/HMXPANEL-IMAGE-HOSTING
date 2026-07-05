import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String bytes(int bytes) {
    if (bytes == 0) return '0 B';
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength / 10).floor().clamp(0, sizes.length - 1);
    final value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(1)} ${sizes[i]}';
  }

  static String dateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String maskApiKey(String key) {
    if (key.length <= 8) return '••••••••';
    return '••••••••${key.substring(key.length - 4)}';
  }

  static String countdown(DateTime expiration) {
    final remaining = expiration.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m';
    }
    return '${remaining.inHours}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s';
  }
}
