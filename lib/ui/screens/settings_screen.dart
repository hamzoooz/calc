import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/settings_provider.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(l10n.appearance, isDark),
          const SizedBox(height: 8),
          _buildGlassCard(
            isDark,
            child: Column(
              children: [
                _buildThemeTile(context, settings, l10n, isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calculator Mode Section
          _buildSectionHeader(l10n.calculatorMode, isDark),
          const SizedBox(height: 8),
          _buildGlassCard(
            isDark,
            child: Column(
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.science_outlined,
                  title: l10n.scientific,
                  subtitle: 'Show scientific functions',
                  value: settings.scientificMode,
                  onChanged: (value) => settings.setScientificMode(value),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildAngleModeTile(context, settings, l10n, isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Feedback Section
          _buildSectionHeader(l10n.feedback, isDark),
          const SizedBox(height: 8),
          _buildGlassCard(
            isDark,
            child: Column(
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.volume_up_outlined,
                  title: l10n.sound,
                  subtitle: 'Play sounds on button press',
                  value: settings.soundEnabled,
                  onChanged: (value) => settings.setSoundEnabled(value),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  context,
                  icon: Icons.vibration,
                  title: l10n.haptic,
                  subtitle: 'Vibrate on button press',
                  value: settings.hapticEnabled,
                  onChanged: (value) => settings.setHapticEnabled(value),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(l10n.language, isDark),
          const SizedBox(height: 8),
          _buildGlassCard(
            isDark,
            child: _buildLanguageTile(context, settings, l10n, isDark),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(l10n.about, isDark),
          const SizedBox(height: 8),
          _buildGlassCard(
            isDark,
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.info_outline,
                  title: l10n.version,
                  value: '1.0.0',
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildTapTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () {
                    // Open privacy policy
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildGlassCard(bool isDark, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        l10n.theme,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      subtitle: Text(
        _getThemeName(settings.themeMode, l10n),
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, settings, l10n),
    );
  }

  String _getThemeName(AppThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n.lightMode;
      case AppThemeMode.dark:
        return l10n.darkMode;
      case AppThemeMode.system:
        return l10n.systemMode;
    }
  }

  void _showThemeDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: Text(l10n.lightMode),
              value: AppThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text(l10n.darkMode),
              value: AppThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text(l10n.systemMode),
              value: AppThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngleModeTile(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.rotate_right,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        l10n.angleUnit,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      subtitle: Text(
        settings.useRadians ? l10n.radians : l10n.degrees,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAngleModeDialog(context, settings, l10n),
    );
  }

  void _showAngleModeDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.angleUnit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: Text(l10n.degrees),
              value: false,
              groupValue: settings.useRadians,
              onChanged: (value) {
                settings.setUseRadians(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool>(
              title: Text(l10n.radians),
              value: true,
              groupValue: settings.useRadians,
              onChanged: (value) {
                settings.setUseRadians(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.language,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        l10n.language,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      subtitle: Text(
        settings.language == AppLanguage.english ? l10n.english : l10n.arabic,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, settings, l10n),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppLanguage>(
              title: Text(l10n.english),
              value: AppLanguage.english,
              groupValue: settings.language,
              onChanged: (value) {
                settings.setLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppLanguage>(
              title: Text(l10n.arabic),
              value: AppLanguage.arabic,
              groupValue: settings.language,
              onChanged: (value) {
                settings.setLanguage(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildTapTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryStart,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
