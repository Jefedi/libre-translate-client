# LibreTranslate Client

Une application de bureau multiplateforme pour LibreTranslate, offrant une interface simple et élégante pour traduire du texte en utilisant votre serveur LibreTranslate.

## Fonctionnalités

- **Traduction instantanée** : Traduisez du texte entre plusieurs langues
- **Détection automatique** : Détection automatique de la langue source
- **Historique** : Sauvegarde automatique de toutes vos traductions
- **Favoris** : Marquez vos traductions importantes
- **Alternatives** : Obtenez jusqu'à 3 traductions alternatives
- **Cache** : Les traductions sont mises en cache localement pour un accès rapide
- **Mode sombre** : Interface moderne avec support du mode sombre
- **Multiplateforme** : Windows, macOS, Linux, Android, iOS

## Captures d'écran

L'application offre une interface épurée avec :
- Onglet Traduction : Interface principale pour traduire du texte
- Onglet Historique : Accès à toutes vos traductions passées avec recherche
- Onglet Paramètres : Configuration et statistiques

## Installation

### Windows

1. Téléchargez la dernière version depuis [Releases](https://github.com/VOTRE_USERNAME/libre-translate-client/releases)
2. Extrayez l'archive ZIP
3. Lancez `libre_translate_app.exe`

### Compilation depuis les sources

Prérequis :
- Flutter SDK 3.x ou supérieur
- Visual Studio 2022 avec "Desktop development with C++" (Windows)
- Xcode (macOS)
- Linux development tools (Linux)

```bash
# Cloner le dépôt
git clone https://github.com/VOTRE_USERNAME/libre-translate-client.git
cd libre-translate-client/app

# Installer les dépendances
flutter pub get

# Compiler pour votre plateforme
flutter build windows --release  # Windows
flutter build macos --release    # macOS
flutter build linux --release    # Linux
flutter build apk --release      # Android
flutter build ios --release      # iOS
```

## Configuration

L'application est configurée pour se connecter à un serveur LibreTranslate spécifique. Pour changer le serveur :

1. Ouvrez `app/lib/config/app_config.dart`
2. Modifiez la valeur de `libreTranslateUrl`
3. Si votre serveur nécessite une clé API, ajoutez-la dans `libreTranslateApiKey`
4. Recompilez l'application

```dart
class AppConfig {
  static const String libreTranslateUrl = 'http://VOTRE_SERVEUR:5000';
  static const String libreTranslateApiKey = 'VOTRE_CLE_API';
  // ...
}
```

## Utilisation

1. **Traduire du texte** :
   - Sélectionnez la langue source (ou laissez sur "Détection automatique")
   - Sélectionnez la langue cible
   - Tapez ou collez votre texte
   - Cliquez sur "Traduire"

2. **Consulter l'historique** :
   - Accédez à l'onglet "Historique"
   - Utilisez la barre de recherche pour filtrer
   - Cliquez sur une traduction pour voir les détails et alternatives

3. **Gérer les favoris** :
   - Dans l'historique, cliquez sur l'icône cœur pour marquer comme favori
   - Utilisez le filtre favoris pour voir uniquement vos favoris

4. **Statistiques** :
   - Accédez à l'onglet "Paramètres"
   - Consultez le nombre total de traductions et de favoris
   - Ces statistiques se mettent à jour en temps réel

## Architecture technique

### Structure du projet

```
app/
├── lib/
│   ├── config/          # Configuration de l'application
│   ├── models/          # Modèles de données
│   ├── providers/       # State management (Provider)
│   ├── screens/         # Écrans de l'application
│   ├── services/        # Services (API, Database)
│   └── main.dart        # Point d'entrée
└── pubspec.yaml         # Dépendances
```

### Technologies utilisées

- **Framework** : Flutter 3.x
- **State Management** : Provider
- **Base de données locale** : SQLite (sqflite)
- **HTTP Client** : http package
- **Stockage persistant** : shared_preferences

### Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.2
  sqflite: ^2.3.0
  sqflite_common_ffi: ^2.3.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  crypto: ^3.0.3
```

## Développement

### Structure de la base de données

L'application utilise SQLite pour stocker les traductions localement :

```sql
CREATE TABLE translations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  original_text TEXT NOT NULL,
  translated_text TEXT NOT NULL,
  source_language TEXT NOT NULL,
  target_language TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  from_cache INTEGER DEFAULT 0,
  alternatives TEXT,
  is_favorite INTEGER DEFAULT 0
)
```

### Mise à jour en temps réel

L'application utilise un système de compteur pour synchroniser automatiquement :
- L'historique se met à jour immédiatement après une traduction
- Les statistiques se mettent à jour en temps réel
- Les favoris sont synchronisés instantanément

## Licence

MIT License - Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou un pull request.

## Support

Pour toute question ou problème :
- Ouvrez une [issue](https://github.com/VOTRE_USERNAME/libre-translate-client/issues)
- Consultez la [documentation LibreTranslate](https://github.com/LibreTranslate/LibreTranslate)

## Remerciements

- [LibreTranslate](https://github.com/LibreTranslate/LibreTranslate) - Le moteur de traduction libre et open-source
- [Flutter](https://flutter.dev) - Le framework multiplateforme
- Tous les contributeurs qui rendent ce projet possible

## Changelog

### Version 1.0.0 (2025-12-17)

- Version initiale
- Support de Windows, macOS, Linux, Android, iOS
- Traduction avec détection automatique de langue
- Historique des traductions avec recherche
- Système de favoris
- Cache local des traductions
- Statistiques en temps réel
- Mode sombre
- Interface Material Design 3
