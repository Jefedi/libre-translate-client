import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/translation.dart';
import '../services/database_service.dart';
import '../providers/translation_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Translation> _translations = [];
  bool _isLoading = true;
  bool _showOnlyFavorites = false;
  final TextEditingController _searchController = TextEditingController();
  int _lastHistoryUpdateCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Écouter les changements dans le provider
    final translationProvider = Provider.of<TranslationProvider>(context);
    if (translationProvider.historyUpdateCounter != _lastHistoryUpdateCounter) {
      _lastHistoryUpdateCounter = translationProvider.historyUpdateCounter;
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    final history = await _db.getHistory(
      limit: 100,
      onlyFavorites: _showOnlyFavorites,
    );

    setState(() {
      _translations = history;
      _isLoading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadHistory();
      return;
    }

    setState(() => _isLoading = true);

    final results = await _db.searchHistory(query);

    setState(() {
      _translations = results;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Translation translation) async {
    await _db.toggleFavorite(translation.id!, !translation.isFavorite);
    if (mounted) {
      Provider.of<TranslationProvider>(context, listen: false).notifyHistoryChanged();
    }
    _loadHistory();
  }

  Future<void> _deleteTranslation(int id) async {
    await _db.deleteTranslation(id);
    if (mounted) {
      Provider.of<TranslationProvider>(context, listen: false).notifyHistoryChanged();
    }
    _loadHistory();
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text(
          'Voulez-vous effacer tout l\'historique ? Les favoris seront conservés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.clearHistory(keepFavorites: true);
      if (mounted) {
        Provider.of<TranslationProvider>(context, listen: false).notifyHistoryChanged();
      }
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
              _loadHistory();
            },
            tooltip: 'Favoris uniquement',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearHistory,
            tooltip: 'Effacer l\'historique',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadHistory();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _translations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showOnlyFavorites
                                  ? 'Aucun favori'
                                  : 'Aucune traduction',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          itemCount: _translations.length,
                          itemBuilder: (context, index) {
                            final translation = _translations[index];
                            return _buildHistoryItem(translation);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Translation translation) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: IconButton(
          icon: Icon(
            translation.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: translation.isFavorite ? Colors.red : null,
          ),
          onPressed: () => _toggleFavorite(translation),
        ),
        title: Text(
          translation.translatedText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${translation.sourceLanguage} → ${translation.targetLanguage} • ${dateFormat.format(translation.timestamp)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Original:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(translation.originalText),
                const Divider(height: 24),
                Text(
                  'Traduction:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(translation.translatedText),
                if (translation.alternatives != null &&
                    translation.alternatives!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    'Alternatives:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...translation.alternatives!.map(
                    (alt) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $alt'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
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
                      icon: const Icon(Icons.copy),
                      label: const Text('Copier'),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteTranslation(translation.id!),
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
