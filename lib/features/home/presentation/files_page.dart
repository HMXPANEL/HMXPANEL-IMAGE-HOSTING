import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../upload/presentation/upload_sheet.dart';
import '../../viewer/presentation/image_card.dart';
import '../../viewer/presentation/image_viewer_sheet.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
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
    final rv = context.rv;

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
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: context.isSmall ? 240 : 260,
            collapsedHeight: context.isSmall ? 100 : 110,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            foregroundColor: cs.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  rv.horizontalEdge.left,
                  MediaQuery.of(context).padding.top + (context.isSmall ? 40 : 60),
                  rv.horizontalEdge.right,
                  AppSpacing.md,
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
              rv.horizontalEdge.left,
              AppSpacing.md,
              rv.horizontalEdge.right,
              rv.bottomNavHeight,
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
                    : SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rv.gridColumns,
                          crossAxisSpacing: rv.gridSpacing,
                          mainAxisSpacing: rv.gridSpacing,
                          childAspectRatio: rv.imageCardAspectRatio,
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

}