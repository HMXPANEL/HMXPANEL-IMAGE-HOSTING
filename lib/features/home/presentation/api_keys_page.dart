import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../upload/domain/api_key_model.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/providers/settings_provider.dart';
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
    final rv = context.rv;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: GlassFAB(
        onPressed: () => _showAddKeySheet(context, ref),
        icon: Icons.add_rounded,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.isSmall ? 140 : 160,
            collapsedHeight: context.isSmall ? 90 : 100,
            pinned: true,
            backgroundColor: Colors.transparent,
            foregroundColor: context.colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  rv.horizontalEdge.left,
                  MediaQuery.of(context).padding.top + (context.isSmall ? 40 : 60),
                  rv.horizontalEdge.right,
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
              rv.horizontalEdge.left,
              AppSpacing.md,
              rv.horizontalEdge.right,
              rv.bottomNavHeight,
            ),
            sliver: state.apiKeys.isEmpty
                ? SliverFillRemaining(
                    child: GlassEmptyState(
                      icon: Icons.key_rounded,
                      title: 'No API keys yet',
                      subtitle: 'Add an API key to start uploading to your preferred service',
                      iconGradient: a.primaryAurora,
                      action: GlassButton(
                        label: 'Add API Key',
                        icon: Icons.add_rounded,
                        onPressed: () => _showAddKeySheet(context, ref),
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
                          onEdit: () => _showEditKeySheet(context, ref, apiKey),
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

  void _showAddKeySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddApiKeySheet(
        onSave: (service, name, key, description) {
          ref.read(uploadProvider.notifier).addApiKey(
            service: service,
            name: name,
            key: key,
            description: description,
            active: true,
          );
        },
      ),
    );
  }

  void _showEditKeySheet(BuildContext context, WidgetRef ref, ApiKey apiKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddApiKeySheet(
        initialKey: apiKey,
        onSave: (service, name, key, description) {
          ref.read(uploadProvider.notifier).updateApiKey(
            apiKey.copyWith(
              service: service,
              name: name,
              key: key,
              description: description,
            ),
          );
          GlassSnackBar.show(context, 'API Key updated');
        },
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

class _AddApiKeySheet extends StatefulWidget {
  final ApiKey? initialKey;
  final void Function(String service, String name, String key, String? description) onSave;

  const _AddApiKeySheet({this.initialKey, required this.onSave});

  @override
  State<_AddApiKeySheet> createState() => _AddApiKeySheetState();
}

class _AddApiKeySheetState extends State<_AddApiKeySheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initialKey?.name);
  late final _keyCtrl = TextEditingController(text: widget.initialKey?.key);
  late final _descCtrl = TextEditingController(text: widget.initialKey?.description);
  late String _service = widget.initialKey?.service ?? 'imgbb';

  final _services = ['imgbb', 'imgkit', 'cloudinary', 'imgur', 'postimage'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(context.rv.cardPaddingVal),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add API Key',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _service,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  filled: true,
                ),
                items: _services.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(AppConstants.serviceLabels[s] ?? s),
                )).toList(),
                onChanged: (v) => setState(() => _service = v ?? 'imgbb'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Key Name',
                  hintText: 'e.g. My Production Key',
                  filled: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Paste your API key here',
                  filled: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Key is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  filled: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      expanded: true,
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surfaceContainerHighest],
                      ),
                      foregroundColor: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      label: 'Save Key',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(_service, _nameCtrl.text.trim(), _keyCtrl.text.trim(),
                              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim());
                          Navigator.pop(context);
                          GlassSnackBar.show(context, 'API Key added');
                        }
                      },
                      expanded: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiProviderCard extends ConsumerStatefulWidget {
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
  ConsumerState<_ApiProviderCard> createState() => _ApiProviderCardState();
}

class _ApiProviderCardState extends ConsumerState<_ApiProviderCard> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = context.colorScheme;
    final apiKey = widget.apiKey;
    final gradient = _serviceGradient(apiKey.service);
    final hideKeys = ref.watch(hideApiKeysProvider);

    final showMasked = hideKeys && _obscured;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        gradient: g.glassSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _serviceIcon(apiKey.service),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apiKey.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
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
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: apiKey.key));
                    GlassSnackBar.show(context, 'API key copied!', icon: Icons.check_circle_rounded);
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.copy_rounded, size: 16, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: apiKey.active
                          ? const Color(0xFF10B981).withAlpha(20)
                          : cs.surfaceContainerHighest,
                      border: Border.all(
                        color: apiKey.active
                            ? const Color(0xFF10B981).withAlpha(60)
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          apiKey.active ? Icons.check_circle : Icons.circle_outlined,
                          size: 10,
                          color: apiKey.active ? const Color(0xFF10B981) : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          apiKey.active ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: apiKey.active ? const Color(0xFF10B981) : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: g.glassSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      showMasked ? Formatters.maskApiKey(apiKey.key) : apiKey.key,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hideKeys)
                    GestureDetector(
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Icon(
                        _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 15, color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Created ${Formatters.dateTime(apiKey.createdAt)}',
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                if (apiKey.description != null && apiKey.description!.isNotEmpty)
                  Flexible(
                    child: Text(
                      apiKey.description!,
                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: widget.onEdit,
                    expanded: true,
                    fontSize: 12,
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
                    onPressed: widget.onDelete,
                    expanded: true,
                    fontSize: 12,
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

  IconData _serviceIcon(String service) {
    switch (service) {
      case 'imgbb': return Icons.image_rounded;
      case 'imgkit': return Icons.photo_library_rounded;
      case 'cloudinary': return Icons.cloud_rounded;
      case 'imgur': return Icons.photo_camera_rounded;
      case 'postimage': return Icons.drive_file_rename_outline_rounded;
      default: return Icons.key_rounded;
    }
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

    final isSmall = ResponsiveUtils.isSmall(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        gradient: g.glassSurface,
        padding: EdgeInsets.all(context.rv.cardPaddingVal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmall ? 48 : 56,
              height: isSmall ? 48 : 56,
              decoration: BoxDecoration(
                color: cs.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: cs.error, size: isSmall ? 24 : 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: isSmall ? 18 : 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: isSmall ? 13 : 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    expanded: true,
                    fontSize: isSmall ? 13 : 14,
                    gradient: LinearGradient(
                      colors: [g.glassSurfaceVariant, g.glassSurfaceVariant],
                    ),
                    foregroundColor: cs.onSurface,
                    borderColor: g.glassBorder,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton(
                    label: confirmLabel,
                    onPressed: onConfirm,
                    expanded: true,
                    fontSize: isSmall ? 13 : 14,
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
