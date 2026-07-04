class Upload {
  final String id;
  final String url;
  final String? displayUrl;
  final String? deleteUrl;
  final String fileName;
  final int size;
  final DateTime timestamp;
  final DateTime? expiration;

  const Upload({
    required this.id,
    required this.url,
    this.displayUrl,
    this.deleteUrl,
    required this.fileName,
    required this.size,
    required this.timestamp,
    this.expiration,
  });

  Upload copyWith({String? id}) {
    return Upload(
      id: id ?? this.id,
      url: url,
      displayUrl: displayUrl,
      deleteUrl: deleteUrl,
      fileName: fileName,
      size: size,
      timestamp: timestamp,
      expiration: expiration,
    );
  }

  Upload copyWithNewExpiration(DateTime? newExpiration) {
    return Upload(
      id: id,
      url: url,
      displayUrl: displayUrl,
      deleteUrl: deleteUrl,
      fileName: fileName,
      size: size,
      timestamp: timestamp,
      expiration: newExpiration,
    );
  }
}
