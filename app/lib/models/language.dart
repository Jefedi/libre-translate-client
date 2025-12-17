class Language {
  final String code;
  final String name;
  final String? nativeName;

  Language({
    required this.code,
    required this.name,
    this.nativeName,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
    };
  }

  @override
  String toString() => nativeName ?? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
