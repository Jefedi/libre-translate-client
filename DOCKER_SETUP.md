# 🐳 Configuration Docker - LibreTranslate

Guide pour configurer correctement ton serveur LibreTranslate.

---

## ✅ Configuration actuelle (fonctionne déjà !)

Ton `docker-compose.yml` est déjà configuré et fonctionne parfaitement avec l'application.

**Points importants :**
- ✅ Serveur accessible sur `100.64.0.2:5000` (via VPN)
- ✅ 49 langues chargées
- ✅ Interface web activée
- ✅ Traduction de fichiers activée

---

## 🔐 Dois-je activer l'authentification par clé API ?

### Option 1 : **SANS clé API (recommandé pour usage privé)**

**Avantages :**
- Simple
- Pas besoin de gérer des clés
- Ton VPN sécurise déjà l'accès

**Configuration :**

Laisse tel quel dans `docker-compose.yml` :

```yaml
environment:
  - LT_API_KEYS=false  # ou retire la ligne complètement
```

Dans `app/lib/config/app_config.dart` :

```dart
static const String libreTranslateApiKey = '';  # Laisse vide
```

**C'est ce que je recommande pour ton cas !**

---

### Option 2 : **AVEC clé API (pour usage partagé)**

**Avantages :**
- Contrôle d'accès par clé
- Statistiques d'utilisation
- Plusieurs utilisateurs avec différentes clés

**Configuration :**

Dans `docker-compose.yml` :

```yaml
environment:
  # Activer les clés API
  - LT_API_KEYS=true
  - LT_REQUIRE_API_KEY_SECRET=true
  - LT_API_KEY_SECRET=ChangeThisToAVeryStrongSecret123!  # ⚠️ CHANGE MOI !
  - LT_API_KEYS_DB_PATH=/app/db/api_keys.db
```

Redémarre Docker :

```bash
docker-compose down
docker-compose up -d
```

Génère une clé API :

```bash
docker exec -it libretranslate python manage.py --api-keys
```

Copie la clé générée et ajoute-la dans `app/lib/config/app_config.dart` :

```dart
static const String libreTranslateApiKey = 'ta_cle_generee_ici';
```

---

## 🚀 Optimisations recommandées

### 1. Augmenter les performances

Si tu as un bon CPU (4+ cœurs), augmente les threads :

```yaml
environment:
  - LT_THREADS=8  # Au lieu de 4
```

### 2. Limiter les langues (économise de la RAM)

Si tu n'utilises que certaines langues :

```yaml
environment:
  - LT_LOAD_ONLY=fr,en,es,de,it,pt  # Seulement ces langues
```

**RAM économisée :** ~50-70%

### 3. Limites de sécurité (optionnel)

```yaml
environment:
  - LT_CHAR_LIMIT=50000       # Max 50k caractères par requête
  - LT_REQ_LIMIT=100          # 100 req/min sans clé API
  - LT_BATCH_LIMIT=100        # Max 100 textes en batch
```

---

## 📊 Configuration optimale (sans clé API)

Voici ma recommandation pour ton usage :

```yaml
services:
  libretranslate:
    container_name: libretranslate
    image: libretranslate/libretranslate:latest
    ports:
      - 100.64.0.2:5000:5000
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "./venv/bin/python scripts/healthcheck.py"]
      interval: 10s
      timeout: 4s
      retries: 4
      start_period: 5s
    tty: true
    environment:
      # Modèles
      - LT_UPDATE_MODELS=true

      # Configuration réseau
      - LT_HOST=0.0.0.0
      - LT_PORT=5000
      - LT_THREADS=8  # ← Augmenté pour de meilleures perfs

      # Limites (protection)
      - LT_CHAR_LIMIT=50000
      - LT_REQ_LIMIT=100

      # Interface
      - LT_DISABLE_WEB_UI=false
      - LT_FRONTEND_LANGUAGE_SOURCE=fr
      - LT_FRONTEND_LANGUAGE_TARGET=en

      # Features
      - LT_DISABLE_FILES_TRANSLATION=false
      - LT_SUGGESTIONS=true
      - LT_METRICS=true  # ← Pour les statistiques

    volumes:
      - libretranslate_api_keys:/app/db
      - libretranslate_models:/home/libretranslate/.local:rw

    networks:
      - translate_network

volumes:
  libretranslate_api_keys:
    driver: local
  libretranslate_models:
    driver: local

networks:
  translate_network:
    driver: bridge
```

---

## 🔄 Appliquer les modifications

Après avoir modifié `docker-compose.yml` :

```bash
docker-compose down
docker-compose up -d
```

Vérifie que ça fonctionne :

```bash
docker ps
docker logs libretranslate
```

Teste dans ton navigateur :

```
http://100.64.0.2:5000/languages
```

---

## 📈 Monitoring

### Voir les logs

```bash
docker-compose logs -f libretranslate
```

### Statistiques du container

```bash
docker stats libretranslate
```

### Tester la traduction

```bash
curl -X POST http://100.64.0.2:5000/translate \
  -H "Content-Type: application/json" \
  -d '{
    "q": "Bonjour le monde",
    "source": "fr",
    "target": "en"
  }'
```

---

## 🛠️ Dépannage

### Container ne démarre pas

```bash
docker-compose down
docker-compose up
# Regarde les erreurs
```

### Manque de RAM

Limite les langues :

```yaml
- LT_LOAD_ONLY=fr,en,es,de
```

### Traductions lentes

Augmente les threads :

```yaml
- LT_THREADS=8
```

---

## 📝 Résumé de ma recommandation

Pour ton usage (VPN privé, accès personnel) :

1. ✅ **PAS de clé API** (ton VPN suffit)
2. ✅ **Augmente LT_THREADS à 8**
3. ✅ **Active LT_METRICS=true** (pour voir les stats)
4. ✅ **Garde toutes les langues** (tu as de la RAM)

L'application Flutter est déjà configurée pour ça !

---

**C'est tout ! Ton serveur est prêt. 🚀**
