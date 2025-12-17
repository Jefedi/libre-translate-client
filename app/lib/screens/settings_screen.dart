import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/translation_provider.dart';
import '../services/database_service.dart';
import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  Map<String, int> _stats = {'total': 0, 'favorites': 0};
  int _lastHistoryUpdateCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Écouter les changements dans le provider
    final translationProvider = Provider.of<TranslationProvider>(context);
    if (translationProvider.historyUpdateCounter != _lastHistoryUpdateCounter) {
      _lastHistoryUpdateCounter = translationProvider.historyUpdateCounter;
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final stats = await _db.getStats();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // Info de connexion
              Card(
                margin: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_done,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Serveur LibreTranslate',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConfig.libreTranslateUrl,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              // Section Apparence
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Apparence'),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
              ),

              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Mode sombre'),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),

              const Divider(),

              // Section Traduction
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Traduction'),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
              ),

              SwitchListTile(
                secondary: const Icon(Icons.history),
                title: const Text('Sauvegarder dans l\'historique'),
                subtitle: const Text('Enregistrer les traductions dans l\'historique'),
                value: settings.saveToHistory,
                onChanged: (value) => settings.setSaveToHistory(value),
              ),

              const Divider(),

              // Section Statistiques
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Statistiques'),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
              ),

              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Total de traductions'),
                trailing: Text(
                  _stats['total'].toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favoris'),
                trailing: Text(
                  _stats['favorites'].toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const Divider(),

              // Section Actions
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: const Text('Actions'),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
              ),

              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Rafraîchir les statistiques'),
                onTap: _loadStats,
              ),

              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Réinitialiser les paramètres'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Réinitialiser les paramètres'),
                      content: const Text(
                        'Voulez-vous vraiment réinitialiser tous les paramètres ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Réinitialiser'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await settings.resetSettings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paramètres réinitialisés'),
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 32),

              // Version et info
              Center(
                child: Column(
                  children: [
                    Text(
                      AppConfig.appName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version ${AppConfig.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
