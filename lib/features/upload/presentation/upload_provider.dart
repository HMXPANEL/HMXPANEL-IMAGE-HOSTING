import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../domain/upload_model.dart';
import '../domain/api_key_model.dart';
import '../data/upload_repository.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';

class UploadState {
  final bool isLoading;
  final bool isUploading;
  final double uploadProgress;
  final String? statusMessage;
  final File? selectedFile;
  final Upload? lastUpload;
  final String? error;
  final List<Upload> uploads;
  final List<ApiKey> apiKeys;

  const UploadState({
    this.isLoading = false,
    this.isUploading = false,
    this.uploadProgress = 0,
    this.statusMessage,
    this.selectedFile,
    this.lastUpload,
    this.error,
    this.uploads = const [],
    this.apiKeys = const [],
  });

  UploadState copyWith({
    bool? isLoading,
    bool? isUploading,
    double? uploadProgress,
    String? statusMessage,
    File? selectedFile,
    Upload? lastUpload,
    String? error,
    List<Upload>? uploads,
    List<ApiKey>? apiKeys,
    bool clearError = false,
    bool clearLastUpload = false,
    bool clearSelectedFile = false,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      statusMessage: statusMessage ?? this.statusMessage,
      selectedFile: clearSelectedFile ? null : (selectedFile ?? this.selectedFile),
      lastUpload: clearLastUpload ? null : (lastUpload ?? this.lastUpload),
      error: clearError ? null : (error ?? this.error),
      uploads: uploads ?? this.uploads,
      apiKeys: apiKeys ?? this.apiKeys,
    );
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final repository = ref.read(uploadRepositoryProvider);
  return UploadNotifier(repository);
});

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadRepository _repository;
  final ImagePicker _picker = ImagePicker();

  UploadNotifier(this._repository) : super(const UploadState()) {
    _watchUploads();
    _watchApiKeys();
  }

  void _watchUploads() {
    _repository.watchUploads().listen((uploads) {
      state = state.copyWith(uploads: uploads);
    });
  }

  void _watchApiKeys() {
    _repository.watchApiKeys().listen((keys) {
      state = state.copyWith(apiKeys: keys);
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: AppConfig.maxImageDimension.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );
      if (file != null) {
        state = state.copyWith(
          selectedFile: File(file.path),
          error: null,
          statusMessage: 'Image selected',
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image');
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${file.path}_compressed.jpg',
        quality: AppConfig.imageQuality,
        minWidth: AppConfig.maxImageDimension,
        minHeight: AppConfig.maxImageDimension,
      );
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Compression failed');
      return null;
    }
  }

  Future<void> uploadImage() async {
    final file = state.selectedFile;
    if (file == null) {
      state = state.copyWith(error: 'No image selected');
      return;
    }

    final compressed = await compressImage(file);
    final uploadFile = compressed ?? file;

    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      statusMessage: 'Uploading... 0%',
      error: null,
    );

    try {
      final bytes = await uploadFile.readAsBytes();
      final upload = await _repository.uploadImage(
        imageBytes: bytes,
        fileName: file.name,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final percent = (sent / total * 100).roundToDouble();
            state = state.copyWith(
              uploadProgress: percent / 100,
              statusMessage: 'Uploading... ${percent.round()}%',
            );
          }
        },
      );

      state = state.copyWith(
        isUploading: false,
        uploadProgress: 1.0,
        statusMessage: 'Upload complete!',
        lastUpload: upload,
        clearSelectedFile: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.message,
        statusMessage: 'Upload failed',
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Upload failed',
        statusMessage: 'Upload failed',
      );
    }
  }

  Future<void> deleteUpload(String id) async {
    try {
      await _repository.deleteUpload(id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete upload');
    }
  }

  Future<void> clearAllUploads() async {
    try {
      await _repository.clearAllUploads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear uploads');
    }
  }

  Future<void> addApiKey({
    required String service,
    required String name,
    required String key,
    String? description,
    required bool active,
  }) async {
    try {
      final apiKey = ApiKey(
        id: '',
        service: service,
        name: name,
        key: key,
        description: description,
        active: active,
        createdAt: DateTime.now(),
      );
      await _repository.addApiKey(apiKey);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add API key');
    }
  }

  Future<void> updateApiKey(ApiKey key) async {
    try {
      await _repository.updateApiKey(key);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update API key');
    }
  }

  Future<void> deleteApiKey(String id) async {
    try {
      await _repository.deleteApiKey(id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete API key');
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedFile: true, error: null, statusMessage: null);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearLastUpload() {
    state = state.copyWith(clearLastUpload: true);
  }
}

extension on File {
  String get name => path.split('/').last;
}
