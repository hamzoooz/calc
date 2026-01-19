import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Calculator Pro',

      // Calculator
      'result': 'Result',
      'expression': 'Expression',

      // History
      'history': 'History',
      'clear_history': 'Clear History',
      'no_history': 'No calculations yet',
      'favorites': 'Favorites',
      'all': 'All',

      // Settings
      'settings': 'Settings',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'dark_mode': 'Dark',
      'light_mode': 'Light',
      'system_mode': 'System',
      'feedback': 'Feedback',
      'sound': 'Sound',
      'haptic': 'Haptic Feedback',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'calculator_mode': 'Calculator Mode',
      'scientific': 'Scientific',
      'standard': 'Standard',
      'angle_unit': 'Angle Unit',
      'degrees': 'Degrees',
      'radians': 'Radians',

      // Actions
      'copy': 'Copy',
      'share': 'Share',
      'copied': 'Copied to clipboard',
      'delete': 'Delete',
      'cancel': 'Cancel',

      // Errors
      'error': 'Error',
      'invalid_input': 'Invalid input',

      // About
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
    },
    'ar': {
      // App
      'app_name': 'الآلة الحاسبة برو',

      // Calculator
      'result': 'النتيجة',
      'expression': 'المعادلة',

      // History
      'history': 'السجل',
      'clear_history': 'مسح السجل',
      'no_history': 'لا توجد حسابات بعد',
      'favorites': 'المفضلة',
      'all': 'الكل',

      // Settings
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'theme': 'السمة',
      'dark_mode': 'داكن',
      'light_mode': 'فاتح',
      'system_mode': 'النظام',
      'feedback': 'ردود الفعل',
      'sound': 'الصوت',
      'haptic': 'الاهتزاز',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'calculator_mode': 'وضع الآلة الحاسبة',
      'scientific': 'علمي',
      'standard': 'قياسي',
      'angle_unit': 'وحدة الزاوية',
      'degrees': 'درجات',
      'radians': 'راديان',

      // Actions
      'copy': 'نسخ',
      'share': 'مشاركة',
      'copied': 'تم النسخ',
      'delete': 'حذف',
      'cancel': 'إلغاء',

      // Errors
      'error': 'خطأ',
      'invalid_input': 'إدخال غير صالح',

      // About
      'about': 'حول',
      'version': 'الإصدار',
      'privacy_policy': 'سياسة الخصوصية',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get result => _localizedValues[locale.languageCode]!['result']!;
  String get expression => _localizedValues[locale.languageCode]!['expression']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get clearHistory => _localizedValues[locale.languageCode]!['clear_history']!;
  String get noHistory => _localizedValues[locale.languageCode]!['no_history']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get all => _localizedValues[locale.languageCode]!['all']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get appearance => _localizedValues[locale.languageCode]!['appearance']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get darkMode => _localizedValues[locale.languageCode]!['dark_mode']!;
  String get lightMode => _localizedValues[locale.languageCode]!['light_mode']!;
  String get systemMode => _localizedValues[locale.languageCode]!['system_mode']!;
  String get feedback => _localizedValues[locale.languageCode]!['feedback']!;
  String get sound => _localizedValues[locale.languageCode]!['sound']!;
  String get haptic => _localizedValues[locale.languageCode]!['haptic']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get calculatorMode => _localizedValues[locale.languageCode]!['calculator_mode']!;
  String get scientific => _localizedValues[locale.languageCode]!['scientific']!;
  String get standard => _localizedValues[locale.languageCode]!['standard']!;
  String get angleUnit => _localizedValues[locale.languageCode]!['angle_unit']!;
  String get degrees => _localizedValues[locale.languageCode]!['degrees']!;
  String get radians => _localizedValues[locale.languageCode]!['radians']!;
  String get copy => _localizedValues[locale.languageCode]!['copy']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get copied => _localizedValues[locale.languageCode]!['copied']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get invalidInput => _localizedValues[locale.languageCode]!['invalid_input']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacy_policy']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
