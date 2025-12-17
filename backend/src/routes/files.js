const express = require('express');
const router = express.Router();
const multer = require('multer');
const translationService = require('../services/translationService');
const { authenticateApiKey } = require('../middleware/auth');

// Configuration de multer pour le téléchargement de fichiers
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10 MB max
  },
  fileFilter: (req, file, cb) => {
    // Types de fichiers acceptés
    const allowedTypes = [
      'text/plain',
      'text/html',
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.oasis.opendocument.text'
    ];

    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Type de fichier non supporté'), false);
    }
  }
});

/**
 * POST /api/files/translate - Traduire un fichier
 */
router.post('/translate', authenticateApiKey, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'Fichier manquant',
        message: 'Veuillez fournir un fichier à traduire'
      });
    }

    const { source, target } = req.body;

    if (!target) {
      return res.status(400).json({
        error: 'Paramètre manquant',
        message: 'Le paramètre "target" (langue cible) est requis'
      });
    }

    // Traduire le fichier
    const result = await translationService.translateFile(
      req.file,
      source || 'auto',
      target
    );

    // Renvoyer le fichier traduit
    res.setHeader('Content-Type', result.contentType);
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="translated_${req.file.originalname}"`
    );
    res.send(result.data);
  } catch (error) {
    res.status(500).json({
      error: 'Erreur de traduction de fichier',
      message: error.message
    });
  }
});

module.exports = router;
