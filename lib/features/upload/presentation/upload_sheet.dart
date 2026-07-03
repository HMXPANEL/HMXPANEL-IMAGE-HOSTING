import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'upload_provider.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';

class UploadSheet extends ConsumerStatefulWidget {
  const UploadSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UploadSheet(),
    );
  }

  @override
  ConsumerState<UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<UploadSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadProvider);
    final cs = context.colorScheme;
    final g = context.glass;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(ResponsiveUtils.isSmall(context) ? 20 : 28),
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
            ),
            SizedBox(height: ResponsiveUtils.isSmall(context) ? 16 : 20),
            Text(
              'Upload Image',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: ResponsiveUtils.isSmall(context) ? 20 : 24),
            if (state.selectedFile != null)
              _buildPreview(context, cs, g, state)
            else
              _buildDropZone(context, cs, g, state),
            if (state.lastUpload != null) ...[
              const SizedBox(height: 16),
              _buildUploadComplete(context, cs, state),
            ],
            SizedBox(height: ResponsiveUtils.isSmall(context) ? 8 : 16),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDropZone(BuildContext context, ColorScheme cs, GlassThemeExtension g, UploadState state) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.isSmall(context) ? 36 : 56,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              g.glassSurfaceVariant.withAlpha(180),
              g.glassSurface.withAlpha(120),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: g.glassBorder, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: context.aurora.accentGlow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.aurora.electricBlue.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Drop image here or tap to browse',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG, WebP • Max 10 MB',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ).animate().shake(duration: 800.ms).then().shimmer(
          duration: 3000.ms,
          color: Colors.white.withAlpha(20),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPreview(BuildContext context, ColorScheme cs, GlassThemeExtension g, UploadState state) {
    final file = state.selectedFile!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                file,
                width: double.infinity,
                height: ResponsiveUtils.isSmall(context) ? 220 : 300,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => ref.read(uploadProvider.notifier).clearSelection(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            if (state.isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: state.uploadProgress,
                            strokeWidth: 4,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(state.uploadProgress * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.image_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(file.name, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            const Spacer(),
            Icon(Icons.storage_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              Formatters.bytes(file.lengthSync()),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Remove',
                onPressed: () => ref.read(uploadProvider.notifier).clearSelection(),
                expanded: true,
                fontSize: 14,
                gradient: LinearGradient(
                  colors: [g.glassSurfaceVariant, g.glassSurfaceVariant],
                ),
                foregroundColor: cs.onSurface,
                borderColor: g.glassBorder,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GlassButton(
                label: state.isUploading
                    ? 'Uploading... ${(state.uploadProgress * 100).round()}%'
                    : 'Upload Image',
                icon: state.isUploading ? null : Icons.cloud_upload_outlined,
                onPressed: state.isUploading
                    ? null
                    : () => ref.read(uploadProvider.notifier).uploadImage(),
                loading: state.isUploading,
                expanded: true,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadComplete(BuildContext context, ColorScheme cs, UploadState state) {
    final upload = state.lastUpload!;
    return GlassCard(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF10B981).withAlpha(15),
          const Color(0xFF10B981).withAlpha(5),
        ],
      ),
      borderColor: const Color(0xFF10B981).withAlpha(40),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Complete!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
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
                icon: Icon(Icons.copy_rounded, color: cs.onSurfaceVariant, size: 20),
                onPressed: () => GlassSnackBar.show(context, 'Link copied!', icon: Icons.check_circle_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    upload.url,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  expanded: true,
                  fontSize: 14,
                  gradient: LinearGradient(
                    colors: [g.glassSurfaceVariant, g.glassSurfaceVariant],
                  ),
                  foregroundColor: cs.onSurface,
                  borderColor: g.glassBorder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: 'Open URL',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () {},
                  expanded: true,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.95, end: 1.0);
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassCard(
        margin: EdgeInsets.zero,
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
            const SizedBox(height: 20),
            const Text(
              'Choose Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)]),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(uploadProvider.notifier).pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.folder_open_rounded,
                    label: 'Browse',
                    gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]),
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
    );
  }
}

class _SourceOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_SourceOption> createState() => _SourceOptionState();
}

class _SourceOptionState extends State<_SourceOption>
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
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: g.glassSurface,
            border: Border.all(color: g.glassBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}