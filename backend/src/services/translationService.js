const axios = require('axios');
const crypto = require('crypto');
const db = require('../config/database');

class TranslationService {
  constructor() {
    this.libreTranslateUrl = process.env.LIBRETRANSLATE_URL || 'http://100.64.0.2:5000';
    this.libreTranslateApiKey = process.env.LIBRETRANSLATE_API_KEY || '';
    this.cacheEnabled = process.env.CACHE_ENABLED === 'true';
    this.cacheTTL = parseInt(process.env.CACHE_TTL_SECONDS) || 3600;
  }

  /**
   * Générer un hash pour le cache
   */
  _generateHash(text) {
    return crypto.createHash('sha256').update(text).digest('hex');
  }

  /**
   * Vérifier le cache
   */
  _checkCache(textHash, sourceLang, targetLang) {
    if (!this.cacheEnabled) return null;

    const stmt = db.prepare(`
      SELECT * FROM translation_cache
      WHERE text_hash = ? AND source_lang = ? AND target_lang = ?
      AND datetime(created_at, '+' || ? || ' seconds') > datetime('now')
    `);

    const cached = stmt.get(textHash, sourceLang, targetLang, this.cacheTTL);

    if (cached) {
      // Incrémenter le compteur d'accès
      const updateStmt = db.prepare(`
        UPDATE translation_cache
        SET access_count = access_count + 1
        WHERE id = ?
      `);
      updateStmt.run(cached.id);

      return {
        translatedText: cached.translated_text,
        fromCache: true
      };
    }

    return null;
  }

  /**
   * Sauvegarder dans le cache
   */
  _saveToCache(text, sourceLang, targetLang, translatedText) {
    if (!this.cacheEnabled) return;

    const textHash = this._generateHash(text);

    const stmt = db.prepare(`
      INSERT OR REPLACE INTO translation_cache
      (text_hash, source_lang, target_lang, original_text, translated_text)
      VALUES (?, ?, ?, ?, ?)
    `);

    stmt.run(textHash, sourceLang, targetLang, text, translatedText);
  }

  /**
   * Traduire un texte
   */
  async translate(text, sourceLang, targetLang, options = {}) {
    const textHash = this._generateHash(text);

    // Vérifier le cache
    const cached = this._checkCache(textHash, sourceLang, targetLang);
    if (cached) {
      return cached;
    }

    // Appeler LibreTranslate
    const requestData = {
      q: text,
      source: sourceLang,
      target: targetLang,
      format: options.format || 'text',
      alternatives: options.alternatives || 0
    };

    // Ajouter la clé API si configurée
    if (this.libreTranslateApiKey) {
      requestData.api_key = this.libreTranslateApiKey;
    }

    try {
      const response = await axios.post(
        `${this.libreTranslateUrl}/translate`,
        requestData,
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 30000
        }
      );

      const result = response.data;

      // Sauvegarder dans le cache
      this._saveToCache(text, sourceLang, targetLang, result.translatedText);

      return {
        translatedText: result.translatedText,
        detectedLanguage: result.detectedLanguage,
        alternatives: result.alternatives || [],
        fromCache: false
      };
    } catch (error) {
      throw new Error(`Erreur de traduction: ${error.message}`);
    }
  }

  /**
   * Détecter la langue
   */
  async detect(text) {
    try {
      const response = await axios.post(
        `${this.libreTranslateUrl}/detect`,
        { q: text },
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 10000
        }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Erreur de détection: ${error.message}`);
    }
  }

  /**
   * Obtenir les langues disponibles
   */
  async getLanguages() {
    try {
      const response = await axios.get(`${this.libreTranslateUrl}/languages`);
      return response.data;
    } catch (error) {
      throw new Error(`Erreur lors de la récupération des langues: ${error.message}`);
    }
  }

  /**
   * Traduire un fichier
   */
  async translateFile(file, sourceLang, targetLang) {
    const FormData = require('form-data');
    const form = new FormData();

    form.append('file', file.buffer, file.originalname);
    form.append('source', sourceLang);
    form.append('target', targetLang);

    if (this.libreTranslateApiKey) {
      form.append('api_key', this.libreTranslateApiKey);
    }

    try {
      const response = await axios.post(
        `${this.libreTranslateUrl}/translate_file`,
        form,
        {
          headers: form.getHeaders(),
          responseType: 'arraybuffer',
          timeout: 60000
        }
      );

      return {
        data: response.data,
        contentType: response.headers['content-type']
      };
    } catch (error) {
      throw new Error(`Erreur de traduction de fichier: ${error.message}`);
    }
  }

  /**
   * Obtenir les statistiques du cache
   */
  getCacheStats() {
    const stmt = db.prepare(`
      SELECT
        COUNT(*) as total_entries,
        SUM(access_count) as total_accesses,
        AVG(access_count) as avg_accesses_per_entry
      FROM translation_cache
    `);

    return stmt.get();
  }

  /**
   * Nettoyer le cache expiré
   */
  cleanExpiredCache() {
    const stmt = db.prepare(`
      DELETE FROM translation_cache
      WHERE datetime(created_at, '+' || ? || ' seconds') < datetime('now')
    `);

    const result = stmt.run(this.cacheTTL);
    return result.changes;
  }
}

module.exports = new TranslationService();
