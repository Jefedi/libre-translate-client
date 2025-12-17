import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<String> languages;
  final Function(String) onChanged;
  final String label;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
    required this.label,
  });

  String _getLanguageName(String code) {
    const languageNames = {
      'auto': 'Détection auto',
      'fr': 'Français',
      'en': 'English',
      'es': 'Español',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'ja': '日本語',
      'zh': '中文',
      'ar': 'العربية',
      'hi': 'हिन्दी',
      'nl': 'Nederlands',
      'pl': 'Polski',
      'tr': 'Türkçe',
      'ko': '한국어',
      'sv': 'Svenska',
      'da': 'Dansk',
      'fi': 'Suomi',
      'no': 'Norsk',
      'cs': 'Čeština',
      'el': 'Ελληνικά',
      'he': 'עברית',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
      'uk': 'Українська',
    };

    return languageNames[code] ?? code.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: selectedLanguage,
          isExpanded: true,
          underline: Container(),
          items: languages.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text(_getLanguageName(code)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
