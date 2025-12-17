# 🏗️ Guide de Compilation - LibreTranslate App

Guide complet pour compiler l'application pour toutes les plateformes.

---

## ⚙️ ÉTAPE 1 : Configuration (OBLIGATOIRE)

### 1. Ouvre le fichier de configuration

```
app/lib/config/app_config.dart
```

### 2. Modifie l'URL de ton serveur LibreTranslate

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';
```

Remplace par **l'URL de TON serveur** :
- Si VPN : `http://100.64.0.2:5000` (comme actuellement)
- Si local : `http://localhost:5000`
- Si distant : `https://monserveur.com`

### 3. (Optionnel) Ajoute une clé API

Si ton serveur LibreTranslate nécessite une clé API :

```dart
static const String libreTranslateApiKey = 'ta_cle_api_libretranslate';
```

Sinon, laisse vide :

```dart
static const String libreTranslateApiKey = '';
```

---

## 📦 ÉTAPE 2 : Installation des dépendances

```bash
cd app
flutter pub get
```

---

## 🖥️ Windows

### Prérequis
- Visual Studio 2022 avec "Desktop development with C++"
- Flutter SDK configuré

### Compilation

```bash
flutter build windows --release
```

### Fichier généré

```
build\windows\runner\Release\libre_translate_app.exe
```

**Pour distribuer :** Copie **tout le dossier `Release`** (contient les DLL nécessaires)

### Créer un installateur (optionnel)

Utilise **Inno Setup** ou **NSIS** pour créer un installateur `.exe`.

---

## 🍎 macOS

### Prérequis
- Xcode installé
- CocoaPods (`sudo gem install cocoapods`)

### Compilation

```bash
flutter build macos --release
```

### Fichier généré

```
build/macos/Build/Products/Release/LibreTranslate.app
```

### Pour distribuer

1. **Simple** : Compresse le `.app` en ZIP
2. **Professionnel** : Crée un DMG

```bash
# Installer create-dmg
brew install create-dmg

# Créer le DMG
create-dmg \
  --volname "LibreTranslate" \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 400 200 \
  LibreTranslate.dmg \
  build/macos/Build/Products/Release/LibreTranslate.app
```

---

## 🐧 Linux

### Prérequis

**Ubuntu/Debian :**
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

**Fedora :**
```bash
sudo dnf install clang cmake ninja-build gtk3-devel
```

### Compilation

```bash
flutter build linux --release
```

### Fichier généré

```
build/linux/x64/release/bundle/
```

**Pour distribuer :** Compresse tout le dossier `bundle/`

### Créer un package (optionnel)

**AppImage :**
```bash
# Installer appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# Créer l'AppImage (nécessite un fichier .desktop et une icône)
./appimagetool-x86_64.AppImage bundle/ LibreTranslate.AppImage
```

**Snap :**
```bash
snapcraft
```

---

## 🤖 Android

### Prérequis
- Android Studio
- Android SDK (API 21+)

### Compilation (APK)

```bash
flutter build apk --release
```

### Fichier généré

```
build/app/outputs/flutter-apk/app-release.apk
```

### Compilation (App Bundle pour Play Store)

```bash
flutter build appbundle --release
```

### Fichier généré

```
build/app/outputs/bundle/release/app-release.aab
```

### Signer l'APK (important pour distribution)

1. Crée un keystore :

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure dans `android/key.properties` :

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<chemin vers upload-keystore.jks>
```

3. Modifie `android/app/build.gradle` :

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## 📱 iOS

### Prérequis
- macOS
- Xcode
- Compte développeur Apple (pour distribution)

### Compilation

```bash
flutter build ios --release
```

### Distribution

1. Ouvre Xcode :

```bash
open ios/Runner.xcworkspace
```

2. Configure le **Bundle Identifier** unique

3. Configure le **Signing & Capabilities** avec ton compte Apple

4. Archive l'app : `Product > Archive`

5. Distribute :
   - **TestFlight** : Pour les beta-testeurs
   - **App Store** : Pour publication officielle
   - **Ad Hoc** : Pour distribution interne (100 appareils max)

---

## 🎨 Personnalisation de l'app

### Changer le nom de l'app

Édite `pubspec.yaml` :

```yaml
name: mon_app_traduction
description: Ma super app de traduction
```

### Changer l'icône

1. Remplace les icônes dans :
   - `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - `windows/runner/resources/app_icon.ico`
   - `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
   - `linux/` (selon le gestionnaire de fenêtres)

2. Ou utilise un package :

```yaml
dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## 🔧 Optimisations de build

### Réduire la taille de l'app

**Android :**
```bash
flutter build apk --release --split-per-abi
```

Génère 3 APK plus petits (arm64, armeabi, x86_64).

**iOS :**
L'App Store optimise automatiquement.

### Mode obfuscation (sécurité)

```bash
flutter build <platform> --release --obfuscate --split-debug-info=build/debug-info
```

---

## 📊 Taille approximative des builds

| Plateforme | Taille  |
|------------|---------|
| Windows    | ~25 MB  |
| macOS      | ~20 MB  |
| Linux      | ~15 MB  |
| Android    | ~15 MB  |
| iOS        | ~12 MB  |

---

## ✅ Checklist avant distribution

- [ ] L'URL LibreTranslate est correcte dans `app_config.dart`
- [ ] La clé API est configurée (si nécessaire)
- [ ] L'app a été testée en mode release
- [ ] Le nom et l'icône sont personnalisés
- [ ] Les builds sont signés (Android/iOS)
- [ ] La version dans `pubspec.yaml` est correcte

---

## 🚀 Distribution rapide

### Via GitHub Releases

1. Compile pour toutes les plateformes
2. Crée une release sur GitHub
3. Upload tous les fichiers :
   - `LibreTranslate-Windows.zip`
   - `LibreTranslate-macOS.dmg`
   - `LibreTranslate-Linux.tar.gz`
   - `LibreTranslate-Android.apk`

### Via serveur web

Héberge les fichiers et fournis les liens de téléchargement.

---

Voilà ! Tu peux maintenant compiler ton application pour toutes les plateformes ! 🎉
