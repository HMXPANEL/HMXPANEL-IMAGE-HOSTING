import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../upload/domain/upload_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/glass_components.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageViewerSheet(upload: upload, onDelete: onDelete),
    );
  }

  @override
  State<ImageViewerSheet> createState() => _ImageViewerSheetState();
}

class _ImageViewerSheetState extends State<ImageViewerSheet> {
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final g = context.glass;
    final upload = widget.upload;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().fadeIn(duration: 200.ms),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black,
                child: CachedNetworkImage(
                  imageUrl: upload.displayUrl ?? upload.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.95, end: 1.0),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ViewerAction(icon: Icons.download_rounded, label: 'Save', onTap: () {
                  GlassSnackBar.show(context, 'Download started', icon: Icons.download_rounded);
                }),
                _ViewerAction(icon: Icons.link_rounded, label: 'Copy', onTap: () {
                  GlassSnackBar.show(context, 'Link copied!', icon: Icons.check_circle_rounded);
                }),
                _ViewerAction(icon: Icons.share_rounded, label: 'Share', onTap: () {
                  GlassSnackBar.show(context, 'Sharing...', icon: Icons.share_rounded);
                }),
                _ViewerAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete?.call();
                  },
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 16),
            GlassCard(
              gradient: g.glassSurfaceVariant,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _InfoRow(label: 'File Name', value: upload.fileName, cs: cs),
                  SizedBox(height: 6),
                  GlassDivider(),
                  SizedBox(height: 6),
                  _InfoRow(label: 'Upload Date', value: Formatters.dateTime(upload.timestamp), cs: cs),
                  SizedBox(height: 6),
                  GlassDivider(),
                  SizedBox(height: 6),
                  _InfoRow(label: 'File Size', value: Formatters.bytes(upload.size), cs: cs),
                  SizedBox(height: 6),
                  GlassDivider(),
                  SizedBox(height: 6),
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
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ViewerAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ViewerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_ViewerAction> createState() => _ViewerActionState();
}

class _ViewerActionState extends State<_ViewerAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 150.ms, vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
    final cs = context.colorScheme;
    final g = context.glass;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: g.glassSurfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: g.glassBorder, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: widget.isDestructive ? cs.error : cs.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isDestructive ? cs.error : cs.onSurfaceVariant,
                ),
              ),
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
        Text(
          label,
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
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