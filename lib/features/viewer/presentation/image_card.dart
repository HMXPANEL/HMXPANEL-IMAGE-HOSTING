import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../upload/domain/upload_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/glass_components.dart';

class ImageCard extends StatelessWidget {
  final Upload upload;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const ImageCard({
    super.key,
    required this.upload,
    required this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final g = context.glass;

    return GlassCard(
      padding: EdgeInsets.zero,
      gradient: g.glassSurface,
      onTap: onTap,
      animateOnAppear: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: upload.displayUrl ?? upload.url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upload.fileName,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.timeAgo(upload.timestamp),
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onDownload,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          size: 14,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (upload.expiration != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: upload.expiration!.isExpired
                          ? cs.error.withAlpha(15)
                          : Colors.amber.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 10,
                          color: upload.expiration!.isExpired ? cs.error : Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          upload.expiration!.isExpired ? 'Expired' : Formatters.countdown(upload.expiration!),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: upload.expiration!.isExpired ? cs.error : Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}