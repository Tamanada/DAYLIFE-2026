import 'package:flutter/material.dart';

class DreamModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final String colorHex;
  final DateTime? deadline;
  final DateTime? completedAt;
  final bool isCompleted;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  DreamModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category = 'personal',
    this.colorHex = '#FF6B6B',
    this.deadline,
    this.completedAt,
    this.isCompleted = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DreamModel.fromJson(Map<String, dynamic> json) {
    return DreamModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'personal',
      colorHex: json['color_hex'] as String? ?? '#FF6B6B',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
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
      'title': title,
      'description': description,
      'category': category,
      'color_hex': colorHex,
      'deadline': deadline?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  bool get isOverdue =>
      deadline != null && !isCompleted && DateTime.now().isAfter(deadline!);

  int? get daysUntilDeadline => deadline?.difference(DateTime.now()).inDays;
}
