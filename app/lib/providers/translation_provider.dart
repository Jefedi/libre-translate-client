import 'package:flutter/material.dart';
import '../models/language.dart';
import '../models/translation.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class TranslationProvider with ChangeNotifier {
  final ApiService _api = ApiService.instance;
  final DatabaseService _db = DatabaseService.instance;

  List<Language> _languages = [];
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';
  String _sourceText = '';
  String _translatedText = '';
  List<String> _alternatives = [];
  bool _isLoading = false;
  bool _fromCache = false;
  String? _errorMessage;
  String? _detectedLanguage;
  int _historyUpdateCounter = 0;

  // Getters
  List<Language> get languages => _languages;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  List<String> get alternatives => _alternatives;
  bool get isLoading => _isLoading;
  bool get fromCache => _fromCache;
  String? get errorMessage => _errorMessage;
  String? get detectedLanguage => _detectedLanguage;
  int get historyUpdateCounter => _historyUpdateCounter;

  TranslationProvider() {
    loadLanguages();
  }

  // === CHARGEMENT DES LANGUES ===

  Future<void> loadLanguages() async {
    try {
      _languages = await _api.getLanguages();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // === TRADUCTION ===

  Future<void> translate({
    String? text,
    bool useCache = true,
    bool saveToHistory = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _fromCache = false;
    _alternatives = [];
    _detectedLanguage = null;
    notifyListeners();

    final textToTranslate = text ?? _sourceText;

    if (textToTranslate.trim().isEmpty) {
      _isLoading = false;
      _translatedText = '';
      notifyListeners();
      return;
    }

    try {
      // Vérifier le cache local si activé
      if (useCache) {
        final cached = await _db.getCachedTranslation(
          textToTranslate,
          _sourceLanguage,
          _targetLanguage,
        );

        if (cached != null) {
          _translatedText = cached.translatedText;
          _alternatives = cached.alternatives ?? [];
          _fromCache = true;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Appel API
      final result = await _api.translate(
        text: textToTranslate,
        sourceLang: _sourceLanguage,
        targetLang: _targetLanguage,
        alternatives: 3,
      );

      _translatedText = result['translatedText'] as String;
      _fromCache = result['fromCache'] as bool? ?? false;

      if (result['alternatives'] != null) {
        _alternatives = (result['alternatives'] as List).cast<String>();
      }

      if (result['detectedLanguage'] != null) {
        final detected = result['detectedLanguage'] as Map<String, dynamic>;
        _detectedLanguage = detected['language'] as String?;
      }

      // Sauvegarder dans l'historique
      if (saveToHistory) {
        final translation = Translation(
          originalText: textToTranslate,
          translatedText: _translatedText,
          sourceLanguage: _detectedLanguage ?? _sourceLanguage,
          targetLanguage: _targetLanguage,
          timestamp: DateTime.now(),
          fromCache: _fromCache,
          alternatives: _alternatives,
        );

        await _db.insertTranslation(translation);
        _historyUpdateCounter++;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // === DÉTECTION DE LANGUE ===

  Future<String?> detectLanguage(String text) async {
    try {
      final result = await _api.detectLanguage(text);
      if (result.isNotEmpty) {
        return result.first['language'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // === SETTERS ===

  void setSourceLanguage(String code) {
    _sourceLanguage = code;
    notifyListeners();
  }

  void setTargetLanguage(String code) {
    _targetLanguage = code;
    notifyListeners();
  }

  void setSourceText(String text) {
    _sourceText = text;
    notifyListeners();
  }

  void swapLanguages() {
    if (_sourceLanguage == 'auto') return;

    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    final tempText = _sourceText;
    _sourceText = _translatedText;
    _translatedText = tempText;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearTranslation() {
    _sourceText = '';
    _translatedText = '';
    _alternatives = [];
    _errorMessage = null;
    _detectedLanguage = null;
    notifyListeners();
  }

  // Méthode pour notifier les changements d'historique (favoris, suppression, etc.)
  void notifyHistoryChanged() {
    _historyUpdateCounter++;
    notifyListeners();
  }
}
