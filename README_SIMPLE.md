# 🌍 LibreTranslate - Application Multiplateforme

Application de traduction standalone qui se connecte directement à ton serveur LibreTranslate.

## 🎯 Ce que c'est

Une application **Flutter** multiplateforme (Windows, macOS, Linux, Android, iOS) qui se connecte **directement** à ton serveur LibreTranslate sans nécessiter d'API Gateway ou de configuration utilisateur.

**L'URL du serveur est codée en dur** dans l'application lors de la compilation.

---

## ✨ Fonctionnalités

✅ Traduction de texte avec détection automatique de langue
✅ Support de 49+ langues (selon ton serveur LibreTranslate)
✅ Historique local des traductions avec recherche
✅ Favoris
✅ Mode hors ligne (cache local SQLite)
✅ Alternatives de traduction
✅ Mode sombre/clair
✅ Interface Material Design 3

---

## 🚀 Démarrage rapide

### 1. Configure ton serveur LibreTranslate

Ouvre `app/lib/config/app_config.dart` et modifie :

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';  // TON serveur
static const String libreTranslateApiKey = '';  // Ta clé API (si nécessaire)
```

### 2. Installe les dépendances

```bash
cd app
flutter pub get
```

### 3. Lance l'application

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 📦 Compiler pour distribution

Voir le guide complet : **[BUILD_GUIDE.md](BUILD_GUIDE.md)**

### Windows
```bash
flutter build windows --release
```
Fichier : `build\windows\runner\Release\libre_translate_app.exe`

### macOS
```bash
flutter build macos --release
```
Fichier : `build/macos/Build/Products/Release/LibreTranslate.app`

### Linux
```bash
flutter build linux --release
```
Fichier : `build/linux/x64/release/bundle/`

### Android
```bash
flutter build apk --release
```
Fichier : `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
Puis ouvre dans Xcode pour signer.

---

## 🐳 Configuration Docker de LibreTranslate

Ton `docker-compose.yml` actuel fonctionne déjà parfaitement !

### Si tu veux ajouter une clé API (optionnel)

```yaml
environment:
  - LT_API_KEYS=true
  - LT_REQUIRE_API_KEY_SECRET=true
  - LT_API_KEY_SECRET=TonMotDePasseSecretFort123!
```

Puis génère une clé API et ajoute-la dans `app_config.dart`.

### Si tu ne veux PAS de clé API (recommandé pour usage privé)

Laisse tel quel :

```yaml
environment:
  - LT_API_KEYS=false  # ou retire la ligne
```

Et laisse vide dans `app_config.dart` :

```dart
static const String libreTranslateApiKey = '';
```

---

## 📁 Structure du projet

```
Translate/
├── app/                           # Application Flutter
│   ├── lib/
│   │   ├── config/
│   │   │   └── app_config.dart    # ⚠️ CONFIGURE ICI !
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── docker-compose.yml             # Ton serveur LibreTranslate
├── README_SIMPLE.md               # Ce fichier
└── BUILD_GUIDE.md                 # Guide de compilation
```

---

## 🔧 Personnaliser l'app

### Changer le nom

Édite `app/pubspec.yaml` :

```yaml
name: mon_app_traduction
description: Mon app de traduction perso
```

### Changer l'icône

Utilise `flutter_launcher_icons` :

```yaml
dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  windows: true
  macos: true
  linux: true
  image_path: "assets/icon/icon.png"
```

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## 💡 Comment ça fonctionne

```
┌─────────────────────────┐
│   Application Flutter   │
│  (Windows/iOS/Android)  │
│                         │
│  - Interface UI         │
│  - Historique local     │
│  - Cache SQLite         │
└───────────┬─────────────┘
            │
            │ HTTP direct
            │
┌───────────▼─────────────┐
│  Serveur LibreTranslate │
│   (Docker)              │
│                         │
│  - Traduction           │
│  - 49 langues           │
│  - 100.64.0.2:5000      │
└─────────────────────────┘
```

**Pas d'API Gateway, pas de configuration utilisateur !**

---

## ❓ FAQ

### L'app peut fonctionner sans connexion ?

Oui ! Les traductions déjà effectuées sont en cache local et fonctionnent hors ligne.

### Dois-je installer quelque chose sur les appareils utilisateurs ?

Non, juste l'application compilée. Aucune configuration nécessaire.

### Puis-je distribuer cette app ?

Oui ! Une fois compilée, l'app est standalone et peut être distribuée librement.

### Comment changer l'URL du serveur après compilation ?

Tu ne peux pas. L'URL est codée en dur. Tu dois recompiler l'app avec la nouvelle URL.

### Puis-je avoir plusieurs apps pour différents serveurs ?

Oui ! Compile avec des URL différentes dans `app_config.dart` et change le nom de l'app.

---

## 🛠️ Dépannage

### "Pas de connexion au serveur"

- Vérifie que ton serveur LibreTranslate est démarré : `docker ps`
- Vérifie l'URL dans `app_config.dart`
- Test l'URL dans ton navigateur : `http://100.64.0.2:5000/languages`

### Erreur de compilation

```bash
flutter clean
flutter pub get
flutter build <platform>
```

### "API key invalide"

- Si tu n'utilises pas de clé API, laisse vide dans `app_config.dart`
- Si tu utilises une clé, vérifie qu'elle est correcte

---

## 📖 Documentation

- **[BUILD_GUIDE.md](BUILD_GUIDE.md)** - Guide complet de compilation
- **[app/README.md](app/README.md)** - Documentation de l'application Flutter

---

## 🎉 C'est tout !

Ton application est prête à être compilée et distribuée. Les utilisateurs n'auront rien à configurer, elle se connectera automatiquement à ton serveur LibreTranslate.

Bon développement ! 🚀
