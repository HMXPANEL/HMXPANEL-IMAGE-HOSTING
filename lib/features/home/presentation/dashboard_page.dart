import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../upload/presentation/upload_provider.dart';
import '../../upload/presentation/upload_sheet.dart';
import '../../viewer/presentation/image_card.dart';
import '../../viewer/presentation/image_viewer_sheet.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final g = context.glass;
    final a = context.aurora;
    final cs = context.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.padding(context).left,
        MediaQuery.of(context).padding.top + 80,
        ResponsiveUtils.padding(context).right,
        ResponsiveUtils.padding(context).bottom + 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context, cs, state),
          SizedBox(height: ResponsiveUtils.isSmall(context) ? 20 : 28),
          _buildStatsRow(context, state),
          SizedBox(height: ResponsiveUtils.isSmall(context) ? 20 : 28),
          _buildQuickUpload(context),
          SizedBox(height: ResponsiveUtils.isSmall(context) ? 24 : 32),
          _buildRecentActivitySection(context, cs, state, ref),
          SizedBox(height: 24),
          _buildStorageSection(context, state),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ColorScheme cs, UploadState state) {
    final user = state.uploads.isNotEmpty ? 'Welcome back!' : 'Welcome!';
    final count = state.uploads.length;

    return GlassCard(
      gradient: LinearGradient(
        colors: [
          cs.surface.withAlpha(200),
          cs.surface.withAlpha(180),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: EdgeInsets.all(ResponsiveUtils.isSmall(context) ? 20 : 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count > 0
                      ? '$count image${count != 1 ? 's' : ''} uploaded'
                      : 'Start hosting your images for free',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  label: 'Upload Now',
                  icon: Icons.cloud_upload_outlined,
                  onPressed: null,
                  expanded: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ],
            ),
          ),
          _buildCloudIllustration(context),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.02, end: 0);
  }

  Widget _buildCloudIllustration(BuildContext context) {
    final a = context.aurora;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: a.primaryAurora,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: a.electricBlue.withAlpha(50),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.cloud_rounded,
          size: 48,
          color: Colors.white.withAlpha(220),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scaleXY(begin: 0.8, end: 1.0).then()
      .shimmer(duration: 2000.ms, color: Colors.white.withAlpha(40));
  }

  Widget _buildStatsRow(BuildContext context, UploadState state) {
    final isSmall = ResponsiveUtils.isSmall(context);
    final uploadCount = state.uploads.length;
    final totalSize = state.uploads.fold<int>(0, (sum, u) => sum + u.size);
    final apiKeyCount = state.apiKeys.length;
    final avgSize = uploadCount > 0 ? totalSize ~/ uploadCount : 0;

    return ResponsiveWidget(
      small: (_) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassStatCard(
                  label: 'Total Uploads',
                  value: '$uploadCount',
                  icon: Icons.cloud_done_rounded,
                  gradient: context.aurora.primaryAurora,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassStatCard(
                  label: 'Storage Used',
                  value: Formatters.bytes(totalSize),
                  icon: Icons.storage_rounded,
                  gradient: context.aurora.secondaryAurora,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassStatCard(
                  label: 'Avg. File Size',
                  value: Formatters.bytes(avgSize),
                  icon: Icons.bar_chart_rounded,
                  gradient: context.aurora.tertiaryAurora,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassStatCard(
                  label: 'API Keys',
                  value: '$apiKeyCount',
                  icon: Icons.key_rounded,
                  gradient: LinearGradient(
                    colors: [context.aurora.electricBlue, context.aurora.electricCyan],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      medium: (_) => Row(
        children: [
          Expanded(
            child: GlassStatCard(
              label: 'Total Uploads', value: '$uploadCount',
              icon: Icons.cloud_done_rounded,
              gradient: context.aurora.primaryAurora,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassStatCard(
              label: 'Storage Used', value: Formatters.bytes(totalSize),
              icon: Icons.storage_rounded,
              gradient: context.aurora.secondaryAurora,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassStatCard(
              label: 'Avg. File Size', value: Formatters.bytes(avgSize),
              icon: Icons.bar_chart_rounded,
              gradient: context.aurora.tertiaryAurora,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassStatCard(
              label: 'API Keys', value: '$apiKeyCount',
              icon: Icons.key_rounded,
              gradient: LinearGradient(
                colors: [context.aurora.electricBlue, context.aurora.electricCyan],
              ),
            ),
          ),
        ],
      ),
      large: (_) => Row(
        children: [
          Expanded(child: GlassStatCard(label: 'Total Uploads', value: '$uploadCount', icon: Icons.cloud_done_rounded, gradient: context.aurora.primaryAurora)),
          const SizedBox(width: 16),
          Expanded(child: GlassStatCard(label: 'Storage Used', value: Formatters.bytes(totalSize), icon: Icons.storage_rounded, gradient: context.aurora.secondaryAurora)),
          const SizedBox(width: 16),
          Expanded(child: GlassStatCard(label: 'Avg. File Size', value: Formatters.bytes(avgSize), icon: Icons.bar_chart_rounded, gradient: context.aurora.tertiaryAurora)),
          const SizedBox(width: 16),
          Expanded(child: GlassStatCard(label: 'API Keys', value: '$apiKeyCount', icon: Icons.key_rounded, gradient: LinearGradient(colors: [context.aurora.electricBlue, context.aurora.electricCyan]))),
        ],
      ),
    );
  }

  Widget _buildQuickUpload(BuildContext context) {
    final a = context.aurora;
    return GlassSection(
      title: 'Quick Upload',
      subtitle: 'Choose a source',
      trailing: GlassBadge(label: 'Free', color: const Color(0xFF10B981)),
      child: ResponsiveWidget(
        small: (_) => Row(
          children: [
            Expanded(child: _QuickUploadTile(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)]),
              onTap: null,
            )),
            const SizedBox(width: 12),
            Expanded(child: _QuickUploadTile(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]),
              onTap: null,
            )),
            const SizedBox(width: 12),
            Expanded(child: _QuickUploadTile(
              icon: Icons.folder_open_rounded,
              label: 'Browse',
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
              onTap: null,
            )),
          ],
        ),
        medium: (_) => Row(
          children: [
            Expanded(child: _QuickUploadTile(icon: Icons.camera_alt_rounded, label: 'Camera', gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)]), onTap: null)),
            const SizedBox(width: 16),
            Expanded(child: _QuickUploadTile(icon: Icons.photo_library_rounded, label: 'Gallery', gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]), onTap: null)),
            const SizedBox(width: 16),
            Expanded(child: _QuickUploadTile(icon: Icons.folder_open_rounded, label: 'Browse', gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]), onTap: null)),
          ],
        ),
        large: (_) => Row(
          children: [
            Expanded(child: _QuickUploadTile(icon: Icons.camera_alt_rounded, label: 'Camera', gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)]), onTap: null)),
            const SizedBox(width: 16),
            Expanded(child: _QuickUploadTile(icon: Icons.photo_library_rounded, label: 'Gallery', gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]), onTap: null)),
            const SizedBox(width: 16),
            Expanded(child: _QuickUploadTile(icon: Icons.folder_open_rounded, label: 'Browse', gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]), onTap: null)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildRecentActivitySection(
      BuildContext context, ColorScheme cs, UploadState state, WidgetRef ref) {
    final recent = state.uploads.take(6).toList();

    return GlassSection(
      title: 'Recent Activity',
      subtitle: '${state.uploads.length} total images',
      trailing: state.uploads.isNotEmpty
          ? GlassChip(
              label: 'View All',
              icon: Icons.arrow_forward_rounded,
              onTap: null,
            )
          : null,
      child: state.isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : recent.isEmpty
              ? GlassEmptyState(
                  icon: Icons.image_outlined,
                  title: 'No images yet',
                  subtitle: 'Upload your first image to get started',
                  action: GlassButton(
                    label: 'Upload Now',
                    icon: Icons.cloud_upload_outlined,
                    onPressed: null,
                    expanded: false,
                  ),
                )
              : AdaptiveGrid(
                  itemCount: recent.length,
                  itemBuilder: (_, index) {
                    final upload = recent[index];
                    return ImageCard(
                      upload: upload,
                      onTap: () => ImageViewerSheet.show(
                        context,
                        upload: upload,
                        onDelete: () =>
                            ref.read(uploadProvider.notifier).deleteUpload(upload.id),
                      ),
                      onDownload: () =>
                          GlassSnackBar.show(context, 'Download started'),
                    );
                  },
                  spacing: 12,
                ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildStorageSection(BuildContext context, UploadState state) {
    final totalSize = state.uploads.fold<int>(0, (sum, u) => sum + u.size);
    final percent = totalSize > 0 ? (totalSize / (100 * 1024 * 1024)).clamp(0.0, 1.0) : 0.0;

    return GlassSection(
      title: 'Storage Analytics',
      subtitle: '${(percent * 100).round()}% of 100 MB used',
      trailing: GlassBadge(
        label: '${(percent * 100).round()}%',
        color: percent > 0.8
            ? context.colorScheme.error
            : percent > 0.5
                ? Colors.amber
                : context.aurora.electricBlue,
      ),
      child: Column(
        children: [
          GlassProgressBar(value: percent, height: 10),
          const SizedBox(height: 16),
          Row(
            children: [
              _StorageStat(label: 'Images', value: '${state.uploads.length}', icon: Icons.image_rounded),
              _StorageStat(label: 'Used', value: Formatters.bytes(totalSize), icon: Icons.database_rounded),
              _StorageStat(label: 'Remaining', value: '${(100 * 1024 * 1024 - totalSize) > 0 ? Formatters.bytes((100 * 1024 * 1024 - totalSize).clamp(0, 100 * 1024 * 1024)) : '0 B'}', icon: Icons.space_dashboard_rounded),
            ],
          ),
          const SizedBox(height: 8),
          GlassDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: context.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Free tier includes up to 100 MB storage',
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }
}

class _QuickUploadTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _QuickUploadTile({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });

  @override
  State<_QuickUploadTile> createState() => _QuickUploadTileState();
}

class _QuickUploadTileState extends State<_QuickUploadTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 150.ms, vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: GlassCard(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.isSmall(context) ? 24 : 28,
          ),
          gradient: g.glassSurface,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.9, end: 1.0);
  }
}

class _StorageStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StorageStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}