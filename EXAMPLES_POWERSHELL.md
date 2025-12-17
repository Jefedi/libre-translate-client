# 🪟 Exemples PowerShell pour Windows

Guide d'utilisation de l'API avec PowerShell (Windows).

## 📋 Prérequis

Remplace dans tous les exemples :
- `YOUR_API_KEY` par ta clé API
- `YOUR_ADMIN_KEY` par ta clé admin

## 🌍 Traduction

### Traduction simple

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
    "Content-Type" = "application/json"
}

$body = @{
    q = "Bonjour le monde"
    source = "fr"
    target = "en"
    alternatives = 3
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/translate" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Host "Traduction : $($response.translatedText)"
Write-Host "Du cache : $($response.fromCache)"

if ($response.alternatives) {
    Write-Host "`nAlternatives :"
    $response.alternatives | ForEach-Object { Write-Host "  - $_" }
}
```

### Détection automatique de langue

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
    "Content-Type" = "application/json"
}

$body = @{
    q = "Hello world"
    source = "auto"
    target = "fr"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/translate" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Host "Traduction : $($response.translatedText)"

if ($response.detectedLanguage) {
    Write-Host "Langue détectée : $($response.detectedLanguage.language)"
    Write-Host "Confiance : $($response.detectedLanguage.confidence)%"
}
```

## 🔍 Détection de langue

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
    "Content-Type" = "application/json"
}

$body = @{
    q = "Guten Tag"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/detect" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Host "Résultats de détection :"
$response | ForEach-Object {
    Write-Host "  Langue: $($_.language) - Confiance: $($_.confidence)%"
}
```

## 🌐 Langues disponibles

```powershell
$languages = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/languages"

Write-Host "Langues disponibles :"
$languages | ForEach-Object {
    Write-Host "  [$($_.code)] $($_.name)"
}
```

## 🔑 Gestion des clés API (Admin)

### Créer une nouvelle clé

```powershell
$headers = @{
    "X-Admin-Key" = "YOUR_ADMIN_KEY"
    "Content-Type" = "application/json"
}

$body = @{
    name = "Application Mobile"
    description = "Clé pour l'application mobile iOS/Android"
    rateLimit = 5000
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Host "✅ Clé créée avec succès !"
Write-Host "ID : $($response.apiKey.id)"
Write-Host "Nom : $($response.apiKey.name)"
Write-Host "Clé : $($response.apiKey.key)"
Write-Host "`n⚠️  Sauvegardez cette clé, elle ne sera plus affichée !"
```

### Lister toutes les clés

```powershell
$headers = @{
    "X-Admin-Key" = "YOUR_ADMIN_KEY"
}

$keys = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys" `
    -Method Get `
    -Headers $headers

Write-Host "Clés API actives :"
$keys | ForEach-Object {
    Write-Host "`nID: $($_.id)"
    Write-Host "Nom: $($_.name)"
    Write-Host "Clé: $($_.key)"
    Write-Host "Utilisations: $($_.usage_count)"
    Write-Host "Limite: $($_.rate_limit) req/jour"
    Write-Host "Créée le: $($_.created_at)"
}
```

### Voir les statistiques d'une clé

```powershell
$headers = @{
    "X-Admin-Key" = "YOUR_ADMIN_KEY"
}

$keyId = 1  # Remplace par l'ID de ta clé

$stats = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys/$keyId/stats" `
    -Method Get `
    -Headers $headers

Write-Host "Statistiques de la clé #$keyId :"
Write-Host "Nom : $($stats.key.name)"
Write-Host "Utilisations totales : $($stats.key.usageCount)"
Write-Host "Dernière utilisation : $($stats.key.lastUsedAt)"

Write-Host "`nStatistiques quotidiennes (30 derniers jours) :"
$stats.dailyStats | ForEach-Object {
    Write-Host "  $($_.date) : $($_.total_requests) requêtes (dont $($_.successful_requests) réussies)"
}
```

### Révoquer une clé

```powershell
$headers = @{
    "X-Admin-Key" = "YOUR_ADMIN_KEY"
}

$keyId = 1  # Remplace par l'ID de la clé à révoquer

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys/$keyId/revoke" `
    -Method Post `
    -Headers $headers

Write-Host "✅ $($response.message)"
```

### Supprimer une clé

```powershell
$headers = @{
    "X-Admin-Key" = "YOUR_ADMIN_KEY"
}

$keyId = 1  # Remplace par l'ID de la clé à supprimer

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/keys/$keyId" `
    -Method Delete `
    -Headers $headers

Write-Host "✅ $($response.message)"
```

## 📁 Traduction de fichiers

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
}

# Chemin du fichier à traduire
$filePath = "C:\Users\Jefe\Documents\document.txt"

# Créer un multipart/form-data
$form = @{
    file = Get-Item -Path $filePath
    source = "fr"
    target = "en"
}

# Effectuer la requête
Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/files/translate" `
    -Method Post `
    -Headers $headers `
    -Form $form `
    -OutFile "C:\Users\Jefe\Documents\document_translated.txt"

Write-Host "✅ Fichier traduit sauvegardé !"
```

## 📊 Cache

### Statistiques du cache

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
}

$stats = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/cache/stats" `
    -Method Get `
    -Headers $headers

Write-Host "Statistiques du cache :"
Write-Host "  Entrées totales : $($stats.total_entries)"
Write-Host "  Accès totaux : $($stats.total_accesses)"
Write-Host "  Moyenne d'accès par entrée : $([math]::Round($stats.avg_accesses_per_entry, 2))"
```

### Nettoyer le cache expiré

```powershell
$headers = @{
    "X-API-Key" = "YOUR_API_KEY"
}

$response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/cache/clean" `
    -Method Delete `
    -Headers $headers

Write-Host "✅ Cache nettoyé !"
Write-Host "Entrées supprimées : $($response.deletedEntries)"
```

## 🔄 Script complet : Traduction en batch

```powershell
# Configuration
$apiKey = "YOUR_API_KEY"
$headers = @{
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

# Textes à traduire
$textes = @(
    "Bonjour",
    "Comment allez-vous ?",
    "Au revoir"
)

Write-Host "Traduction de $($textes.Count) textes...`n"

foreach ($texte in $textes) {
    $body = @{
        q = $texte
        source = "fr"
        target = "en"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/translate" `
            -Method Post `
            -Headers $headers `
            -Body $body

        Write-Host "✅ '$texte' → '$($response.translatedText)'"

        if ($response.fromCache) {
            Write-Host "   (du cache)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Erreur : $_" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 100  # Petit délai entre les requêtes
}

Write-Host "`nTraduction terminée !"
```

## 🩺 Vérification de santé

```powershell
# Health check de l'API
$health = Invoke-RestMethod -Uri "http://100.64.0.2:3000/health"

Write-Host "Status : $($health.status)"
Write-Host "Timestamp : $($health.timestamp)"
Write-Host "Uptime : $([math]::Round($health.uptime, 2)) secondes"
```

## 💡 Conseils

### Gérer les erreurs

```powershell
try {
    $response = Invoke-RestMethod -Uri "http://100.64.0.2:3000/api/translate" `
        -Method Post `
        -Headers $headers `
        -Body $body

    Write-Host "Succès : $($response.translatedText)"
}
catch {
    $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "Erreur : $($errorDetails.message)" -ForegroundColor Red
}
```

### Sauvegarder les résultats dans un fichier

```powershell
$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "resultat.json" -Encoding UTF8
```

### Charger depuis un fichier JSON

```powershell
$data = Get-Content -Path "textes.json" -Raw | ConvertFrom-Json

foreach ($item in $data) {
    # Traiter chaque élément
}
```

---

Bon développement ! 🚀
