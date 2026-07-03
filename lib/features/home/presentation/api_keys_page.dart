import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../upload/domain/api_key_model.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

class ApiKeysPage extends ConsumerWidget {
  const ApiKeysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final a = context.aurora;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: const GlassFAB(
        onPressed: null,
        icon: Icons.add_rounded,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.isSmall(context) ? 140 : 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            foregroundColor: context.colorScheme.onSurface,
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
                      'API Keys',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.apiKeys.length} key${state.apiKeys.length != 1 ? 's' : ''} configured',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: 14,
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
            sliver: state.apiKeys.isEmpty
                ? SliverFillRemaining(
                    child: GlassEmptyState(
                      icon: Icons.key_rounded,
                      title: 'No API keys yet',
                      subtitle: 'Add an API key to start uploading to your preferred service',
                      iconGradient: a.primaryAurora,
                      action: const GlassButton(
                        label: 'Add API Key',
                        icon: Icons.add_rounded,
                        onPressed: null,
                        expanded: false,
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        final apiKey = state.apiKeys[index];
                        return _ApiProviderCard(
                          key: ValueKey(apiKey.id),
                          apiKey: apiKey,
                          onEdit: () {},
                          onDelete: () => _confirmDelete(context, ref, apiKey.id),
                          onToggle: () {
                            ref.read(uploadProvider.notifier).updateApiKey(
                              apiKey.copyWith(active: !apiKey.active),
                            );
                          },
                        ).animate().fadeIn(
                          duration: 400.ms,
                          delay: (index * 80).ms,
                          curve: Curves.easeOut,
                        ).slideX(begin: 0.05, end: 0);
                      },
                      childCount: state.apiKeys.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => _GlassConfirmDialog(
        title: 'Delete API Key',
        message: 'Are you sure you want to delete this API key? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          ref.read(uploadProvider.notifier).deleteApiKey(id);
          Navigator.pop(context);
          GlassSnackBar.show(context, 'API Key deleted');
        },
      ),
    );
  }
}

class _ApiProviderCard extends StatelessWidget {
  final ApiKey apiKey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ApiProviderCard({
    super.key,
    required this.apiKey,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = context.colorScheme;
    final gradient = _serviceGradient(apiKey.service);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        gradient: g.glassSurface,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.key_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apiKey.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.serviceLabels[apiKey.service] ?? apiKey.service,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassBadge(
                  label: apiKey.active ? 'Active' : 'Inactive',
                  color: apiKey.active
                      ? const Color(0xFF10B981)
                      : cs.onSurfaceVariant,
                  icon: apiKey.active ? Icons.check_circle : null,
                ),
                if (apiKey.active)
                  const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: apiKey.active ? const Color(0xFF10B981) : cs.surfaceContainerHighest,
                  ),
                  child: GestureDetector(
                    onTap: onToggle,
                    child: AnimatedAlign(
                      duration: 200.ms,
                      curve: Curves.easeOutCubic,
                      alignment: apiKey.active ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: g.glassSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Formatters.maskApiKey(apiKey.key),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(Icons.visibility_outlined, size: 16, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            if (apiKey.description != null && apiKey.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      apiKey.description!,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                    expanded: true,
                    fontSize: 13,
                    gradient: LinearGradient(
                      colors: [g.glassSurfaceVariant, g.glassSurfaceVariant],
                    ),
                    foregroundColor: cs.onSurface,
                    borderColor: g.glassBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    onPressed: onDelete,
                    expanded: true,
                    fontSize: 13,
                    gradient: LinearGradient(
                      colors: [cs.error.withAlpha(30), cs.error.withAlpha(10)],
                    ),
                    foregroundColor: cs.error,
                    borderColor: cs.error.withAlpha(50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _serviceGradient(String service) {
    switch (service) {
      case 'imgbb':
        return const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]);
      case 'imgkit':
        return const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]);
      case 'cloudinary':
        return const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]);
      case 'imgur':
        return const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF10B981)]);
      case 'postimage':
        return const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFF97316)]);
      default:
        return const LinearGradient(colors: [Color(0xFF64748B), Color(0xFF475569)]);
    }
  }
}

class _GlassConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const _GlassConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = context.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        gradient: g.glassSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
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
                    label: confirmLabel,
                    onPressed: onConfirm,
                    expanded: true,
                    fontSize: 14,
                    gradient: LinearGradient(
                      colors: [cs.error, cs.error.withAlpha(200)],
                    ),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}