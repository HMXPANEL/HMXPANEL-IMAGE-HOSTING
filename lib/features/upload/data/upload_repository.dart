import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/upload_model.dart';
import '../domain/api_key_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository();
});

class UploadRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DioClient _dio;

  UploadRepository()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance,
        _dio = DioClient();

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _uploadsRef =>
      _firestore.collection('users').doc(_userId).collection('uploads');

  CollectionReference get _apiKeysRef =>
      _firestore.collection('users').doc(_userId).collection('apiKeys');

  Stream<List<Upload>> watchUploads() {
    return _uploadsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Upload(
          id: doc.id,
          url: data['url'] as String? ?? '',
          displayUrl: data['displayUrl'] as String?,
          deleteUrl: data['deleteUrl'] as String?,
          fileName: data['fileName'] as String? ?? 'Unknown',
          size: data['size'] as int? ?? 0,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          expiration: (data['expiration'] as Timestamp?)?.toDate(),
        );
      }).toList();
    });
  }

  Stream<List<ApiKey>> watchApiKeys() {
    return _apiKeysRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ApiKey(
          id: doc.id,
          service: data['service'] as String? ?? 'custom',
          name: data['name'] as String? ?? '',
          key: data['key'] as String? ?? '',
          description: data['description'] as String?,
          active: data['active'] as bool? ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  Future<ApiKey?> getActiveApiKey() async {
    final snapshot = await _apiKeysRef.where('active', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    return ApiKey(
      id: doc.id,
      service: data['service'] as String? ?? 'custom',
      name: data['name'] as String? ?? '',
      key: data['key'] as String? ?? '',
      description: data['description'] as String?,
      active: data['active'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> addApiKey(ApiKey key) async {
    if (key.active) {
      await _deactivateAllKeys();
    }
    await _apiKeysRef.add({
      'service': key.service,
      'name': key.name,
      'key': key.key,
      'description': key.description,
      'active': key.active,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateApiKey(ApiKey key) async {
    if (key.active) {
      await _deactivateAllKeys();
    }
    await _apiKeysRef.doc(key.id).update({
      'service': key.service,
      'name': key.name,
      'key': key.key,
      'description': key.description,
      'active': key.active,
    });
  }

  Future<void> deleteApiKey(String id) async {
    await _apiKeysRef.doc(id).delete();
  }

  Future<void> _deactivateAllKeys() async {
    final snapshot = await _apiKeysRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({'active': false});
    }
  }

  Future<Upload> uploadImage({
    required List<int> imageBytes,
    required String fileName,
    required void Function(int, int)? onSendProgress,
  }) async {
    final activeKey = await getActiveApiKey();
    if (activeKey == null) {
      throw UploadException('Please add and activate an API key');
    }

    try {
      final base64 = _encodeBase64(imageBytes);
      final formData = FormData.fromMap({
        'image': base64,
      });

      String apiUrl = '${AppConfig.imgbbUploadUrl}?key=${activeKey.key}';

      final response = await _dio.postFormData(
        apiUrl,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          sendTimeout: AppConfig.uploadTimeout,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw UploadException(body['error']?['message'] ?? 'Upload failed');
      }

      final data = body['data'] as Map<String, dynamic>;
      final upload = Upload(
        id: '',
        url: data['url'] as String? ?? '',
        displayUrl: data['display_url'] as String?,
        deleteUrl: data['delete_url'] as String?,
        fileName: fileName,
        size: imageBytes.length,
        timestamp: DateTime.now(),
        expiration: data['expiration'] != null
            ? DateTime.now().add(Duration(seconds: int.parse(data['expiration'].toString())))
            : null,
      );

      final docRef = await _uploadsRef.add(_uploadToFirestore(upload));
      return upload.copyWith(id: docRef.id);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UploadException('Upload failed: $e');
    }
  }

  Future<void> updateUploadExpiration(String id, DateTime expiration) async {
    await _uploadsRef.doc(id).update({
      'expiration': Timestamp.fromDate(expiration),
    });
  }

  Future<void> deleteUpload(String id) async {
    await _uploadsRef.doc(id).delete();
  }

  Future<void> clearAllUploads() async {
    final snapshot = await _uploadsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  String _encodeBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  Map<String, dynamic> _uploadToFirestore(Upload upload) {
    return {
      'url': upload.url,
      'displayUrl': upload.displayUrl,
      'deleteUrl': upload.deleteUrl,
      'fileName': upload.fileName,
      'size': upload.size,
      'timestamp': Timestamp.fromDate(upload.timestamp),
      if (upload.expiration != null)
        'expiration': Timestamp.fromDate(upload.expiration!),
    };
  }
}
