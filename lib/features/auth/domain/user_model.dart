import 'package:firebase_auth/firebase_auth.dart' as fb;

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.createdAt,
  });

  factory AppUser.fromFirebase(fb.User? user) {
    if (user == null) {
      throw Exception('User is null');
    }
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? user.email?.split('@').first,
      createdAt: user.metadata.creationTime,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
