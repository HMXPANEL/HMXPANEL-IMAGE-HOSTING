import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AutoDeleteDuration {
  never,
  oneHour,
  sixHours,
  twelveHours,
  oneDay,
  sevenDays,
  thirtyDays,
  custom,
}

class AutoDeleteSetting {
  final bool enabled;
  final AutoDeleteDuration duration;
  final int? customHours;

  const AutoDeleteSetting({
    this.enabled = false,
    this.duration = AutoDeleteDuration.never,
    this.customHours,
  });

  AutoDeleteSetting copyWith({bool? enabled, AutoDeleteDuration? duration, int? customHours}) {
    return AutoDeleteSetting(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
      customHours: customHours ?? this.customHours,
    );
  }

  Duration? get expirationDuration {
    if (!enabled || duration == AutoDeleteDuration.never) return null;
    switch (duration) {
      case AutoDeleteDuration.never: return null;
      case AutoDeleteDuration.oneHour: return const Duration(hours: 1);
      case AutoDeleteDuration.sixHours: return const Duration(hours: 6);
      case AutoDeleteDuration.twelveHours: return const Duration(hours: 12);
      case AutoDeleteDuration.oneDay: return const Duration(days: 1);
      case AutoDeleteDuration.sevenDays: return const Duration(days: 7);
      case AutoDeleteDuration.thirtyDays: return const Duration(days: 30);
      case AutoDeleteDuration.custom: {
        final h = customHours;
        return h != null ? Duration(hours: h) : null;
      }
    }
  }
}

final autoDeleteProvider = StateNotifierProvider<AutoDeleteNotifier, AutoDeleteSetting>((ref) {
  return AutoDeleteNotifier();
});

class AutoDeleteNotifier extends StateNotifier<AutoDeleteSetting> {
  AutoDeleteNotifier() : super(const AutoDeleteSetting()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('auto_delete_enabled') ?? false;
    final durationIndex = prefs.getInt('auto_delete_duration') ?? 0;
    final customHours = prefs.getInt('auto_delete_custom_hours');
    final index = durationIndex.clamp(0, AutoDeleteDuration.values.length - 1);
    state = AutoDeleteSetting(
      enabled: enabled,
      duration: AutoDeleteDuration.values[index],
      customHours: customHours,
    );
  }

  Future<void> save(AutoDeleteSetting setting) async {
    state = setting;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_delete_enabled', setting.enabled);
    await prefs.setInt('auto_delete_duration', setting.duration.index);
    if (setting.customHours != null) {
      await prefs.setInt('auto_delete_custom_hours', setting.customHours!);
    } else {
      await prefs.remove('auto_delete_custom_hours');
    }
  }
}

final hideApiKeysProvider = StateNotifierProvider<HideApiKeysNotifier, bool>((ref) {
  return HideApiKeysNotifier();
});

class HideApiKeysNotifier extends StateNotifier<bool> {
  HideApiKeysNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('hide_api_keys') ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_api_keys', state);
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_api_keys', value);
  }
}
