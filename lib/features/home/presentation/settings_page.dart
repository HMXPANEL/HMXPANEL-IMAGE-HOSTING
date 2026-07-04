import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../upload/presentation/upload_provider.dart';
import 'profile_sheet.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/premium_extensions.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _accentColors = [
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  bool _uploadNotify = true;
  bool _biometricAuth = false;
  bool _biometricAvailable = false;
  bool _biometricChecking = true;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometrics();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _uploadNotify = prefs.getBool('upload_notify') ?? true;
        _biometricAuth = prefs.getBool('biometric_auth') ?? false;
      });
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      final enrolled = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _biometricAvailable = available && enrolled;
          _biometricChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _biometricChecking = false;
        });
      }
    }
  }

  Future<bool> _authenticateBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric lock',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final upload = ref.watch(uploadProvider);
    final cs = context.colorScheme;
    final g = context.glass;
    final a = context.aurora;
    final user = auth.user;
    final autoDelete = ref.watch(autoDeleteProvider);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.isSmall(context) ? 340 : 380,
            collapsedHeight: ResponsiveUtils.isSmall(context) ? 100 : 110,
            pinned: true,
            backgroundColor: Colors.transparent,
            foregroundColor: cs.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.padding(context).left,
                  MediaQuery.of(context).padding.top + (ResponsiveUtils.isSmall(context) ? 40 : 60),
                  ResponsiveUtils.padding(context).right,
                  16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
              ResponsiveUtils.bottomNavHeight(context),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAppearanceSection(context, cs),
                const SizedBox(height: 12),
                _buildNotificationsSection(context, cs, autoDelete),
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
      padding: EdgeInsets.all(ResponsiveUtils.isSmall(context) ? 16 : 24),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtils.isSmall(context) ? 48 : 64,
            height: ResponsiveUtils.isSmall(context) ? 48 : 64,
            decoration: BoxDecoration(
              gradient: a.primaryAurora,
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isSmall(context) ? 14 : 20),
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
                ((user?.displayName?.isNotEmpty == true ? user!.displayName : 'U')[0]).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.isSmall(context) ? 24 : 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GlassBadge(
                  label: 'Free Plan',
                  color: a.electricBlue,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant, size: 20),
            onPressed: () => ProfileSheet.show(context),
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
              Expanded(
                child: Text(
                  'Storage Usage',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                '${Formatters.bytes(totalSize)} / 100 MB',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassProgressBar(value: percent, height: 8),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${upload.uploads.length} images',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).round()}% used',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ColorScheme cs) {
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
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _accentColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => ref.read(accentColorProvider.notifier).setColor(_accentColors[i]),
                  child: Container(
                    width: 28,
                    height: 28,
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

  Widget _buildNotificationsSection(
      BuildContext context, ColorScheme cs, AutoDeleteSetting autoDelete) {
    return GlassSection(
      title: 'Notifications',
      subtitle: 'Manage your alerts',
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.cloud_done_rounded,
            title: 'Upload Complete',
            subtitle: 'Notify when upload finishes',
            trailing: Switch(
              value: _uploadNotify,
              onChanged: (v) {
                setState(() => _uploadNotify = v);
                _saveSetting('upload_notify', v);
              },
            ),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.delete_outline_rounded,
            title: 'Auto Delete',
            subtitle: autoDelete.enabled
                ? _autoDeleteLabel(autoDelete)
                : 'Auto-delete old uploads',
            trailing: Switch(
              value: autoDelete.enabled,
              onChanged: (v) => _handleAutoDeleteToggle(context, v),
            ),
          ),
        ],
      ),
    );
  }

  String _autoDeleteLabel(AutoDeleteSetting setting) {
    if (!setting.enabled) return 'Disabled';
    if (setting.duration == AutoDeleteDuration.never) return 'Disabled';
    if (setting.duration == AutoDeleteDuration.custom) {
      return 'After ${setting.customHours}h';
    }
    const labels = {
      AutoDeleteDuration.oneHour: 'After 1 Hour',
      AutoDeleteDuration.sixHours: 'After 6 Hours',
      AutoDeleteDuration.twelveHours: 'After 12 Hours',
      AutoDeleteDuration.oneDay: 'After 1 Day',
      AutoDeleteDuration.sevenDays: 'After 7 Days',
      AutoDeleteDuration.thirtyDays: 'After 30 Days',
    };
    return labels[setting.duration] ?? 'Disabled';
  }

  void _handleAutoDeleteToggle(BuildContext context, bool value) {
    if (!value) {
      ref.read(autoDeleteProvider.notifier).save(
        const AutoDeleteSetting(enabled: false),
      );
      return;
    }
    _showAutoDeleteSheet(context);
  }

  void _showAutoDeleteSheet(BuildContext context) {
    final cs = this.context.colorScheme;
    final a = this.context.aurora;
    AutoDeleteDuration selectedDuration = AutoDeleteDuration.oneDay;
    int customHours = 24;
    final customCtrl = TextEditingController(text: '24');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(ResponsiveUtils.isSmall(ctx) ? 20 : 28),
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
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: a.accentGlow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto Delete',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'When should uploaded images be deleted?',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...AutoDeleteDuration.values.map((d) {
                  if (d == AutoDeleteDuration.custom) {
                    return Column(
                      children: [
                        _DurationOption(
                          label: _durationLabel(d),
                          selected: selectedDuration == d,
                          onTap: () => setSheetState(() => selectedDuration = d),
                        ),
                        if (selectedDuration == d) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: customCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Hours',
                                    filled: true,
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    customHours = int.tryParse(v) ?? 1;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: customHours >= 24
                                        ? '${customHours ~/ 24}'
                                        : '',
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Days',
                                    filled: true,
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    final days = int.tryParse(v) ?? 0;
                                    if (days > 0) {
                                      customCtrl.text = '${days * 24}';
                                      customHours = days * 24;
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: customHours >= 168
                                        ? '${customHours ~/ 168}'
                                        : '',
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Weeks',
                                    filled: true,
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    final weeks = int.tryParse(v) ?? 0;
                                    if (weeks > 0) {
                                      customCtrl.text = '${weeks * 168}';
                                      customHours = weeks * 168;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withAlpha(30)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Only future uploads will follow this rule.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                  return _DurationOption(
                    label: _durationLabel(d),
                    selected: selectedDuration == d,
                    onTap: () => setSheetState(() => selectedDuration = d),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(ctx),
                        expanded: true,
                        gradient: LinearGradient(
                          colors: [cs.surfaceContainerHighest, cs.surfaceContainerHighest],
                        ),
                        foregroundColor: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        label: 'Save',
                        onPressed: () {
                          final hours = selectedDuration == AutoDeleteDuration.custom
                              ? (int.tryParse(customCtrl.text) ?? 24).clamp(1, 8760)
                              : null;
                          ref.read(autoDeleteProvider.notifier).save(
                            AutoDeleteSetting(
                              enabled: true,
                              duration: selectedDuration,
                              customHours: hours,
                            ),
                          );
                          Navigator.pop(ctx);
                          GlassSnackBar.show(context, 'Auto delete enabled',
                              icon: Icons.check_circle_rounded);
                        },
                        expanded: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _durationLabel(AutoDeleteDuration d) {
    switch (d) {
      case AutoDeleteDuration.never: return 'Never';
      case AutoDeleteDuration.oneHour: return 'After 1 Hour';
      case AutoDeleteDuration.sixHours: return 'After 6 Hours';
      case AutoDeleteDuration.twelveHours: return 'After 12 Hours';
      case AutoDeleteDuration.oneDay: return 'After 1 Day';
      case AutoDeleteDuration.sevenDays: return 'After 7 Days';
      case AutoDeleteDuration.thirtyDays: return 'After 30 Days';
      case AutoDeleteDuration.custom: return 'Custom';
    }
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
            subtitle: _biometricChecking
                ? 'Checking device support...'
                : !_biometricAvailable
                    ? 'Biometric auth not available on this device'
                    : 'Require biometrics to open app',
            trailing: _biometricChecking
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                  )
                : Switch(
                    value: _biometricAuth,
                    onChanged: !_biometricAvailable
                        ? null
                        : (v) async {
                            if (v) {
                              final authenticated = await _authenticateBiometric();
                              if (!authenticated) {
                                if (context.mounted) {
                                  GlassSnackBar.show(
                                    context,
                                    'Authentication failed',
                                    isError: true,
                                  );
                                }
                                return;
                              }
                            }
                            setState(() => _biometricAuth = v);
                            _saveSetting('biometric_auth', v);
                            if (context.mounted) {
                              GlassSnackBar.show(
                                context,
                                v ? 'Biometric auth enabled' : 'Biometric auth disabled',
                                icon: v ? Icons.check_circle_rounded : null,
                              );
                            }
                          },
                  ),
          ),
          const SizedBox(height: 4),
          const GlassDivider(),
          const SizedBox(height: 4),
          Consumer(
            builder: (_, ref2, __) {
              final hideKeys = ref2.watch(hideApiKeysProvider);
              return _SettingRow(
                icon: Icons.visibility_off_rounded,
                title: 'Hide API Keys',
                subtitle: hideKeys ? 'API keys are masked' : 'API keys are visible',
                trailing: Switch(
                  value: hideKeys,
                  onChanged: (v) => ref2.read(hideApiKeysProvider.notifier).set(v),
                ),
              );
            },
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

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

class _DurationOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? cs.primaryContainer.withAlpha(60) : Colors.transparent,
            border: Border.all(
              color: selected ? cs.primary.withAlpha(80) : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
