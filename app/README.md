# 🌍 LibreTranslate - Application Multiplateforme

Application de traduction standalone qui se connecte directement à votre serveur LibreTranslate.

## 📋 Configuration

### 1. Configurer l'URL de ton serveur

Ouvre `lib/config/app_config.dart` et modifie :

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';  // TON serveur
```

### 2. (Optionnel) Ajouter une clé API

Si ton serveur LibreTranslate nécessite une clé API (`LT_API_KEYS=true` dans Docker), ajoute-la ici :

```dart
static const String libreTranslateApiKey = 'ta_cle_api_ici';
```

Sinon, laisse vide :

```dart
static const String libreTranslateApiKey = '';
```

## 🚀 Compiler l'application

### Windows

```bash
flutter build windows --release
```

**Fichier généré :** `build\windows\runner\Release\libre_translate_app.exe`

### macOS

```bash
flutter build macos --release
```

**Fichier généré :** `build/macos/Build/Products/Release/LibreTranslate.app`

### Linux

```bash
flutter build linux --release
```

**Fichier généré :** `build/linux/x64/release/bundle/`

### Android (APK)

```bash
flutter build apk --release
```

**Fichier généré :** `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Ensuite ouvre dans Xcode pour signer et distribuer.

---

## 📱 Utilisation

L'application se connecte automatiquement à ton serveur LibreTranslate configuré. Aucune configuration n'est nécessaire dans l'interface.

### Fonctionnalités

✅ **Traduction** de texte avec détection automatique
✅ **Historique** local avec recherche
✅ **Favoris** pour retrouver rapidement
✅ **Mode hors ligne** grâce au cache local
✅ **Alternatives** de traduction
✅ **Mode sombre/clair**
✅ **Multiplateforme** (Windows, macOS, Linux, Android, iOS)

---

## 🔧 Modifications pour ton serveur Docker

### Si tu utilises une clé API

Active dans `docker-compose.yml` :

```yaml
environment:
  - LT_API_KEYS=true
  - LT_REQUIRE_API_KEY_SECRET=true
  - LT_API_KEY_SECRET=TonMotDePasseSecretFort
```

Puis génère une clé API :

```bash
docker exec -it libretranslate python -m libretranslate --api-keys
```

Et ajoute-la dans `app_config.dart`.

### Si tu n'utilises PAS de clé API

Laisse tel quel dans `docker-compose.yml` :

```yaml
environment:
  - LT_API_KEYS=false  # ou retire complètement la ligne
```

Et laisse vide dans `app_config.dart` :

```dart
static const String libreTranslateApiKey = '';
```

---

## 📦 Structure

```
app/
├── lib/
│   ├── config/
│   │   └── app_config.dart        # ⚠️ CONFIGURE ICI !
│   ├── models/
│   ├── services/
│   │   ├── api_service.dart       # Communication avec LibreTranslate
│   │   └── database_service.dart  # Base locale SQLite
│   ├── providers/
│   ├── screens/
│   └── main.dart
└── pubspec.yaml
```

---

## 🛠️ Installation des dépendances

```bash
flutter pub get
```

---

## ▶️ Lancer en mode développement

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

---

## 📝 Notes importantes

1. **L'URL est codée en dur** dans l'application compilée
2. **Aucune configuration utilisateur** n'est nécessaire
3. **L'historique est stocké localement** sur chaque appareil
4. **Le cache permet le mode hors ligne** pour les traductions déjà effectuées

---

## 🎯 Distribution

Une fois compilée, l'application est **autonome** et **prête à distribuer**. Les utilisateurs n'ont rien à configurer, elle se connecte automatiquement à ton serveur LibreTranslate.

### Windows
Distribue le dossier `build\windows\runner\Release\` complet.

### macOS
Distribue le fichier `.app` ou crée un `.dmg`.

### Linux
Distribue le dossier `bundle/` ou crée un package (snap, flatpak, deb).

### Android
Distribue l'APK ou publie sur le Play Store.

### iOS
Distribue via TestFlight ou l'App Store.

---

Bon développement ! 🚀
