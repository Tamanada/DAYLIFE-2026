class ReflectionModel {
  final String id;
  final String userId;
  final DateTime reflectionDate;
  final String? learned;
  final String? grateful;
  final String? improve;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReflectionModel({
    required this.id,
    required this.userId,
    required this.reflectionDate,
    this.learned,
    this.grateful,
    this.improve,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reflectionDate: DateTime.tryParse(json['reflection_date'] as String) ??
          DateTime.now(),
      learned: json['learned'] as String?,
      grateful: json['grateful'] as String?,
      improve: json['improve'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reflection_date': reflectionDate.toIso8601String(),
      'learned': learned,
      'grateful': grateful,
      'improve': improve,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isComplete =>
      (learned?.isNotEmpty ?? false) &&
      (grateful?.isNotEmpty ?? false) &&
      (improve?.isNotEmpty ?? false);
}
