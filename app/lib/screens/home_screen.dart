import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _sourceController = TextEditingController();

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibreTranslate'),
        centerTitle: true,
      ),
      body: Consumer2<TranslationProvider, SettingsProvider>(
        builder: (context, translation, settings, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélecteur de langues
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: LanguageSelector(
                            selectedLanguage: translation.sourceLanguage,
                            languages: ['auto', ...translation.languages.map((l) => l.code)],
                            onChanged: (code) {
                              translation.setSourceLanguage(code);
                            },
                            label: 'Source',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: translation.sourceLanguage == 'auto'
                              ? null
                              : () => translation.swapLanguages(),
                        ),
                        Expanded(
                          child: LanguageSelector(
                            selectedLanguage: translation.targetLanguage,
                            languages: translation.languages.map((l) => l.code).toList(),
                            onChanged: (code) {
                              translation.setTargetLanguage(code);
                            },
                            label: 'Cible',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Texte source
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _sourceController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: 'Entrez le texte à traduire...',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            translation.setSourceText(text);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${_sourceController.text.length} caractères',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _sourceController.clear();
                                translation.clearTranslation();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton traduire
                FilledButton.icon(
                  onPressed: translation.isLoading || _sourceController.text.trim().isEmpty
                      ? null
                      : () {
                          translation.translate(
                            useCache: true,
                            saveToHistory: settings.saveToHistory,
                          );
                        },
                  icon: translation.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.translate),
                  label: Text(translation.isLoading ? 'Traduction...' : 'Traduire'),
                ),

                const SizedBox(height: 16),

                // Erreur
                if (translation.errorMessage != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              translation.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => translation.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Traduction
                if (translation.translatedText.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (translation.fromCache)
                                Chip(
                                  label: const Text('Cache'),
                                  avatar: const Icon(Icons.offline_bolt, size: 16),
                                ),
                              if (translation.detectedLanguage != null)
                                Chip(
                                  label: Text('Détecté: ${translation.detectedLanguage}'),
                                  avatar: const Icon(Icons.language, size: 16),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: translation.translatedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copié dans le presse-papiers'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          SelectableText(
                            translation.translatedText,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),

                          // Alternatives
                          if (translation.alternatives.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Alternatives:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...translation.alternatives.map(
                              (alt) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('• $alt'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
