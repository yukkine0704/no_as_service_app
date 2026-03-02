/// Data model representing a "No" phrase from the API.
///
/// This model is used to deserialize JSON responses from the
/// NoWay API endpoint.
class NoPhrase {
  /// Unique identifier for the phrase
  final String id;

  /// The actual "No" phrase text
  final String phrase;

  /// Optional category or tag for the phrase
  final String? category;

  /// Optional description providing more context
  final String? description;

  /// Timestamp when the phrase was created on the server
  final DateTime? createdAt;

  /// Constructs a new NoPhrase instance.
  const NoPhrase({
    required this.id,
    required this.phrase,
    this.category,
    this.description,
    this.createdAt,
  });

  /// Creates a NoPhrase instance from a JSON map.
  ///
  /// Handles various field names that might be returned by the API.
  /// If no ID is provided, generates a hash-based ID from the phrase content.
  factory NoPhrase.fromJson(Map<String, dynamic> json) {
    // Extract the phrase text from various possible field names
    final phraseText = json['phrase']?.toString() ?? 
                       json['text']?.toString() ?? 
                       json['no']?.toString() ??
                       json['reason']?.toString() ?? 
                       '';
    
    // Generate ID from phrase content hash if not provided
    final idValue = json['id']?.toString();
    final String generatedId = (idValue?.isNotEmpty == true) 
        ? idValue! 
        : _generateIdFromPhrase(phraseText);
    
    return NoPhrase(
      id: generatedId,
      phrase: phraseText,
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Generates a unique ID from the phrase content using hash.
  static String _generateIdFromPhrase(String phrase) {
    if (phrase.isEmpty) return DateTime.now().millisecondsSinceEpoch.toString();
    return phrase.hashCode.abs().toString();
  }

  /// Converts this NoPhrase instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phrase': phrase,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoPhrase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoPhrase(id: $id, phrase: $phrase, category: $category)';
  }

  /// Creates a copy of this NoPhrase with the given fields replaced.
  NoPhrase copyWith({
    String? id,
    String? phrase,
    String? category,
    String? description,
    DateTime? createdAt,
  }) {
    return NoPhrase(
      id: id ?? this.id,
      phrase: phrase ?? this.phrase,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
