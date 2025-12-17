const db = require('../config/database');
const { nanoid } = require('nanoid');

class ApiKeyService {
  /**
   * Générer une nouvelle clé API
   */
  static generateKey() {
    const length = parseInt(process.env.API_KEY_LENGTH) || 32;
    return `ltk_${nanoid(length)}`;
  }

  /**
   * Créer une nouvelle clé API
   */
  static createApiKey(name, description = '', rateLimit = 1000) {
    const key = this.generateKey();

    const stmt = db.prepare(`
      INSERT INTO api_keys (key, name, description, rate_limit)
      VALUES (?, ?, ?, ?)
    `);

    const result = stmt.run(key, name, description, rateLimit);

    return {
      id: result.lastInsertRowid,
      key,
      name,
      description,
      rateLimit,
      isActive: true,
      createdAt: new Date().toISOString()
    };
  }

  /**
   * Valider une clé API
   */
  static validateApiKey(key) {
    const stmt = db.prepare(`
      SELECT * FROM api_keys
      WHERE key = ? AND is_active = 1
    `);

    const apiKey = stmt.get(key);

    if (apiKey) {
      // Mettre à jour la date de dernière utilisation
      const updateStmt = db.prepare(`
        UPDATE api_keys
        SET last_used_at = CURRENT_TIMESTAMP,
            usage_count = usage_count + 1
        WHERE key = ?
      `);
      updateStmt.run(key);

      return {
        valid: true,
        apiKey: {
          id: apiKey.id,
          name: apiKey.name,
          rateLimit: apiKey.rate_limit,
          usageCount: apiKey.usage_count + 1
        }
      };
    }

    return { valid: false };
  }

  /**
   * Lister toutes les clés API
   */
  static listApiKeys(includeInactive = false) {
    const query = includeInactive
      ? 'SELECT * FROM api_keys ORDER BY created_at DESC'
      : 'SELECT * FROM api_keys WHERE is_active = 1 ORDER BY created_at DESC';

    const stmt = db.prepare(query);
    return stmt.all();
  }

  /**
   * Obtenir une clé API par ID
   */
  static getApiKey(id) {
    const stmt = db.prepare('SELECT * FROM api_keys WHERE id = ?');
    return stmt.get(id);
  }

  /**
   * Révoquer une clé API
   */
  static revokeApiKey(id) {
    const stmt = db.prepare(`
      UPDATE api_keys
      SET is_active = 0
      WHERE id = ?
    `);

    const result = stmt.run(id);
    return result.changes > 0;
  }

  /**
   * Réactiver une clé API
   */
  static reactivateApiKey(id) {
    const stmt = db.prepare(`
      UPDATE api_keys
      SET is_active = 1
      WHERE id = ?
    `);

    const result = stmt.run(id);
    return result.changes > 0;
  }

  /**
   * Supprimer définitivement une clé API
   */
  static deleteApiKey(id) {
    const stmt = db.prepare('DELETE FROM api_keys WHERE id = ?');
    const result = stmt.run(id);
    return result.changes > 0;
  }

  /**
   * Mettre à jour les informations d'une clé
   */
  static updateApiKey(id, updates) {
    const allowedFields = ['name', 'description', 'rate_limit'];
    const fields = Object.keys(updates).filter(f => allowedFields.includes(f));

    if (fields.length === 0) return false;

    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => updates[f]);

    const stmt = db.prepare(`
      UPDATE api_keys
      SET ${setClause}
      WHERE id = ?
    `);

    const result = stmt.run(...values, id);
    return result.changes > 0;
  }

  /**
   * Obtenir les statistiques d'utilisation d'une clé
   */
  static getKeyStats(id) {
    const key = this.getApiKey(id);
    if (!key) return null;

    const statsStmt = db.prepare(`
      SELECT
        COUNT(*) as total_requests,
        SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) as successful_requests,
        AVG(response_time) as avg_response_time,
        DATE(timestamp) as date
      FROM usage_stats
      WHERE api_key = ?
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
      LIMIT 30
    `);

    return {
      key: {
        id: key.id,
        name: key.name,
        usageCount: key.usage_count,
        lastUsedAt: key.last_used_at
      },
      dailyStats: statsStmt.all(key.key)
    };
  }
}

module.exports = ApiKeyService;
