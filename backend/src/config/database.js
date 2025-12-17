const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const dbPath = process.env.DATABASE_PATH || './data/gateway.db';
const dbDir = path.dirname(dbPath);

// Créer le dossier si nécessaire
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new Database(dbPath);
db.pragma('journal_mode = WAL');

// Initialiser les tables
function initDatabase() {
  // Table des clés API
  db.exec(`
    CREATE TABLE IF NOT EXISTS api_keys (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      last_used_at DATETIME,
      is_active INTEGER DEFAULT 1,
      rate_limit INTEGER DEFAULT 1000,
      usage_count INTEGER DEFAULT 0
    )
  `);

  // Table d'historique des traductions (cache)
  db.exec(`
    CREATE TABLE IF NOT EXISTS translation_cache (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text_hash TEXT NOT NULL,
      source_lang TEXT NOT NULL,
      target_lang TEXT NOT NULL,
      original_text TEXT NOT NULL,
      translated_text TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      access_count INTEGER DEFAULT 1,
      UNIQUE(text_hash, source_lang, target_lang)
    )
  `);

  // Table des statistiques d'utilisation
  db.exec(`
    CREATE TABLE IF NOT EXISTS usage_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      api_key TEXT,
      endpoint TEXT NOT NULL,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      response_time INTEGER,
      success INTEGER DEFAULT 1
    )
  `);

  // Index pour les performances
  db.exec(`
    CREATE INDEX IF NOT EXISTS idx_cache_lookup
    ON translation_cache(text_hash, source_lang, target_lang);
  `);

  db.exec(`
    CREATE INDEX IF NOT EXISTS idx_api_keys_active
    ON api_keys(key) WHERE is_active = 1;
  `);

  console.log('✅ Base de données initialisée');
}

// Initialiser au démarrage
initDatabase();

module.exports = db;
