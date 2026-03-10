import 'package:flutter/material.dart';

/// Total estimated life days (~82 years)
const int kTotalLifeDays = 30000;

/// Lunar color palette
class DaylifeColors {
  DaylifeColors._();

  static const Color midnightBlue = Color(0xFF0D1B2A);
  static const Color navyBlue = Color(0xFF1B2838);
  static const Color deepNavy = Color(0xFF152238);
  static const Color silverLight = Color(0xFFC0C0C0);
  static const Color silverBright = Color(0xFFD4D4D4);
  static const Color sandGold = Color(0xFFCDB38B);
  static const Color sandLight = Color(0xFFE8D5B7);
  static const Color moonWhite = Color(0xFFF5F5F0);
  static const Color starYellow = Color(0xFFFFD700);
  static const Color cosmicPurple = Color(0xFF6B5B95);
  static const Color successGreen = Color(0xFF4A8B6F);
  static const Color errorCoral = Color(0xFFEF6461);
}

class DreamCategories {
  DreamCategories._();

  static const Map<String, Color> colors = {
    'general': Color(0xFFC0C0C0),
    'career': Color(0xFFB8860B),
    'health': Color(0xFF4A8B6F),
    'personal': Color(0xFF6B7DB3),
    'travel': Color(0xFFC2955D),
    'education': Color(0xFF8B6DAF),
  };

  static const List<String> all = ['general', 'career', 'health', 'personal', 'travel', 'education'];

  static String label(String category) => switch (category) {
    'career' => 'Career',
    'health' => 'Health',
    'personal' => 'Personal',
    'travel' => 'Travel',
    'education' => 'Education',
    _ => 'General',
  };
}

class StarRewards {
  StarRewards._();
  static const int dailyLogin = 1;
  static const int addDream = 2;
  static const int completeGoal = 3;
  static const int streakBonus = 10;
  static const int reflection = 1;
  static const int streakInterval = 7;
}

class AvatarStyles {
  AvatarStyles._();
  static const List<String> all = [
    'adventurer', 'avataaars', 'bottts', 'fun-emoji',
    'lorelei', 'notionists', 'pixel-art', 'thumbs',
  ];
  static String url(String style, String seed, {int size = 200}) =>
      'https://api.dicebear.com/9.x/$style/png?seed=$seed&size=$size';
}
