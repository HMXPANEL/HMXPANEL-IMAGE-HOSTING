import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../upload/presentation/upload_sheet.dart';
import '../../viewer/presentation/image_card.dart';
import '../../viewer/presentation/image_viewer_sheet.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/download_helper.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final bool _isGridView = true;
  String _searchQuery = '';
  int _selectedFilter = 0;
  final _searchCtrl = TextEditingController();
  final _filters = ['All', 'Recent', 'Images', 'Expiring'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadProvider);
    final cs = context.colorScheme;
    final g = context.glass;

    var filteredUploads = state.uploads;
    if (_searchQuery.isNotEmpty) {
      filteredUploads = filteredUploads
          .where((u) =>
              u.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_selectedFilter == 1) {
      filteredUploads = filteredUploads
          .where((u) =>
              DateTime.now().difference(u.timestamp).inDays < 1)
          .toList();
    } else if (_selectedFilter == 2) {
      filteredUploads = filteredUploads
          .where((u) =>
              u.fileName.endsWith('.jpg') ||
              u.fileName.endsWith('.png') ||
              u.fileName.endsWith('.webp'))
          .toList();
    } else if (_selectedFilter == 3) {
      filteredUploads = filteredUploads
          .where((u) => u.expiration != null && !u.expiration!.isExpired)
          .toList();
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.isSmall(context) ? 180 : 200,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            foregroundColor: cs.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.padding(context).left,
                  MediaQuery.of(context).padding.top + 60,
                  ResponsiveUtils.padding(context).right,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Manager',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filteredUploads.length} of ${state.uploads.length} items',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchBar(context, cs, g),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GlassChip(
                          label: _filters[i],
                          selected: _selectedFilter == i,
                          onTap: () => setState(() => _selectedFilter = i),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.padding(context).left,
              16,
              ResponsiveUtils.padding(context).right,
              ResponsiveUtils.padding(context).bottom + 120,
            ),
            sliver: state.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: GlassLoading(size: 40),
                    ),
                  )
                : filteredUploads.isEmpty
                    ? SliverFillRemaining(
                        child: GlassEmptyState(
                          icon: Icons.folder_open_rounded,
                          title: state.uploads.isEmpty
                              ? 'No files yet'
                              : 'No results found',
                          subtitle: state.uploads.isEmpty
                              ? 'Upload your first image'
                              : 'Try a different search or filter',
                          action: state.uploads.isEmpty
                              ? GlassButton(
                                  label: 'Upload Now',
                                  icon: Icons.cloud_upload_outlined,
                                  onPressed: () => UploadSheet.show(context),
                                  expanded: false,
                                )
                              : null,
                        ),
                      )
                    : _isGridView
                        ? SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveUtils.isLarge(context)
                                  ? 4
                                  : ResponsiveUtils.isMedium(context)
                                      ? 3
                                      : 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (_, index) {
                                final upload = filteredUploads[index];
                                return ImageCard(
                                  upload: upload,
                                  onTap: () => ImageViewerSheet.show(
                                    context,
                                    upload: upload,
                                    onDelete: () => ref
                                        .read(uploadProvider.notifier)
                                        .deleteUpload(upload.id),
                                  ),
                                  onDownload: () => GlassSnackBar.show(context, 'Download started'),
                                ).animate().fadeIn(
                                    duration: 300.ms,
                                    delay: (index * 50).ms);
                              },
                              childCount: filteredUploads.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, index) {
                                final upload = filteredUploads[index];
                                return _buildListTile(context, upload, ref, cs);
                              },
                              childCount: filteredUploads.length,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, ColorScheme cs, GlassThemeExtension g) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: g.glassShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: cs.onSurface, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search files...',
          hintStyle: TextStyle(color: cs.onSurfaceVariant.withAlpha(120)),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: g.glassSurface,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, upload, WidgetRef ref, ColorScheme cs) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: cs.surfaceContainerHighest,
              child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upload.fileName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.bytes(upload.size)} • ${Formatters.timeAgo(upload.timestamp)}',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant, size: 20),
            onPressed: () => _showContextMenu(context, upload, ref),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, upload, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContextMenuItem(
              icon: Icons.download_rounded,
              label: 'Download',
              onTap: () async {
                Navigator.pop(context);
                GlassSnackBar.show(context, 'Downloading...', icon: Icons.download_rounded);
                try {
                  await saveImageToGallery(upload.url);
                  if (context.mounted) {
                    GlassSnackBar.show(context, 'Saved to gallery', icon: Icons.check_circle_rounded);
                  }
                } catch (_) {
                  if (context.mounted) {
                    GlassSnackBar.show(context, 'Download failed', icon: Icons.error_outline_rounded);
                  }
                }
              },
            ),
            _ContextMenuItem(
              icon: Icons.link_rounded,
              label: 'Copy Link',
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: upload.url));
                GlassSnackBar.show(context, 'Link copied!', icon: Icons.check_circle_rounded);
              },
            ),
            _ContextMenuItem(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () {
                Navigator.pop(context);
                SharePlus.instance.share(
                  ShareParams(text: upload.url),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(uploadProvider.notifier).deleteUpload(upload.id);
                GlassSnackBar.show(context, 'Image deleted');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? cs.error : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? cs.error : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}