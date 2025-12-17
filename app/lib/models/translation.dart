class Translation {
  final int? id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final bool fromCache;
  final List<String>? alternatives;
  final bool isFavorite;

  Translation({
    this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.fromCache = false,
    this.alternatives,
    this.isFavorite = false,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as int?,
      originalText: json['original_text'] as String,
      translatedText: json['translated_text'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fromCache: (json['from_cache'] as int?) == 1,
      alternatives: json['alternatives'] != null
          ? (json['alternatives'] as String).split('|||')
          : null,
      isFavorite: (json['is_favorite'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_text': originalText,
      'translated_text': translatedText,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'from_cache': fromCache ? 1 : 0,
      'alternatives': alternatives?.join('|||'),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  Translation copyWith({
    int? id,
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    bool? fromCache,
    List<String>? alternatives,
    bool? isFavorite,
  }) {
    return Translation(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      fromCache: fromCache ?? this.fromCache,
      alternatives: alternatives ?? this.alternatives,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
