require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

// Routes
const translationRoutes = require('./routes/translation');
const apiKeysRoutes = require('./routes/apiKeys');
const filesRoutes = require('./routes/files');

const app = express();
const PORT = process.env.PORT || 3000;

// === MIDDLEWARES DE SÉCURITÉ ===
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting global
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max 100 requêtes par IP
  message: {
    error: 'Trop de requêtes',
    message: 'Vous avez dépassé la limite de requêtes. Réessayez plus tard.'
  }
});

app.use('/api/', limiter);

// === ROUTES ===
app.get('/', (req, res) => {
  res.json({
    name: 'LibreTranslate API Gateway',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      translation: '/api/translate',
      detection: '/api/detect',
      languages: '/api/languages',
      files: '/api/files/translate',
      apiKeys: '/api/keys',
      cache: {
        stats: '/api/cache/stats',
        clean: '/api/cache/clean'
      }
    },
    documentation: {
      authentication: 'Utilisez le header X-API-Key ou le paramètre api_key',
      admin: 'Utilisez le header X-Admin-Key pour les opérations admin'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Routes API
app.use('/api', translationRoutes);
app.use('/api/keys', apiKeysRoutes);
app.use('/api/files', filesRoutes);

// === GESTION DES ERREURS ===
app.use((err, req, res, next) => {
  console.error('Erreur:', err);

  if (err.type === 'entity.too.large') {
    return res.status(413).json({
      error: 'Fichier trop volumineux',
      message: 'La taille du fichier dépasse la limite autorisée (10 MB)'
    });
  }

  res.status(err.status || 500).json({
    error: err.message || 'Erreur interne du serveur',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route non trouvée',
    message: `La route ${req.method} ${req.path} n'existe pas`
  });
});

// === DÉMARRAGE DU SERVEUR ===
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   🚀 LibreTranslate API Gateway                      ║
║                                                       ║
║   📡 Serveur démarré sur le port ${PORT}                ║
║   🌍 Environnement: ${process.env.NODE_ENV || 'development'}                  ║
║   🔗 LibreTranslate: ${process.env.LIBRETRANSLATE_URL || 'http://100.64.0.2:5000'}      ║
║                                                       ║
║   📚 Documentation: http://localhost:${PORT}/           ║
║   ❤️  Health check: http://localhost:${PORT}/health     ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
  `);
});

// Gestion propre de l'arrêt
process.on('SIGTERM', () => {
  console.log('SIGTERM reçu. Arrêt propre du serveur...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT reçu. Arrêt propre du serveur...');
  process.exit(0);
});
