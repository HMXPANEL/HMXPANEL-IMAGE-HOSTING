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
    final isSmall = context.isSmall;

    return RepaintBoundary(
      child: GlassCard(
        padding: EdgeInsets.zero,
        gradient: g.glassSurface,
        onTap: onTap,
        animateOnAppear: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1.18,
                child: Hero(
                  tag: 'image_${upload.id}',
                  child: CachedNetworkImage(
                    imageUrl: upload.displayUrl ?? upload.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
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
            ),
            Padding(
              padding: EdgeInsets.all(isSmall ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    upload.fileName,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmall ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 10, color: cs.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                Formatters.timeAgo(upload.timestamp),
                                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onDownload != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onDownload,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              size: 10,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (upload.expiration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: upload.expiration!.isExpired
                              ? cs.error.withAlpha(15)
                              : Colors.amber.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 8,
                              color: upload.expiration!.isExpired ? cs.error : Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                upload.expiration!.isExpired ? 'Expired' : Formatters.countdown(upload.expiration!),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: upload.expiration!.isExpired ? cs.error : Colors.amber.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
