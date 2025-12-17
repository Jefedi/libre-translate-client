require('dotenv').config();
const db = require('../config/database');
const ApiKeyService = require('../services/apiKeyService');

console.log('🔧 Initialisation de la base de données...\n');

// Créer une première clé API pour tester
const testKey = ApiKeyService.createApiKey(
  'Test Application',
  'Clé API de test pour le développement',
  5000
);

console.log('✅ Base de données initialisée avec succès!\n');
console.log('📋 Informations de la clé de test:');
console.log('   ID:', testKey.id);
console.log('   Nom:', testKey.name);
console.log('   Clé:', testKey.key);
console.log('   Limite de requêtes:', testKey.rateLimit);
console.log('\n⚠️  IMPORTANT: Sauvegardez cette clé, elle ne sera plus affichée en entier!\n');

console.log('💡 Pour créer d\'autres clés, utilisez:');
console.log('   POST /api/keys');
console.log('   Header: X-Admin-Key: ' + process.env.MASTER_ADMIN_KEY);
console.log('\n');

process.exit(0);
