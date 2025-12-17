import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/language.dart';

class ApiService {
  static final ApiService instance = ApiService._init();

  ApiService._init();

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Ajouter la clé API seulement si elle est configurée
    if (AppConfig.libreTranslateApiKey.isNotEmpty) {
      headers['api_key'] = AppConfig.libreTranslateApiKey;
    }

    return headers;
  }

  // === TRADUCTION ===

  Future<Map<String, dynamic>> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
    int alternatives = 3,
  }) async {
    final url = Uri.parse('${AppConfig.libreTranslateUrl}/translate');

    final body = {
      'q': text,
      'source': sourceLang,
      'target': targetLang,
      'alternatives': alternatives,
    };

    // Ajouter la clé API dans le body si configurée
    if (AppConfig.libreTranslateApiKey.isNotEmpty) {
      body['api_key'] = AppConfig.libreTranslateApiKey;
    }

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Erreur de traduction');
      }
    } on SocketException {
      throw Exception('Pas de connexion au serveur LibreTranslate');
    } on http.ClientException {
      throw Exception('Erreur de connexion au serveur');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // === DÉTECTION DE LANGUE ===

  Future<List<Map<String, dynamic>>> detectLanguage(String text) async {
    final url = Uri.parse('${AppConfig.libreTranslateUrl}/detect');

    final body = {'q': text};
    if (AppConfig.libreTranslateApiKey.isNotEmpty) {
      body['api_key'] = AppConfig.libreTranslateApiKey;
    }

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as List<dynamic>;
        return result.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur de détection');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // === LANGUES DISPONIBLES ===

  Future<List<Language>> getLanguages() async {
    final url = Uri.parse('${AppConfig.libreTranslateUrl}/languages');

    try {
      final response = await http.get(url).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Language.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des langues');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // === TRADUCTION DE FICHIERS ===

  Future<List<int>> translateFile({
    required File file,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    final url = Uri.parse('${AppConfig.libreTranslateUrl}/translate_file');

    try {
      final request = http.MultipartRequest('POST', url);

      // Fichier
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // Paramètres
      request.fields['source'] = sourceLang;
      request.fields['target'] = targetLang;

      // Ajouter la clé API si configurée
      if (AppConfig.libreTranslateApiKey.isNotEmpty) {
        request.fields['api_key'] = AppConfig.libreTranslateApiKey;
      }

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );

      if (streamedResponse.statusCode == 200) {
        return await streamedResponse.stream.toBytes();
      } else {
        final responseBody = await streamedResponse.stream.bytesToString();
        final error = jsonDecode(responseBody);
        throw Exception(error['error'] ?? error['message'] ?? 'Erreur de traduction de fichier');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // === VÉRIFICATION DE LA CONNEXION ===

  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse('${AppConfig.libreTranslateUrl}/languages');
      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
