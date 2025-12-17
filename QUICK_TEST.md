# ⚡ Test Rapide

Guide pour tester rapidement que tout fonctionne.

---

## 🧪 Test 1 : Serveur LibreTranslate

Vérifie que ton serveur Docker fonctionne :

```bash
# Vérifie que le container est démarré
docker ps

# Tu dois voir "libretranslate" dans la liste
```

### Test dans le navigateur

Ouvre dans ton navigateur :

```
http://100.64.0.2:5000
```

Tu devrais voir l'interface web de LibreTranslate.

### Test API

```bash
curl http://100.64.0.2:5000/languages
```

Tu dois recevoir une liste de langues en JSON.

**Si ça fonctionne → Continue ✅**

**Si ça ne fonctionne pas :**

```bash
# Démarre le serveur
docker-compose up -d

# Attends 30 secondes
# Puis teste à nouveau
```

---

## 🧪 Test 2 : Configuration de l'app

Vérifie que l'URL est correcte :

```bash
cat app/lib/config/app_config.dart
```

Tu dois voir :

```dart
static const String libreTranslateUrl = 'http://100.64.0.2:5000';
```

**Si l'URL est correcte → Continue ✅**

---

## 🧪 Test 3 : Dépendances Flutter

```bash
cd app
flutter doctor
```

Tu devrais voir :

```
✓ Flutter (Channel stable, ...)
✓ Windows/macOS/Linux toolchain
```

Si des erreurs :

```bash
flutter clean
flutter pub get
```

**Si tout est vert → Continue ✅**

---

## 🧪 Test 4 : Lance l'application

### Sur Windows :

```bash
flutter run -d windows
```

### Sur macOS :

```bash
flutter run -d macos
```

### Sur Linux :

```bash
flutter run -d linux
```

**L'application devrait se lancer ✅**

---

## 🧪 Test 5 : Test de traduction

Dans l'application :

1. **Laisse** "Détection auto" → "English"
2. **Entre** : `Bonjour le monde`
3. **Clique** sur "Traduire"

**Résultat attendu :**

```
Hello the world
ou
Hello world
```

**Si la traduction fonctionne → SUCCÈS ! 🎉**

---

## ❌ Dépannage rapide

### Erreur "Pas de connexion au serveur"

```bash
# 1. Vérifie Docker
docker ps

# 2. Vérifie l'URL dans app_config.dart
cat app/lib/config/app_config.dart

# 3. Teste avec curl
curl http://100.64.0.2:5000/languages

# 4. Redémarre Docker
docker-compose restart
```

### Erreur "Flutter command not found"

Installe Flutter : https://flutter.dev/docs/get-started/install

### L'app se lance mais crash

```bash
cd app
flutter clean
flutter pub get
flutter run -d windows  # ou ta plateforme
```

### Traduction ne fonctionne pas

Vérifie les logs Docker :

```bash
docker logs libretranslate
```

---

## ✅ Tous les tests passent ?

**Parfait ! Tu es prêt à compiler ! 🚀**

```bash
# Compile pour distribution
flutter build windows --release

# Trouve ton executable
ls build/windows/runner/Release/
```

---

## 📊 Résumé

| Test | Description | Status |
|------|-------------|--------|
| 1 | Docker fonctionne | [ ] |
| 2 | URL configurée | [ ] |
| 3 | Flutter installé | [ ] |
| 4 | App se lance | [ ] |
| 5 | Traduction fonctionne | [ ] |

**Si tout est ✅ → C'EST BON ! 🎉**

---

**Prochaines étapes :**
- Voir [BUILD_GUIDE.md](BUILD_GUIDE.md) pour compiler
- Voir [README_SIMPLE.md](README_SIMPLE.md) pour plus de détails
