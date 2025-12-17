# 🚀 Script d'installation automatique - LibreTranslate App
# Pour Windows PowerShell

Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                       ║" -ForegroundColor Cyan
Write-Host "║   🌍 LibreTranslate - Installation automatique       ║" -ForegroundColor Cyan
Write-Host "║                                                       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Fonction pour vérifier si une commande existe
function Test-Command {
    param($command)
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Vérifier Docker
Write-Host "🔍 Vérification de Docker..." -ForegroundColor Yellow
if (-not (Test-Command "docker")) {
    Write-Host "❌ Docker n'est pas installé !" -ForegroundColor Red
    Write-Host "   Télécharge Docker Desktop : https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker détecté" -ForegroundColor Green

# Vérifier Node.js
Write-Host "🔍 Vérification de Node.js..." -ForegroundColor Yellow
if (-not (Test-Command "node")) {
    Write-Host "❌ Node.js n'est pas installé !" -ForegroundColor Red
    Write-Host "   Télécharge Node.js : https://nodejs.org/" -ForegroundColor Red
    exit 1
}
$nodeVersion = node --version
Write-Host "✅ Node.js détecté : $nodeVersion" -ForegroundColor Green

# Vérifier Flutter
Write-Host "🔍 Vérification de Flutter..." -ForegroundColor Yellow
if (-not (Test-Command "flutter")) {
    Write-Host "⚠️  Flutter n'est pas installé (optionnel pour l'instant)" -ForegroundColor Yellow
} else {
    $flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✅ Flutter détecté : $flutterVersion" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ÉTAPE 1 : Configuration Docker" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Demander le secret API
Write-Host "🔐 Configuration du secret API LibreTranslate" -ForegroundColor Yellow
$apiSecret = Read-Host "Entre un mot de passe fort pour LibreTranslate (min. 20 caractères)"

if ($apiSecret.Length -lt 20) {
    Write-Host "❌ Le mot de passe doit faire au moins 20 caractères !" -ForegroundColor Red
    exit 1
}

# Modifier docker-compose.yml
Write-Host "📝 Modification de docker-compose.yml..." -ForegroundColor Yellow
$dockerCompose = Get-Content "docker-compose.yml" -Raw
$dockerCompose = $dockerCompose -replace "ChangeThisToAStrongSecretKey123!", $apiSecret
$dockerCompose | Set-Content "docker-compose.yml" -Encoding UTF8
Write-Host "✅ docker-compose.yml configuré" -ForegroundColor Green

# Démarrer Docker
Write-Host ""
Write-Host "🐳 Démarrage de LibreTranslate avec Docker..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ LibreTranslate démarré !" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du démarrage de Docker" -ForegroundColor Red
    exit 1
}

# Attendre que LibreTranslate soit prêt
Write-Host "⏳ Attente du démarrage de LibreTranslate (30 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ÉTAPE 2 : Installation de l'API Gateway" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Aller dans le dossier backend
Set-Location "backend"

# Installer les dépendances
Write-Host "📦 Installation des dépendances npm..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Write-Host "✅ Dépendances installées" -ForegroundColor Green

# Créer le fichier .env
Write-Host ""
Write-Host "🔐 Configuration de l'API Gateway" -ForegroundColor Yellow
$adminKey = Read-Host "Entre un mot de passe admin fort (min. 20 caractères)"

if ($adminKey.Length -lt 20) {
    Write-Host "❌ Le mot de passe admin doit faire au moins 20 caractères !" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

$envContent = @"
PORT=3000
NODE_ENV=production
LIBRETRANSLATE_URL=http://100.64.0.2:5000
DATABASE_PATH=./data/gateway.db
MASTER_ADMIN_KEY=$adminKey
API_KEY_LENGTH=32
CACHE_ENABLED=true
CACHE_TTL_SECONDS=3600
"@

$envContent | Set-Content ".env" -Encoding UTF8
Write-Host "✅ Fichier .env créé" -ForegroundColor Green

# Initialiser la base de données
Write-Host ""
Write-Host "🗄️  Initialisation de la base de données..." -ForegroundColor Yellow
npm run init-db

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ÉTAPE 3 : Configuration Flutter (optionnel)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$installFlutter = Read-Host "Veux-tu installer les dépendances Flutter ? (O/N)"

if ($installFlutter -eq "O" -or $installFlutter -eq "o") {
    if (Test-Command "flutter") {
        Set-Location "..\app"
        Write-Host "📦 Installation des dépendances Flutter..." -ForegroundColor Yellow
        flutter pub get

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Dépendances Flutter installées" -ForegroundColor Green
        }
        Set-Location "..\backend"
    } else {
        Write-Host "⚠️  Flutter n'est pas installé, étape sautée" -ForegroundColor Yellow
    }
}

Set-Location ".."

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                       ║" -ForegroundColor Green
Write-Host "║   ✅ Installation terminée avec succès !              ║" -ForegroundColor Green
Write-Host "║                                                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Prochaines étapes :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Démarre l'API Gateway :" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "2. Lance l'application Flutter :" -ForegroundColor Yellow
Write-Host "   cd app" -ForegroundColor White
Write-Host "   flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "3. Configure ta clé API dans l'application (onglet Paramètres)" -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 Documentation complète : README.md" -ForegroundColor Cyan
Write-Host "🚀 Démarrage rapide : QUICK_START.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bonne traduction ! 🌍✨" -ForegroundColor Green
