const ApiKeyService = require('../services/apiKeyService');

/**
 * Middleware d'authentification par clé API
 */
function authenticateApiKey(req, res, next) {
  // Vérifier si c'est une clé admin
  const adminKey = req.headers['x-admin-key'];
  if (adminKey && adminKey === process.env.MASTER_ADMIN_KEY) {
    req.isAdmin = true;
    return next();
  }

  // Extraire la clé API
  const apiKey = req.headers['x-api-key'] || req.query.api_key || req.body?.api_key;

  if (!apiKey) {
    return res.status(401).json({
      error: 'API key manquante',
      message: 'Veuillez fournir une clé API via le header X-API-Key ou le paramètre api_key'
    });
  }

  // Valider la clé
  const validation = ApiKeyService.validateApiKey(apiKey);

  if (!validation.valid) {
    return res.status(403).json({
      error: 'API key invalide',
      message: 'La clé API fournie est invalide ou a été révoquée'
    });
  }

  // Ajouter les informations de la clé à la requête
  req.apiKey = validation.apiKey;
  req.isAdmin = false;

  next();
}

/**
 * Middleware pour vérifier les droits admin uniquement
 */
function requireAdmin(req, res, next) {
  const adminKey = req.headers['x-admin-key'];

  if (!adminKey || adminKey !== process.env.MASTER_ADMIN_KEY) {
    return res.status(403).json({
      error: 'Accès refusé',
      message: 'Cette opération nécessite des droits administrateur'
    });
  }

  req.isAdmin = true;
  next();
}

/**
 * Middleware optionnel (n'échoue pas si la clé est absente)
 */
function optionalAuth(req, res, next) {
  const apiKey = req.headers['x-api-key'] || req.query.api_key;

  if (apiKey) {
    const validation = ApiKeyService.validateApiKey(apiKey);
    if (validation.valid) {
      req.apiKey = validation.apiKey;
    }
  }

  next();
}

module.exports = {
  authenticateApiKey,
  requireAdmin,
  optionalAuth
};
