import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/utils/extensions.dart';

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final upload = ref.watch(uploadProvider);
    final a = context.aurora;
    final user = auth.user;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: a.primaryAurora,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: a.electricBlue.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(
                color: context.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _StatItem(label: 'Uploads', value: '${upload.uploads.length}', aurora: a)),
                Expanded(child: _StatItem(label: 'API Keys', value: '${upload.apiKeys.length}', aurora: a)),
                Expanded(child: _StatItem(label: 'Days', value: _daysSince(user?.createdAt), aurora: a)),
              ],
            ),
            const SizedBox(height: 24),
            GlassButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
              gradient: LinearGradient(
                colors: [context.colorScheme.error, context.colorScheme.error.withAlpha(200)],
              ),
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  String _daysSince(DateTime? date) {
    if (date == null) return '0';
    return '${DateTime.now().difference(date).inDays}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final AuroraThemeExtension aurora;

  const _StatItem({
    required this.label,
    required this.value,
    required this.aurora,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: aurora.primaryAurora,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}