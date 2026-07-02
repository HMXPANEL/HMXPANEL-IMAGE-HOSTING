import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/utils/extensions.dart';

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      title: '',
      child: const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final upload = ref.watch(uploadProvider);
    final cs = Theme.of(context).colorScheme;
    final user = auth.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person_rounded, size: 40, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatItem(label: 'Uploads', value: '${upload.uploads.length}'),
              _StatItem(label: 'API Keys', value: '${upload.apiKeys.length}'),
              _StatItem(label: 'Days', value: _daysSince(user?.createdAt)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(backgroundColor: cs.error),
            ),
          ),
        ],
      ),
    );
  }

  String _daysSince(DateTime? date) {
    if (date == null) return '0';
    return '${DateTime.now().difference(date).inDays}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
