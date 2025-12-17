# 🎯 COMMENCE ICI

## ⚡ Configuration en 3 étapes

### ✅ ÉTAPE 1 : Configure l'URL de ton serveur

Ouvre ce fichier :

```
app/lib/config/app_config.dart
```

Modifie cette ligne :

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';
```

**Remplace par l'URL de TON serveur LibreTranslate !**

---

### ✅ ÉTAPE 2 : Installe les dépendances

```bash
cd app
flutter pub get
```

---

### ✅ ÉTAPE 3 : Lance l'application

**Windows :**
```bash
flutter run -d windows
```

**macOS :**
```bash
flutter run -d macos
```

**Linux :**
```bash
flutter run -d linux
```

**Android :**
```bash
flutter run -d android
```

**iOS :**
```bash
flutter run -d ios
```

---

## 🎉 C'est tout !

L'application devrait se lancer et se connecter à ton serveur LibreTranslate.

---

## 📦 Pour compiler (pour distribuer)

Voir le fichier **[BUILD_GUIDE.md](BUILD_GUIDE.md)** pour les instructions complètes.

**Compilation rapide :**

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## ❓ Problèmes ?

### "Pas de connexion au serveur"

1. Vérifie que Docker est démarré : `docker ps`
2. Vérifie l'URL dans `app/lib/config/app_config.dart`
3. Teste dans ton navigateur : `http://100.64.0.2:5000/languages`

### "Flutter command not found"

Installe Flutter SDK : https://flutter.dev/docs/get-started/install

### Autres problèmes

Consulte **[README_SIMPLE.md](README_SIMPLE.md)** pour plus d'infos.

---

**Bon développement ! 🚀**
