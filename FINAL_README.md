# 🌍 LibreTranslate - Application Multiplateforme (Version Simplifiée)

Application Flutter standalone qui se connecte directement à ton serveur LibreTranslate.

---

## 🎯 EN BREF

✅ **Une seule application** pour Windows, macOS, Linux, Android, iOS
✅ **Connexion directe** à ton serveur LibreTranslate
✅ **Aucune configuration** nécessaire pour l'utilisateur
✅ **URL codée en dur** lors de la compilation
✅ **Distribution simple** - juste un fichier à distribuer

---

## 🚀 DÉMARRAGE ULTRA-RAPIDE

### 1️⃣ Configure (une seule fois)

Ouvre `app/lib/config/app_config.dart` :

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';  // TON serveur
static const String libreTranslateApiKey = '';  // Laisse vide si pas de clé
```

### 2️⃣ Installe

```bash
cd app
flutter pub get
```

### 3️⃣ Lance

```bash
flutter run -d windows  # ou macos, linux, android, ios
```

**C'est tout ! 🎉**

---

## 📦 COMPILER POUR DISTRIBUER

### Windows
```bash
flutter build windows --release
```
→ `build\windows\runner\Release\libre_translate_app.exe`

### macOS
```bash
flutter build macos --release
```
→ `build/macos/Build/Products/Release/LibreTranslate.app`

### Linux
```bash
flutter build linux --release
```
→ `build/linux/x64/release/bundle/`

### Android
```bash
flutter build apk --release
```
→ `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
→ Puis signe dans Xcode

---

## 📚 DOCUMENTATION

| Fichier | Description |
|---------|-------------|
| **[START_HERE.md](START_HERE.md)** | 👈 Commence par ici ! |
| [README_SIMPLE.md](README_SIMPLE.md) | Documentation complète |
| [BUILD_GUIDE.md](BUILD_GUIDE.md) | Guide de compilation détaillé |
| [DOCKER_SETUP.md](DOCKER_SETUP.md) | Configuration du serveur Docker |
| [WHATS_CHANGED.md](WHATS_CHANGED.md) | Changements vs version précédente |

---

## 🏗️ ARCHITECTURE

```
┌─────────────────────────────┐
│   Application Flutter       │
│   (Windows/iOS/Android...)  │
│                             │
│   - Interface UI            │
│   - Historique local        │
│   - Cache SQLite            │
│   - Mode hors ligne         │
└─────────────┬───────────────┘
              │
              │ HTTP direct
              │ (URL codée en dur)
              │
┌─────────────▼───────────────┐
│   Serveur LibreTranslate    │
│   (Docker)                  │
│                             │
│   - 100.64.0.2:5000         │
│   - 49 langues              │
│   - Traduction ML           │
└─────────────────────────────┘
```

**Simple et efficace !**

---

## ✨ FONCTIONNALITÉS

✅ Traduction de texte
✅ Détection automatique de langue
✅ 49+ langues supportées
✅ Historique local avec recherche
✅ Favoris
✅ Mode hors ligne (cache local)
✅ Alternatives de traduction
✅ Mode sombre/clair
✅ Copie rapide au presse-papiers
✅ Interface Material Design 3

---

## 🐳 TON SERVEUR DOCKER

Ton `docker-compose.yml` actuel fonctionne parfaitement !

**Recommandations :**
- ✅ Pas besoin de clé API (VPN suffit)
- ✅ Augmente `LT_THREADS=8` pour de meilleures perfs
- ✅ Active `LT_METRICS=true` pour les statistiques

Voir **[DOCKER_SETUP.md](DOCKER_SETUP.md)** pour plus de détails.

---

## 🎨 PERSONNALISATION

### Changer l'URL du serveur

```dart
// app/lib/config/app_config.dart
static const String libreTranslateUrl = 'https://monserveur.com';
```

### Changer le nom de l'app

```yaml
# app/pubspec.yaml
name: mon_app_traduction
```

### Changer l'icône

Utilise `flutter_launcher_icons` ou remplace les icônes manuellement.

---

## 📱 DISTRIBUTION

Une fois compilée, l'application :

- ✅ Est **autonome** (aucune installation supplémentaire)
- ✅ Ne nécessite **aucune configuration** utilisateur
- ✅ Se connecte **automatiquement** à ton serveur
- ✅ Fonctionne **hors ligne** (avec cache)
- ✅ Est prête à être **distribuée**

**Partage simplement le fichier exécutable !**

---

## 💡 CAS D'USAGE

### ✅ PARFAIT POUR :

- Usage personnel
- Usage en entreprise (interne)
- Réseau privé / VPN
- Distribution à un groupe restreint
- Pas besoin de gestion multi-utilisateurs

### ❌ PAS ADAPTÉ POUR :

- Service public avec inscription
- Gestion de quotas par utilisateur
- Facturation / abonnements
- Statistiques détaillées par utilisateur

→ Pour ces cas, utilise l'API Gateway (version complète).

---

## 🛠️ DÉPANNAGE

### "Pas de connexion au serveur"

```bash
# Vérifie Docker
docker ps

# Teste l'URL
curl http://100.64.0.2:5000/languages
```

### Erreur de compilation

```bash
flutter clean
flutter pub get
flutter build <platform>
```

### Plus d'aide

Voir [README_SIMPLE.md](README_SIMPLE.md) section "Dépannage".

---

## 📊 TAILLES DES BUILDS

| Plateforme | Taille approximative |
|------------|----------------------|
| Windows    | ~25 MB              |
| macOS      | ~20 MB              |
| Linux      | ~15 MB              |
| Android    | ~15 MB              |
| iOS        | ~12 MB              |

---

## ✅ CHECKLIST AVANT DISTRIBUTION

- [ ] URL correcte dans `app_config.dart`
- [ ] Clé API configurée (si nécessaire)
- [ ] Nom de l'app personnalisé
- [ ] Icône personnalisée
- [ ] Version correcte dans `pubspec.yaml`
- [ ] Testé en mode release
- [ ] Compilé pour la plateforme cible

---

## 🎉 C'EST PRÊT !

Ton application est maintenant :

✅ **Simplifiée** - Pas de backend intermédiaire
✅ **Standalone** - Tout en un
✅ **Prête à compiler** - Un simple `flutter build`
✅ **Prête à distribuer** - Aucune config utilisateur

**Commence par [START_HERE.md](START_HERE.md) !**

---

**Questions ? Consulte la documentation ! 📚**

Bon développement ! 🚀
