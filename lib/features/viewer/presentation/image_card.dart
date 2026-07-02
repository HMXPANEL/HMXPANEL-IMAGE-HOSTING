import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../upload/domain/upload_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/extensions.dart';

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
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surfaceContainerHigh,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: upload.displayUrl ?? upload.url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: cs.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.fileName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            Formatters.date(upload.timestamp),
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ),
                        InkWell(
                          onTap: onDownload,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.download_rounded, size: 16, color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                    if (upload.expiration != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          Formatters.countdown(upload.expiration!),
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: upload.expiration!.isExpired ? cs.error : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
