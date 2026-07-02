import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../upload/domain/api_key_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';

class ApiKeysPage extends ConsumerWidget {
  const ApiKeysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'API Keys',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddKeySheet(context, ref),
            icon: Icon(Icons.add_rounded, color: cs.primary),
          ),
        ],
      ),
      body: state.apiKeys.isEmpty
          ? const EmptyState(
              icon: Icons.key_outlined,
              title: 'No API keys yet',
              subtitle: 'Add one to start uploading images',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.apiKeys.length,
              itemBuilder: (_, index) => _ApiKeyCard(
                key: ValueKey(state.apiKeys[index].id),
                apiKey: state.apiKeys[index],
                onEdit: () => _showEditKeySheet(context, ref, state.apiKeys[index]),
                onDelete: () => _confirmDelete(context, ref, state.apiKeys[index].id),
              ),
            ),
    );
  }

  void _showAddKeySheet(BuildContext context, WidgetRef ref) {
    AppBottomSheet.show(
      context,
      title: 'Add API Key',
      child: _ApiKeyForm(
        onSave: (service, name, key, desc, active) {
          ref.read(uploadProvider.notifier).addApiKey(
                service: service,
                name: name,
                key: key,
                description: desc,
                active: active,
              );
        },
      ),
    );
  }

  void _showEditKeySheet(BuildContext context, WidgetRef ref, ApiKey apiKey) {
    AppBottomSheet.show(
      context,
      title: 'Edit API Key',
      child: _ApiKeyForm(
        initialKey: apiKey,
        onSave: (service, name, key, desc, active) {
          ref.read(uploadProvider.notifier).updateApiKey(
                apiKey.copyWith(
                  service: service,
                  name: name,
                  key: key,
                  description: desc,
                  active: active,
                ),
              );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete API Key'),
        content: const Text('Are you sure you want to delete this API key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(uploadProvider.notifier).deleteApiKey(id);
              Navigator.pop(context);
              context.showSnackBar('API Key deleted');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ApiKeyCard extends StatelessWidget {
  final ApiKey apiKey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ApiKeyCard({
    super.key,
    required this.apiKey,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHigh,
        border: apiKey.active
            ? Border.all(color: Colors.green.shade400, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: _serviceGradient(apiKey.service),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.key_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiKey.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      apiKey.service.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: apiKey.active
                      ? Colors.green.withAlpha(25)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (apiKey.active)
                      Icon(Icons.check, size: 14, color: Colors.green.shade400),
                    const SizedBox(width: 4),
                    Text(
                      apiKey.active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: apiKey.active ? Colors.green.shade400 : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.maskApiKey(apiKey.key),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
          if (apiKey.description != null && apiKey.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              apiKey.description!,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _ApiKeyForm extends StatefulWidget {
  final ApiKey? initialKey;
  final void Function(String service, String name, String key, String? description, bool active) onSave;

  const _ApiKeyForm({this.initialKey, required this.onSave});

  @override
  State<_ApiKeyForm> createState() => _ApiKeyFormState();
}

class _ApiKeyFormState extends State<_ApiKeyForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _descCtrl;
  String _service = 'imgbb';
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialKey?.name ?? '');
    _keyCtrl = TextEditingController(text: widget.initialKey?.key ?? '');
    _descCtrl = TextEditingController(text: widget.initialKey?.description ?? '');
    _service = widget.initialKey?.service ?? 'imgbb';
    _active = widget.initialKey?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _service,
              decoration: const InputDecoration(labelText: 'Service'),
              items: AppConstants.supportedServices.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(AppConstants.serviceLabels[s] ?? s),
                );
              }).toList(),
              onChanged: (v) => setState(() => _service = v ?? 'imgbb'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'My API Key'),
              validator: Validators.apiKeyName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'API Key', hintText: 'Enter your API key'),
              validator: Validators.apiKeyValue,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: "What's this key for?",
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Set as Active', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Switch(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(
                          _service,
                          _nameCtrl.text.trim(),
                          _keyCtrl.text.trim(),
                          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                          _active,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(widget.initialKey != null ? 'Update' : 'Save'),
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
