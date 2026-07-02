import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'upload_provider.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/extensions.dart';

class UploadSheet extends ConsumerStatefulWidget {
  const UploadSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      title: 'Upload Image',
      child: const UploadSheet(),
    );
  }

  @override
  ConsumerState<UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<UploadSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.selectedFile != null)
            _buildPreview(context, cs, state)
          else
            _buildDropZone(context, cs, state),

          if (state.lastUpload != null) ...[
            const SizedBox(height: 16),
            _buildUploadComplete(context, cs, state),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, ColorScheme cs, UploadState state) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outlineVariant,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
          color: cs.surfaceContainerHighest.withAlpha(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Drop image here',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'or tap to browse',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, ColorScheme cs, UploadState state) {
    final file = state.selectedFile!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () => ref.read(uploadProvider.notifier).clearSelection(),
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Original: ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            Text(
              Formatters.bytes(file.lengthSync()),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const Spacer(),
            Text('Compressed: ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            Text(
              Formatters.bytes(file.lengthSync()),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
        if (state.isUploading) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.uploadProgress,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.statusMessage ?? '',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.isUploading
                ? null
                : () => ref.read(uploadProvider.notifier).uploadImage(),
            icon: state.isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(state.isUploading ? 'Uploading...' : 'Upload Image'),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadComplete(BuildContext context, ColorScheme cs, UploadState state) {
    final upload = state.lastUpload!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            upload.displayUrl ?? upload.url,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: cs.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Direct Link', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    upload.url,
                    style: TextStyle(color: cs.onSurface, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => context.showSnackBar('Copied!'),
              icon: const Icon(Icons.copy, size: 20),
            ),
          ],
        ),
        if (upload.deleteUrl != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete Link', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      upload.deleteUrl!,
                      style: TextStyle(color: cs.onSurface, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => context.showSnackBar('Copied!'),
                icon: const Icon(Icons.copy, size: 20),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Uploaded ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            Text(Formatters.date(upload.timestamp), style: TextStyle(color: cs.onSurface, fontSize: 12)),
            const Spacer(),
            Text('Expires ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            Text(
              upload.expiration != null ? Formatters.countdown(upload.expiration!) : 'Never',
              style: TextStyle(
                color: upload.expiration?.isExpired == true ? cs.error : cs.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {/* open URL */},
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Choose Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(uploadProvider.notifier).pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.folder_outlined,
                      label: 'Browse',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(uploadProvider.notifier).pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surfaceContainerHighest.withAlpha(80),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: label == 'Camera'
                      ? const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)])
                      : const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
