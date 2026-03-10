import 'package:flutter/material.dart';

class StarTransactionModel {
  final String id;
  final String userId;
  final String reason;
  final int amount;
  final String? referenceType;
  final String? referenceId;
  final DateTime createdAt;

  StarTransactionModel({
    required this.id,
    required this.userId,
    required this.reason,
    required this.amount,
    this.referenceType,
    this.referenceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StarTransactionModel.fromJson(Map<String, dynamic> json) {
    return StarTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reason: json['reason'] as String,
      amount: json['amount'] as int,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reason': reason,
      'amount': amount,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayReason => switch (reason) {
        'daily_login' => 'Daily Login',
        'add_dream' => 'New Dream',
        'complete_goal' => 'Goal Completed',
        'streak_bonus' => 'Streak Bonus',
        'reflection' => 'Reflection',
        _ => reason,
      };

  IconData get icon => switch (reason) {
        'daily_login' => Icons.login_rounded,
        'add_dream' => Icons.auto_awesome,
        'complete_goal' => Icons.check_circle_rounded,
        'streak_bonus' => Icons.local_fire_department_rounded,
        'reflection' => Icons.edit_note_rounded,
        _ => Icons.star_rounded,
      };
}
