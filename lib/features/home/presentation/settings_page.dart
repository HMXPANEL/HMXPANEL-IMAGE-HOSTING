import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../upload/presentation/upload_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _accentColors = [
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final upload = ref.watch(uploadProvider);
    final cs = context.colorScheme;
    final g = context.glass;
    final a = context.aurora;
    final user = auth.user;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.isSmall(context) ? 340 : 380,
            pinned: true,
            backgroundColor: Colors.transparent,
            foregroundColor: cs.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.padding(context).left,
                  MediaQuery.of(context).padding.top + 60,
                  ResponsiveUtils.padding(context).right,
                  0,
                ),
                child: Column(
                  children: [
                    _buildProfileCard(context, cs, g, a, user),
                    const SizedBox(height: 16),
                    _buildStorageCard(context, cs, g, upload),
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
              ResponsiveUtils.padding(context).bottom + 140,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAppearanceSection(context, cs, ref),
                const SizedBox(height: 12),
                _buildNotificationsSection(context, cs),
                const SizedBox(height: 12),
                _buildSecuritySection(context, cs),
                const SizedBox(height: 12),
                _buildAboutSection(context, cs),
                const SizedBox(height: 24),
                GlassButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  gradient: LinearGradient(
                    colors: [cs.error, cs.error.withAlpha(200)],
                  ),
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, ColorScheme cs, GlassThemeExtension g, AuroraThemeExtension a, user) {
    return GlassCard(
      gradient: g.glassSurface,
      padding: EdgeInsets.all(ResponsiveUtils.isSmall(context) ? 20 : 24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: a.primaryAurora,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: a.electricBlue.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                GlassBadge(
                  label: 'Free Plan',
                  color: a.electricBlue,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(
      BuildContext context, ColorScheme cs, GlassThemeExtension g, UploadState upload) {
    final totalSize = upload.uploads.fold<int>(0, (sum, u) => sum + u.size);
    final percent = (totalSize / (100 * 1024 * 1024)).clamp(0.0, 1.0);

    return GlassCard(
      gradient: g.glassSurfaceVariant,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Storage Usage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${Formatters.bytes(totalSize)} / 100 MB',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassProgressBar(value: percent, height: 8),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${upload.uploads.length} images',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).round()}% used',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ColorScheme cs, WidgetRef ref) {
    return GlassSection(
      title: 'Appearance',
      subtitle: 'Customize your experience',
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Toggle dark theme',
            trailing: Consumer(
              builder: (_, ref2, __) => Switch(
                value: context.isDark,
                onChanged: (v) => ref2.read(themeModeProvider.notifier).toggle(v),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.palette_outlined,
            title: 'Accent Color',
            subtitle: 'Choose your accent color',
            trailing: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _accentColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => ref.read(accentColorProvider.notifier).setColor(_accentColors[i]),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _accentColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColors[i].withAlpha(60),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, ColorScheme cs) {
    return GlassSection(
      title: 'Notifications',
      subtitle: 'Manage your alerts',
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.cloud_done_rounded,
            title: 'Upload Complete',
            subtitle: 'Notify when upload finishes',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.delete_outline_rounded,
            title: 'Auto Delete',
            subtitle: 'Notify when images expire',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, ColorScheme cs) {
    return GlassSection(
      title: 'Security',
      subtitle: 'Protect your account',
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.lock_outline_rounded,
            title: 'Biometric Auth',
            subtitle: 'Require biometrics to open app',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.visibility_off_rounded,
            title: 'Hide API Keys',
            subtitle: 'Mask all API keys in the app',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ColorScheme cs) {
    return GlassSection(
      title: 'About',
      subtitle: 'App information',
      child: Column(
        children: [
          const _SettingRow(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: AppConstants.appVersion,
            trailing: GlassBadge(label: 'Latest', color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.code_rounded,
            title: 'Developer',
            subtitle: 'HmxCloud Team',
            trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.description_outlined,
            title: 'Open Source Licenses',
            subtitle: 'Third-party software',
            trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}