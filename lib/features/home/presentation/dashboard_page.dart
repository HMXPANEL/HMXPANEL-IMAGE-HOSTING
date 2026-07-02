import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../upload/presentation/upload_provider.dart';
import '../../upload/presentation/upload_sheet.dart';
import '../../viewer/presentation/image_card.dart';
import '../../viewer/presentation/image_viewer_sheet.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/extensions.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadCards(context, ref),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(
                'Your Images',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Text(
                'Last uploads',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const ImageGridSkeleton()
          else if (state.uploads.isEmpty)
            const EmptyState(
              icon: Icons.image_outlined,
              title: 'No images yet',
              subtitle: 'Upload your first image',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: state.uploads.length,
              itemBuilder: (_, index) {
                final upload = state.uploads[index];
                return ImageCard(
                  upload: upload,
                  onTap: () => ImageViewerSheet.show(
                    context,
                    upload: upload,
                    onDelete: () => _confirmDelete(context, ref, upload.id),
                  ),
                  onDownload: () => context.showSnackBar('Download started'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUploadCards(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => UploadSheet.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHigh,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFE11D48)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => UploadSheet.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHigh,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.folder_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this image from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(uploadProvider.notifier).deleteUpload(id);
              Navigator.pop(context);
              context.showSnackBar('Image removed from history');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
