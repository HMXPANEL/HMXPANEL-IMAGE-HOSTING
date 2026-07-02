import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/extensions.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final upload = ref.watch(uploadProvider);
    final cs = Theme.of(context).colorScheme;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            children: [
              _SectionTitle(title: 'Appearance', cs: cs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode', style: TextStyle(color: cs.onSurfaceVariant)),
                  Consumer(
                    builder: (_, ref2, __) {
                      return Switch(
                        value: context.isDark,
                        onChanged: (v) => ref2.read(themeModeProvider.notifier).toggle(v),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              _SectionTitle(title: 'Account', cs: cs),
              _InfoRow(label: 'Email', value: user?.email ?? '-', cs: cs),
              const SizedBox(height: 4),
              _InfoRow(label: 'Total Uploads', value: '${upload.uploads.length}', cs: cs),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              _SectionTitle(title: 'Storage', cs: cs),
              _InfoRow(label: 'Images Stored', value: '${upload.uploads.length}', cs: cs),
              const SizedBox(height: 4),
              _InfoRow(label: 'API Keys', value: '${upload.apiKeys.length}', cs: cs),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              _SectionTitle(title: 'About', cs: cs),
              _InfoRow(label: 'Version', value: AppConstants.appVersion, cs: cs),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ColorScheme cs;

  const _SectionTitle({required this.title, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        Text(value, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
      ],
    );
  }
}
