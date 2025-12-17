import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/translation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('libretranslate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table des traductions (historique + cache)
    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        from_cache INTEGER DEFAULT 0,
        alternatives TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Index pour les recherches
    await db.execute('''
      CREATE INDEX idx_timestamp ON translations(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_languages ON translations(source_language, target_language)
    ''');

    await db.execute('''
      CREATE INDEX idx_favorite ON translations(is_favorite) WHERE is_favorite = 1
    ''');
  }

  // === OPÉRATIONS CRUD ===

  Future<int> insertTranslation(Translation translation) async {
    final db = await database;
    return await db.insert('translations', translation.toJson());
  }

  Future<List<Translation>> getHistory({
    int limit = 100,
    int offset = 0,
    bool onlyFavorites = false,
  }) async {
    final db = await database;

    final where = onlyFavorites ? 'WHERE is_favorite = 1' : '';
    final results = await db.rawQuery('''
      SELECT * FROM translations
      $where
      ORDER BY timestamp DESC
      LIMIT ? OFFSET ?
    ''', [limit, offset]);

    return results.map((json) => Translation.fromJson(json)).toList();
  }

  Future<List<Translation>> searchHistory(String query) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT * FROM translations
      WHERE original_text LIKE ? OR translated_text LIKE ?
      ORDER BY timestamp DESC
      LIMIT 100
    ''', ['%$query%', '%$query%']);

    return results.map((json) => Translation.fromJson(json)).toList();
  }

  Future<Translation?> getCachedTranslation(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    final db = await database;

    final results = await db.query(
      'translations',
      where: 'original_text = ? AND source_language = ? AND target_language = ?',
      whereArgs: [text, sourceLang, targetLang],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Translation.fromJson(results.first);
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'translations',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTranslation(int id) async {
    final db = await database;
    return await db.delete(
      'translations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory({bool keepFavorites = true}) async {
    final db = await database;

    if (keepFavorites) {
      return await db.delete(
        'translations',
        where: 'is_favorite = 0',
      );
    } else {
      return await db.delete('translations');
    }
  }

  Future<Map<String, int>> getStats() async {
    final db = await database;

    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM translations');
    final favoritesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM translations WHERE is_favorite = 1',
    );

    return {
      'total': totalResult.first['count'] as int,
      'favorites': favoritesResult.first['count'] as int,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
