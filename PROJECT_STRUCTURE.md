# 📁 Structure du Projet

```
Translate/
│
├── 📄 README.md                      # Documentation complète
├── 📄 QUICK_START.md                 # Guide de démarrage rapide
├── 📄 DOCKER_RECOMMENDATIONS.md      # Recommandations Docker
├── 📄 EXAMPLES_POWERSHELL.md         # Exemples PowerShell
├── 📄 PROJECT_STRUCTURE.md           # Ce fichier
├── 🔧 docker-compose.yml             # Configuration Docker
├── 🔧 setup.ps1                      # Script d'installation Windows
│
├── 📂 backend/                       # API Gateway Node.js
│   ├── 📂 src/
│   │   ├── 📂 config/
│   │   │   └── database.js           # Configuration SQLite
│   │   │
│   │   ├── 📂 middleware/
│   │   │   └── auth.js               # Authentification API
│   │   │
│   │   ├── 📂 services/
│   │   │   ├── apiKeyService.js      # Gestion des clés API
│   │   │   └── translationService.js # Service de traduction
│   │   │
│   │   ├── 📂 routes/
│   │   │   ├── translation.js        # Routes de traduction
│   │   │   ├── apiKeys.js            # CRUD des clés API
│   │   │   └── files.js              # Traduction de fichiers
│   │   │
│   │   ├── 📂 scripts/
│   │   │   └── initDb.js             # Initialisation DB
│   │   │
│   │   └── 📄 index.js               # Point d'entrée
│   │
│   ├── 📂 data/                      # Base de données (généré)
│   │   └── gateway.db                # SQLite database
│   │
│   ├── 📄 package.json               # Dépendances npm
│   ├── 📄 .env.example               # Template environnement
│   ├── 📄 .env                       # Configuration (à créer)
│   ├── 📄 .gitignore
│   ├── 📄 Dockerfile
│   └── 📄 README.md                  # Doc API Gateway
│
└── 📂 app/                           # Application Flutter
    ├── 📂 lib/
    │   ├── 📂 config/
    │   │   └── app_config.dart       # Configuration de l'app
    │   │
    │   ├── 📂 models/
    │   │   ├── language.dart         # Modèle Language
    │   │   └── translation.dart      # Modèle Translation
    │   │
    │   ├── 📂 services/
    │   │   ├── api_service.dart      # Communication API
    │   │   └── database_service.dart # SQLite local
    │   │
    │   ├── 📂 providers/
    │   │   ├── settings_provider.dart    # État des paramètres
    │   │   └── translation_provider.dart # État de traduction
    │   │
    │   ├── 📂 screens/
    │   │   ├── home_screen.dart      # Écran de traduction
    │   │   ├── history_screen.dart   # Historique
    │   │   └── settings_screen.dart  # Paramètres
    │   │
    │   ├── 📂 widgets/
    │   │   └── language_selector.dart # Sélecteur de langue
    │   │
    │   └── 📄 main.dart              # Point d'entrée Flutter
    │
    ├── 📂 android/                   # Configuration Android
    ├── 📂 ios/                       # Configuration iOS
    ├── 📂 windows/                   # Configuration Windows
    ├── 📂 macos/                     # Configuration macOS
    ├── 📂 linux/                     # Configuration Linux
    │
    ├── 📄 pubspec.yaml               # Dépendances Flutter
    └── 📄 .gitignore
```

---

## 🎯 Rôle de chaque composant

### 🐳 Docker (LibreTranslate)

**Fichier :** `docker-compose.yml`

**Rôle :**
- Héberge le moteur de traduction LibreTranslate
- Gère 49+ langues avec modèles de ML
- Fonctionne sur `http://100.64.0.2:5000` (VPN)

**Base de données :**
- SQLite pour les clés API LibreTranslate
- Volume persistant : `libretranslate_api_keys`
- Volume des modèles : `libretranslate_models`

---

### 🌐 Backend API Gateway (Node.js)

**Dossier :** `backend/`

**Rôle :**
- Couche de sécurité entre les apps et LibreTranslate
- Gestion avancée des clés API
- Cache intelligent des traductions
- Rate limiting
- Statistiques d'utilisation

**Base de données :** `data/gateway.db` (SQLite)

**Tables :**
1. `api_keys` - Clés API et leurs permissions
2. `translation_cache` - Cache des traductions
3. `usage_stats` - Statistiques d'utilisation

**API Endpoints :**
- `/api/translate` - Traduction de texte
- `/api/detect` - Détection de langue
- `/api/languages` - Langues disponibles
- `/api/keys` - Gestion des clés (admin)
- `/api/files/translate` - Traduction de fichiers
- `/api/cache/stats` - Statistiques du cache

---

### 📱 Application Flutter

**Dossier :** `app/`

**Rôle :**
- Interface utilisateur multiplateforme
- Gestion de l'historique local
- Mode hors ligne avec cache
- Synchronisation avec l'API Gateway

**Base de données locale :** SQLite (via sqflite)

**Table :**
- `translations` - Historique complet des traductions

**Écrans :**
1. **HomeScreen** - Traduction en temps réel
2. **HistoryScreen** - Historique et favoris
3. **SettingsScreen** - Configuration

**Services :**
- **ApiService** - Communication HTTP avec l'API Gateway
- **DatabaseService** - Gestion de la base locale SQLite

**Providers (State Management):**
- **TranslationProvider** - État de la traduction en cours
- **SettingsProvider** - Paramètres de l'app

---

## 🔄 Flux de données

### Traduction classique

```
┌─────────────────┐
│  App Flutter    │
│  (UI + Cache)   │
└────────┬────────┘
         │ 1. HTTP POST /api/translate
         │    Header: X-API-Key
         │    Body: {q, source, target}
         ▼
┌─────────────────┐
│  API Gateway    │
│  (Node.js)      │
├─────────────────┤
│ 1. Valide clé   │
│ 2. Check cache  │
│ 3. Si pas cache │
│    → appel LT   │
│ 4. Save cache   │
│ 5. Log stats    │
└────────┬────────┘
         │ 2. HTTP POST /translate
         │    Body: {q, source, target, api_key}
         ▼
┌─────────────────┐
│ LibreTranslate  │
│   (Docker)      │
├─────────────────┤
│ - Détection     │
│ - ML models     │
│ - Traduction    │
└────────┬────────┘
         │ 3. Response
         │    {translatedText, alternatives}
         ▼
┌─────────────────┐
│  API Gateway    │ ← Mise en cache
└────────┬────────┘
         │ 4. Response
         │    + fromCache: false
         ▼
┌─────────────────┐
│  App Flutter    │ ← Sauvegarde en historique local
└─────────────────┘
```

### Traduction depuis le cache

```
┌─────────────────┐
│  App Flutter    │
└────────┬────────┘
         │ 1. HTTP POST /api/translate
         ▼
┌─────────────────┐
│  API Gateway    │
├─────────────────┤
│ 1. Valide clé   │
│ 2. ✅ Cache HIT │
│ 3. Return cache │
└────────┬────────┘
         │ 2. Response RAPIDE
         │    + fromCache: true
         ▼
┌─────────────────┐
│  App Flutter    │
└─────────────────┘
```

---

## 💾 Données persistantes

### Docker Volumes

**libretranslate_api_keys** (`/app/db/`)
- Base SQLite des clés API LibreTranslate
- Créée par LibreTranslate lui-même
- À sauvegarder régulièrement

**libretranslate_models** (`/home/libretranslate/.local/`)
- Modèles de machine learning (plusieurs GB)
- Téléchargés au premier démarrage
- Persistent entre les redémarrages

### API Gateway Data

**backend/data/gateway.db**
- Base SQLite du gateway
- Clés API, cache, statistiques
- À sauvegarder régulièrement

### App Flutter Data

**Base locale (emplacement varie par plateforme) :**

- **Windows :** `%APPDATA%\com.example\libre_translate_app\`
- **macOS :** `~/Library/Application Support/com.example.libreTranslateApp/`
- **Linux :** `~/.local/share/libre_translate_app/`
- **Android :** `/data/data/com.example.libre_translate_app/`
- **iOS :** Container de l'app

**Contenu :**
- `libretranslate.db` - Historique des traductions
- `shared_preferences` - Paramètres de l'app (clé API, etc.)

---

## 🔐 Secrets et configuration

### Fichiers à NE PAS commiter (.gitignore)

**Backend :**
```
backend/.env
backend/data/
backend/node_modules/
```

**Flutter :**
```
app/.env
app/build/
```

### Fichiers sensibles à configurer

1. **docker-compose.yml**
   - `LT_API_KEY_SECRET` - Secret LibreTranslate

2. **backend/.env**
   - `MASTER_ADMIN_KEY` - Clé admin du gateway
   - `LIBRETRANSLATE_API_KEY` - Clé pour appeler LibreTranslate (si activé)

3. **app (via Settings)**
   - Clé API saisie par l'utilisateur dans l'app

---

## 📦 Dépendances principales

### Backend (Node.js)

```json
{
  "express": "API web framework",
  "better-sqlite3": "Base de données SQLite",
  "axios": "Client HTTP",
  "nanoid": "Génération de clés uniques",
  "helmet": "Sécurité HTTP",
  "cors": "Cross-Origin Resource Sharing",
  "multer": "Upload de fichiers"
}
```

### Flutter

```yaml
dependencies:
  provider: "State management"
  http: "Requêtes HTTP"
  sqflite: "Base de données locale"
  shared_preferences: "Stockage des paramètres"
  path_provider: "Chemins système"
  file_picker: "Sélection de fichiers"
  intl: "Internationalisation"
```

---

## 🚀 Ordre de démarrage

1. **Docker** (`docker-compose up -d`)
   - Démarre LibreTranslate
   - Charge les modèles de langue
   - Écoute sur `100.64.0.2:5000`

2. **API Gateway** (`npm start`)
   - Initialise la base SQLite
   - Connecte à LibreTranslate
   - Écoute sur `100.64.0.2:3000`

3. **App Flutter** (`flutter run`)
   - Lance l'application
   - Configure la clé API
   - Prête à traduire !

---

## 🛠️ Maintenance

### Logs à surveiller

**Docker :**
```bash
docker-compose logs -f libretranslate
```

**API Gateway :**
```bash
cd backend && npm start
# Les logs s'affichent dans la console
```

**Flutter :**
```bash
flutter run
# Les logs s'affichent dans la console de debug
```

### Backup recommandé

**Quotidien :**
- `backend/data/gateway.db` (clés API + cache)

**Hebdomadaire :**
- Volumes Docker (`libretranslate_api_keys`)

**Mensuel :**
- Volumes Docker complets (inclut les modèles)

---

## 📈 Évolutions futures possibles

- [ ] Interface web d'administration pour les clés API
- [ ] Système de quotas par clé API
- [ ] Support de la traduction temps réel (streaming)
- [ ] Extension navigateur
- [ ] API de suggestions de traduction
- [ ] Intégration avec d'autres moteurs de traduction
- [ ] Mode collaboratif (partage de traductions)
- [ ] Export/Import de l'historique

---

Voilà ! Tu as maintenant une vue complète de l'architecture du projet. 🎉
