const express = require('express');
const router = express.Router();
const translationService = require('../services/translationService');
const { authenticateApiKey } = require('../middleware/auth');
const db = require('../config/database');

/**
 * POST /api/translate - Traduire un texte
 */
router.post('/translate', authenticateApiKey, async (req, res) => {
  const startTime = Date.now();

  try {
    const { q, source, target, format, alternatives } = req.body;

    // Validation
    if (!q || !target) {
      return res.status(400).json({
        error: 'Paramètres manquants',
        message: 'Les paramètres "q" (texte) et "target" (langue cible) sont requis'
      });
    }

    // Traduire
    const result = await translationService.translate(
      q,
      source || 'auto',
      target,
      { format, alternatives }
    );

    // Logger les stats
    const responseTime = Date.now() - startTime;
    db.prepare(`
      INSERT INTO usage_stats (api_key, endpoint, response_time, success)
      VALUES (?, ?, ?, ?)
    `).run(req.apiKey?.name || 'unknown', '/translate', responseTime, 1);

    res.json(result);
  } catch (error) {
    const responseTime = Date.now() - startTime;
    db.prepare(`
      INSERT INTO usage_stats (api_key, endpoint, response_time, success)
      VALUES (?, ?, ?, ?)
    `).run(req.apiKey?.name || 'unknown', '/translate', responseTime, 0);

    res.status(500).json({
      error: 'Erreur de traduction',
      message: error.message
    });
  }
});

/**
 * POST /api/detect - Détecter la langue
 */
router.post('/detect', authenticateApiKey, async (req, res) => {
  try {
    const { q } = req.body;

    if (!q) {
      return res.status(400).json({
        error: 'Paramètre manquant',
        message: 'Le paramètre "q" (texte) est requis'
      });
    }

    const result = await translationService.detect(q);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur de détection',
      message: error.message
    });
  }
});

/**
 * GET /api/languages - Obtenir les langues disponibles
 */
router.get('/languages', async (req, res) => {
  try {
    const languages = await translationService.getLanguages();
    res.json(languages);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * GET /api/cache/stats - Statistiques du cache
 */
router.get('/cache/stats', authenticateApiKey, (req, res) => {
  try {
    const stats = translationService.getCacheStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * DELETE /api/cache/clean - Nettoyer le cache expiré
 */
router.delete('/cache/clean', authenticateApiKey, (req, res) => {
  try {
    const deleted = translationService.cleanExpiredCache();
    res.json({
      message: 'Cache nettoyé',
      deletedEntries: deleted
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

module.exports = router;
