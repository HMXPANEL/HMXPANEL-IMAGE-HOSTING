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
      floatingActionButton: GlassFAB(
        onPressed: () => _showAddKeySheet(context, ref),
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
        padding: const EdgeInsets.all(24),
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

class _ApiProviderCard extends StatefulWidget {
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
  State<_ApiProviderCard> createState() => _ApiProviderCardState();
}

class _ApiProviderCardState extends State<_ApiProviderCard> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = context.colorScheme;
    final apiKey = widget.apiKey;
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
                    onTap: widget.onToggle,
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
                      _obscured ? Formatters.maskApiKey(widget.apiKey.key) : widget.apiKey.key,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 16, color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.apiKey.description != null && widget.apiKey.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.apiKey.description!,
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
                    onPressed: widget.onEdit,
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
                    onPressed: widget.onDelete,
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
