import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../upload/domain/upload_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_bottom_sheet.dart';

class ImageViewerSheet extends StatefulWidget {
  final Upload upload;
  final VoidCallback? onDelete;

  const ImageViewerSheet({
    super.key,
    required this.upload,
    this.onDelete,
  });

  static Future<void> show(BuildContext context, {
    required Upload upload,
    VoidCallback? onDelete,
  }) {
    return AppBottomSheet.show(
      context,
      title: '',
      child: ImageViewerSheet(upload: upload, onDelete: onDelete),
    );
  }

  @override
  State<ImageViewerSheet> createState() => _ImageViewerSheetState();
}

class _ImageViewerSheetState extends State<ImageViewerSheet> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final upload = widget.upload;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black,
              child: CachedNetworkImage(
                imageUrl: upload.displayUrl ?? upload.url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'Save',
                onTap: () => context.showSnackBar('Download started'),
              ),
              _ActionButton(
                icon: Icons.link_rounded,
                label: 'Copy',
                onTap: () {
                  // copy to clipboard
                  context.showSnackBar('Link copied!');
                },
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  // share
                  context.showSnackBar('Sharing...');
                },
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'File Name', value: upload.fileName, cs: cs),
                const SizedBox(height: 4),
                _InfoRow(
                  label: 'Upload Date',
                  value: Formatters.dateTime(upload.timestamp),
                  cs: cs,
                ),
                const SizedBox(height: 4),
                _InfoRow(label: 'File Size', value: Formatters.bytes(upload.size), cs: cs),
                const SizedBox(height: 4),
                _InfoRow(
                  label: 'Expires',
                  value: upload.expiration != null
                      ? Formatters.countdown(upload.expiration!)
                      : 'Never',
                  cs: cs,
                  isError: upload.expiration?.isExpired == true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final bool isError;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.cs,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isError ? cs.error : cs.onSurface,
          ),
        ),
      ],
    );
  }
}
