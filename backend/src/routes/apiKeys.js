const express = require('express');
const router = express.Router();
const ApiKeyService = require('../services/apiKeyService');
const { requireAdmin, authenticateApiKey } = require('../middleware/auth');

/**
 * POST /api/keys - Créer une nouvelle clé API (Admin uniquement)
 */
router.post('/', requireAdmin, (req, res) => {
  try {
    const { name, description, rateLimit } = req.body;

    if (!name) {
      return res.status(400).json({
        error: 'Paramètre manquant',
        message: 'Le paramètre "name" est requis'
      });
    }

    const apiKey = ApiKeyService.createApiKey(name, description, rateLimit);

    res.status(201).json({
      message: 'Clé API créée avec succès',
      apiKey
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur lors de la création de la clé',
      message: error.message
    });
  }
});

/**
 * GET /api/keys - Lister toutes les clés API (Admin uniquement)
 */
router.get('/', requireAdmin, (req, res) => {
  try {
    const includeInactive = req.query.include_inactive === 'true';
    const keys = ApiKeyService.listApiKeys(includeInactive);

    // Masquer les clés complètes pour la sécurité
    const maskedKeys = keys.map(key => ({
      ...key,
      key: `${key.key.substring(0, 10)}...${key.key.substring(key.key.length - 4)}`
    }));

    res.json(maskedKeys);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * GET /api/keys/:id - Obtenir une clé API spécifique (Admin uniquement)
 */
router.get('/:id', requireAdmin, (req, res) => {
  try {
    const key = ApiKeyService.getApiKey(req.params.id);

    if (!key) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée'
      });
    }

    res.json(key);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * PATCH /api/keys/:id - Mettre à jour une clé API (Admin uniquement)
 */
router.patch('/:id', requireAdmin, (req, res) => {
  try {
    const { name, description, rate_limit } = req.body;
    const updates = {};

    if (name) updates.name = name;
    if (description !== undefined) updates.description = description;
    if (rate_limit !== undefined) updates.rate_limit = rate_limit;

    const success = ApiKeyService.updateApiKey(req.params.id, updates);

    if (!success) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée ou aucune modification'
      });
    }

    res.json({
      message: 'Clé API mise à jour avec succès'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * POST /api/keys/:id/revoke - Révoquer une clé API (Admin uniquement)
 */
router.post('/:id/revoke', requireAdmin, (req, res) => {
  try {
    const success = ApiKeyService.revokeApiKey(req.params.id);

    if (!success) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée'
      });
    }

    res.json({
      message: 'Clé API révoquée avec succès'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * POST /api/keys/:id/reactivate - Réactiver une clé API (Admin uniquement)
 */
router.post('/:id/reactivate', requireAdmin, (req, res) => {
  try {
    const success = ApiKeyService.reactivateApiKey(req.params.id);

    if (!success) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée'
      });
    }

    res.json({
      message: 'Clé API réactivée avec succès'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * DELETE /api/keys/:id - Supprimer définitivement une clé API (Admin uniquement)
 */
router.delete('/:id', requireAdmin, (req, res) => {
  try {
    const success = ApiKeyService.deleteApiKey(req.params.id);

    if (!success) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée'
      });
    }

    res.json({
      message: 'Clé API supprimée définitivement'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * GET /api/keys/:id/stats - Obtenir les statistiques d'une clé (Admin ou propriétaire)
 */
router.get('/:id/stats', requireAdmin, (req, res) => {
  try {
    const stats = ApiKeyService.getKeyStats(req.params.id);

    if (!stats) {
      return res.status(404).json({
        error: 'Non trouvé',
        message: 'Clé API non trouvée'
      });
    }

    res.json(stats);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur',
      message: error.message
    });
  }
});

/**
 * GET /api/keys/validate/current - Valider la clé actuelle
 */
router.get('/validate/current', authenticateApiKey, (req, res) => {
  res.json({
    valid: true,
    apiKey: req.apiKey
  });
});

module.exports = router;
