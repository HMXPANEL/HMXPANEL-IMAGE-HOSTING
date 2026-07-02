import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../viewer/presentation/image_card.dart';
import '../../viewer/presentation/image_viewer_sheet.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/extensions.dart';

class FilesPage extends ConsumerWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'File Manager',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (state.uploads.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClearAll(context, ref),
              icon: Icon(Icons.delete_sweep_outlined, color: cs.onSurfaceVariant),
            ),
        ],
      ),
      body: _buildBody(context, cs, state, ref),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme cs, UploadState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ImageGridSkeleton(),
      );
    }

    if (state.uploads.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_outlined,
        title: 'No files yet',
        subtitle: 'Upload your first image to see it here',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                '${state.uploads.length} items',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
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
                  onDelete: () => ref.read(uploadProvider.notifier).deleteUpload(upload.id),
                ),
                onDownload: () => context.showSnackBar('Download started'),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Files'),
        content: const Text('Are you sure you want to delete all uploads?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(uploadProvider.notifier).clearAllUploads();
              Navigator.pop(context);
              context.showSnackBar('All uploads cleared');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
