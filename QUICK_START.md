# 🚀 Démarrage Rapide

Guide express pour lancer l'application en 5 minutes.

## ⚡ Étapes rapides

### 1. Modifier le secret Docker (IMPORTANT!)

Ouvre `docker-compose.yml` et change cette ligne :

```yaml
- LT_API_KEY_SECRET=ChangeThisToAStrongSecretKey123!
```

Par un mot de passe fort de ton choix !

### 2. Démarrer LibreTranslate

```bash
docker-compose up -d
```

Vérifie que ça fonctionne :

```bash
docker ps
```

Tu dois voir `libretranslate` en cours d'exécution.

### 3. Installer et démarrer l'API Gateway

```bash
cd backend
npm install
copy .env.example .env
```

**Édite le fichier `.env` et configure :**
- `MASTER_ADMIN_KEY` : Change par ton mot de passe admin

Puis :

```bash
npm run init-db
```

**⚠️ SAUVEGARDE LA CLÉ API AFFICHÉE !** Tu en auras besoin.

Démarre le serveur :

```bash
npm start
```

Le serveur doit démarrer sur `http://100.64.0.2:3000`

### 4. Lancer l'application Flutter

```bash
cd ../app
flutter pub get
flutter run -d windows
```

(Remplace `windows` par `macos`, `linux`, `android`, ou `ios` selon ta plateforme)

### 5. Configurer l'application

Au premier lancement :

1. Va dans **Paramètres** (3ème onglet)
2. Entre la **clé API** (celle sauvegardée à l'étape 3)
3. Clique sur **Sauvegarder**
4. Clique sur **Tester** pour vérifier la connexion

**C'est tout ! Tu peux maintenant traduire ! 🎉**

---

## 🧪 Test rapide

Dans l'onglet **Traduire** :

1. Sélectionne **Français** → **Anglais**
2. Entre "Bonjour le monde"
3. Clique sur **Traduire**
4. Tu devrais voir "Hello the world" ou "Hello world"

---

## 🆘 Problèmes courants

### Docker ne démarre pas

```bash
docker-compose down
docker-compose up -d
docker logs libretranslate
```

### L'API Gateway ne se connecte pas

Vérifie que LibreTranslate répond :

```bash
curl http://100.64.0.2:5000/languages
```

Si ça ne fonctionne pas, vérifie que Docker est bien démarré.

### Flutter ne compile pas

```bash
flutter clean
flutter pub get
flutter run
```

### "API key invalide"

1. Vérifie que tu as bien copié la clé complète
2. Vérifie que l'API Gateway est démarré (`npm start`)
3. Retourne dans `backend` et relance `npm run init-db` pour générer une nouvelle clé

---

## 📱 Créer des builds

### Windows

```bash
flutter build windows --release
```

L'exécutable sera dans `build\windows\runner\Release\libre_translate_app.exe`

### Android APK

```bash
flutter build apk --release
```

L'APK sera dans `build\app\outputs\flutter-apk\app-release.apk`

---

## 🔑 Créer une nouvelle clé API

Pour créer une clé API pour une autre application :

```bash
curl -X POST http://100.64.0.2:3000/api/keys \
  -H "X-Admin-Key: TonMotDePasseAdmin" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Mon autre app\", \"description\": \"Test\", \"rateLimit\": 1000}"
```

Ou utilise PowerShell sur Windows :

```powershell
$headers = @{
    "X-Admin-Key" = "TonMotDePasseAdmin"
    "Content-Type" = "application/json"
}
$body = @{
    name = "Mon autre app"
    description = "Test"
    rateLimit = 1000
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys" -Method Post -Headers $headers -Body $body
```

---

Voilà ! Tu es prêt à utiliser ton application de traduction ! 🌍✨
