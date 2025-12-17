# API Gateway - LibreTranslate

API Gateway sécurisée pour LibreTranslate avec gestion des clés API, cache et statistiques.

## 🚀 Installation

```bash
npm install
cp .env.example .env
# Éditer .env avec vos paramètres
npm run init-db
npm start
```

## 📡 Endpoints

### Traduction

**POST** `/api/translate`

```bash
curl -X POST http://100.64.0.2:3000/api/translate \
  -H "X-API-Key: ltk_xxxxx" \
  -H "Content-Type: application/json" \
  -d '{"q":"Hello","source":"en","target":"fr"}'
```

### Détection de langue

**POST** `/api/detect`

```bash
curl -X POST http://100.64.0.2:3000/api/detect \
  -H "X-API-Key: ltk_xxxxx" \
  -H "Content-Type: application/json" \
  -d '{"q":"Bonjour"}'
```

### Langues disponibles

**GET** `/api/languages`

```bash
curl http://100.64.0.2:3000/api/languages
```

## 🔑 Gestion des clés API (Admin)

### Créer une clé

**POST** `/api/keys`

```bash
curl -X POST http://100.64.0.2:3000/api/keys \
  -H "X-Admin-Key: votre_admin_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mon App",
    "description": "Clé pour mon application",
    "rateLimit": 1000
  }'
```

### Lister les clés

**GET** `/api/keys`

```bash
curl http://100.64.0.2:3000/api/keys \
  -H "X-Admin-Key: votre_admin_key"
```

### Révoquer une clé

**POST** `/api/keys/:id/revoke`

```bash
curl -X POST http://100.64.0.2:3000/api/keys/1/revoke \
  -H "X-Admin-Key: votre_admin_key"
```

### Supprimer une clé

**DELETE** `/api/keys/:id`

```bash
curl -X DELETE http://100.64.0.2:3000/api/keys/1 \
  -H "X-Admin-Key: votre_admin_key"
```

### Statistiques d'une clé

**GET** `/api/keys/:id/stats`

```bash
curl http://100.64.0.2:3000/api/keys/1/stats \
  -H "X-Admin-Key: votre_admin_key"
```

## 📊 Cache

### Statistiques du cache

**GET** `/api/cache/stats`

```bash
curl http://100.64.0.2:3000/api/cache/stats \
  -H "X-API-Key: ltk_xxxxx"
```

### Nettoyer le cache expiré

**DELETE** `/api/cache/clean`

```bash
curl -X DELETE http://100.64.0.2:3000/api/cache/clean \
  -H "X-API-Key: ltk_xxxxx"
```

## 📁 Traduction de fichiers

**POST** `/api/files/translate`

```bash
curl -X POST http://100.64.0.2:3000/api/files/translate \
  -H "X-API-Key: ltk_xxxxx" \
  -F "file=@document.txt" \
  -F "source=fr" \
  -F "target=en" \
  --output translated_document.txt
```

## 🔒 Sécurité

- Toutes les routes de traduction nécessitent une clé API valide
- Les routes admin nécessitent la clé admin (`MASTER_ADMIN_KEY`)
- Rate limiting : 100 requêtes / 15 minutes par IP
- Les clés API peuvent avoir des limites personnalisées

## ⚙️ Configuration (.env)

```env
PORT=3000
NODE_ENV=production
LIBRETRANSLATE_URL=http://100.64.0.2:5000
DATABASE_PATH=./data/gateway.db
MASTER_ADMIN_KEY=VotreMotDePasseAdminFort
CACHE_ENABLED=true
CACHE_TTL_SECONDS=3600
```

## 🛠️ Scripts

- `npm start` - Démarrer le serveur
- `npm run dev` - Démarrer en mode développement (nodemon)
- `npm run init-db` - Initialiser la base de données et créer une clé de test

## 📂 Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js         # Configuration SQLite
│   ├── middleware/
│   │   └── auth.js             # Middleware d'authentification
│   ├── services/
│   │   ├── apiKeyService.js    # Gestion des clés API
│   │   └── translationService.js # Service de traduction
│   ├── routes/
│   │   ├── translation.js      # Routes de traduction
│   │   ├── apiKeys.js          # Routes de gestion des clés
│   │   └── files.js            # Routes de fichiers
│   ├── scripts/
│   │   └── initDb.js           # Script d'initialisation
│   └── index.js                # Point d'entrée
├── data/                        # Base de données (créé automatiquement)
├── package.json
├── .env                         # Configuration (à créer)
└── Dockerfile
```

## 📊 Base de données

### Tables

#### `api_keys`
- Stocke les clés API
- Champs : id, key, name, description, created_at, last_used_at, is_active, rate_limit, usage_count

#### `translation_cache`
- Cache des traductions
- Champs : id, text_hash, source_lang, target_lang, original_text, translated_text, created_at, access_count

#### `usage_stats`
- Statistiques d'utilisation
- Champs : id, api_key, endpoint, timestamp, response_time, success

## 🐳 Docker

Pour déployer avec Docker :

```bash
docker build -t translate-gateway .
docker run -d -p 3000:3000 -v $(pwd)/data:/app/data translate-gateway
```

## 🔍 Monitoring

Accédez à la racine de l'API pour voir les endpoints disponibles :

```bash
curl http://100.64.0.2:3000/
```

Health check :

```bash
curl http://100.64.0.2:3000/health
```
