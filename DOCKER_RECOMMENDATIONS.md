# 🐳 Recommandations pour la configuration Docker

## ⚠️ Modifications OBLIGATOIRES

### 1. Changer le secret API

**AVANT :**
```yaml
- LT_API_KEY_SECRET=ChangeThisToAStrongSecretKey123!
```

**APRÈS :**
```yaml
- LT_API_KEY_SECRET=VotreMotDePasseSuperSecretEtComplexe2024!
```

**Pourquoi ?**
- Ce secret protège les clés API générées par LibreTranslate
- Utilise au moins 32 caractères avec majuscules, minuscules, chiffres et symboles

---

## 🚀 Modifications recommandées pour les performances

### 1. Augmenter les threads

```yaml
environment:
  - LT_THREADS=8  # Au lieu de 4
```

**Comment choisir ?**
- Regarde le nombre de cœurs de ton CPU
- Mets 1-2 threads par cœur
- Exemple : CPU 4 cœurs → 6-8 threads

### 2. Activer le traitement en batch

```yaml
environment:
  - LT_BATCH_LIMIT=100
```

**Pourquoi ?**
- Permet de traduire plusieurs textes en une seule requête
- Améliore les performances pour les applications qui traduisent beaucoup

### 3. Optimiser le chargement des modèles

```yaml
environment:
  - LT_UPDATE_MODELS=true  # Déjà activé ✅
  - LT_LOAD_ONLY=fr,en,es,de,it  # Optionnel : charger seulement certaines langues
```

**Note :** Si tu utilises seulement quelques langues, charge uniquement celles-ci pour économiser la RAM

---

## 🔒 Modifications recommandées pour la sécurité

### 1. Activer l'authentification obligatoire

```yaml
environment:
  - LT_REQUIRE_API_KEY_SECRET=true  # Déjà activé ✅
  - LT_API_KEY_SECRET=VotreSecretFort
```

### 2. Configurer les limites de requêtes

```yaml
environment:
  - LT_REQ_LIMIT=100          # 100 requêtes/minute sans clé API
  - LT_CHAR_LIMIT=50000       # Max 50k caractères par requête
  - LT_BATCH_LIMIT=100        # Max 100 textes en batch
```

**Pourquoi ?**
- Protège contre les abus
- Empêche la surcharge du serveur
- LT_REQ_LIMIT s'applique aux requêtes sans clé API valide

### 3. Limiter l'accès réseau

```yaml
ports:
  - 100.64.0.2:5000:5000  # Déjà configuré ✅ - accessible uniquement via VPN
```

**Pourquoi ?**
- Ton serveur est uniquement accessible via le VPN (100.64.0.2)
- Pas d'accès public direct
- L'API Gateway sert de couche de sécurité supplémentaire

---

## 📊 Modifications pour le monitoring

### 1. Activer les métriques

```yaml
environment:
  - LT_METRICS=true
  - LT_METRICS_SLOW_REQUEST_THRESHOLD=1000  # Log si requête > 1 seconde
```

### 2. Configurer le healthcheck

```yaml
healthcheck:
  test: ["CMD-SHELL", "./venv/bin/python scripts/healthcheck.py"]
  interval: 10s      # Vérifier toutes les 10s
  timeout: 4s        # Timeout après 4s
  retries: 4         # 4 tentatives avant d'être considéré comme "unhealthy"
  start_period: 5s   # Déjà configuré ✅
```

---

## 💾 Configuration optimale des volumes

```yaml
volumes:
  libretranslate_api_keys:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: C:/LibreTranslate/api_keys  # Backup facile

  libretranslate_models:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: C:/LibreTranslate/models    # Backup facile
```

**Avantages :**
- Backup plus facile
- Pas de perte de données si tu recrées le container
- Modèles persistent entre les redémarrages

---

## 🌍 Configuration des langues

### Option 1 : Toutes les langues (par défaut)

```yaml
environment:
  - LT_LOAD_ONLY=  # Vide = toutes les langues
```

**RAM nécessaire :** ~8-16 GB

### Option 2 : Langues spécifiques (économie de RAM)

```yaml
environment:
  - LT_LOAD_ONLY=fr,en,es,de,it,pt,ru,zh,ja,ar
```

**RAM nécessaire :** ~2-4 GB

**Langues les plus utilisées :**
- `fr` - Français
- `en` - English
- `es` - Español
- `de` - Deutsch
- `it` - Italiano
- `pt` - Português
- `ru` - Русский
- `zh` - 中文 (Chinois)
- `ja` - 日本語 (Japonais)
- `ar` - العربية (Arabe)

---

## 🔧 Configuration réseau avancée

### Créer un réseau dédié

```yaml
networks:
  translate_network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
```

### Assigner une IP fixe à LibreTranslate

```yaml
services:
  libretranslate:
    networks:
      translate_network:
        ipv4_address: 172.20.0.10
```

---

## 🔄 Déploiement avec API Gateway intégré

Si tu veux déployer l'API Gateway dans le même docker-compose :

```yaml
services:
  libretranslate:
    # ... configuration existante ...

  api_gateway:
    container_name: translate_api_gateway
    build: ./backend
    ports:
      - 100.64.0.2:3000:3000
    restart: unless-stopped
    environment:
      - LIBRETRANSLATE_URL=http://libretranslate:5000
      - NODE_ENV=production
      - PORT=3000
      - MASTER_ADMIN_KEY=${ADMIN_KEY}  # Depuis .env
    volumes:
      - gateway_data:/app/data
    depends_on:
      libretranslate:
        condition: service_healthy
    networks:
      - translate_network

volumes:
  libretranslate_api_keys:
    driver: local
  libretranslate_models:
    driver: local
  gateway_data:
    driver: local

networks:
  translate_network:
    driver: bridge
```

Puis crée un fichier `.env` à la racine :

```env
ADMIN_KEY=TonMotDePasseAdminTresFort
```

---

## 📈 Configuration production complète

Voici une configuration optimale pour la production :

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
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    tty: true
    environment:
      # Sécurité
      - LT_API_KEYS=true
      - LT_REQUIRE_API_KEY_SECRET=true
      - LT_API_KEY_SECRET=${LIBRETRANSLATE_SECRET}
      - LT_API_KEYS_DB_PATH=/app/db/api_keys.db

      # Performance
      - LT_THREADS=8
      - LT_BATCH_LIMIT=100
      - LT_UPDATE_MODELS=true

      # Langues (ajuste selon tes besoins)
      - LT_LOAD_ONLY=fr,en,es,de,it,pt,ru,zh,ja,ar

      # Limites
      - LT_CHAR_LIMIT=50000
      - LT_REQ_LIMIT=100

      # Configuration
      - LT_HOST=0.0.0.0
      - LT_PORT=5000

      # Interface
      - LT_DISABLE_WEB_UI=false
      - LT_FRONTEND_LANGUAGE_SOURCE=fr
      - LT_FRONTEND_LANGUAGE_TARGET=en

      # Features
      - LT_DISABLE_FILES_TRANSLATION=false
      - LT_SUGGESTIONS=true
      - LT_METRICS=true

    volumes:
      - ./volumes/api_keys:/app/db
      - ./volumes/models:/home/libretranslate/.local:rw

    networks:
      - translate_network

volumes:
  # Volumes externes pour backup facile

networks:
  translate_network:
    driver: bridge
```

---

## 🛠️ Commandes utiles

### Voir les logs

```bash
docker-compose logs -f libretranslate
```

### Redémarrer le service

```bash
docker-compose restart libretranslate
```

### Mettre à jour LibreTranslate

```bash
docker-compose pull
docker-compose up -d
```

### Sauvegarder les données

```bash
# Windows PowerShell
Copy-Item -Recurse -Path "C:\LibreTranslate\*" -Destination "D:\Backup\LibreTranslate\"

# Linux/Mac
cp -r /path/to/volumes /path/to/backup/
```

### Nettoyer et redémarrer

```bash
docker-compose down
docker-compose up -d
```

---

## 🎯 Récapitulatif des priorités

### 🔴 CRITIQUE (à faire immédiatement)

1. ✅ Changer `LT_API_KEY_SECRET`
2. ✅ Activer `LT_REQUIRE_API_KEY_SECRET=true`

### 🟡 RECOMMANDÉ (améliore les performances)

3. Augmenter `LT_THREADS` selon ton CPU
4. Configurer `LT_CHAR_LIMIT` et `LT_REQ_LIMIT`
5. Activer `LT_METRICS=true`

### 🟢 OPTIONNEL (optimisations)

6. Limiter les langues avec `LT_LOAD_ONLY`
7. Configurer les volumes pour backup facile
8. Déployer l'API Gateway dans Docker

---

**Besoin d'aide ?** Vérifie la documentation officielle : https://github.com/LibreTranslate/LibreTranslate
