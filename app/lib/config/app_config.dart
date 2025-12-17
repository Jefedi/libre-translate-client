class AppConfig {
  // ⚠️ CONFIGURATION UNIQUE - Ton serveur LibreTranslate
  static const String libreTranslateUrl = 'http://100.64.0.2:5000';

  // Clé API LibreTranslate (si tu as activé LT_API_KEYS=true dans Docker)
  // Change cette valeur si ton serveur LibreTranslate nécessite une clé API
  static const String libreTranslateApiKey = '';

  // Informations de l'application
  static const String appName = 'LibreTranslate';
  static const String appVersion = '1.0.0';

  // Configuration du cache local
  static const int cacheTTLSeconds = 86400; // 24 heures
  static const int maxCacheEntries = 1000;

  // Configuration de l'historique
  static const int maxHistoryEntries = 500;

  // Timeout des requêtes
  static const Duration requestTimeout = Duration(seconds: 30);

  // Langues favorites par défaut
  static const List<String> defaultFavoriteLanguages = ['fr', 'en', 'es', 'de', 'it'];

  // Taille maximum des fichiers (10 MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
}
