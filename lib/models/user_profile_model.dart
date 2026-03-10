class UserProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? displayName;
  final String? profilePhotoUrl;
  final String? dicebearSeed;
  final String dicebearStyle;
  final int totalStars;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLoginDate;
  final String preferredLanguage;
  final String themePreference;
  final bool onboardingCompleted;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.dateOfBirth,
    this.displayName,
    this.profilePhotoUrl,
    this.dicebearSeed,
    this.dicebearStyle = 'adventurer',
    this.totalStars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLoginDate,
    this.preferredLanguage = 'en',
    this.themePreference = 'system',
    this.onboardingCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      displayName: json['display_name'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      dicebearSeed: json['dicebear_seed'] as String?,
      dicebearStyle: json['dicebear_style'] as String? ?? 'adventurer',
      totalStars: json['total_stars'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastLoginDate: json['last_login_date'] != null
          ? DateTime.tryParse(json['last_login_date'] as String)
          : null,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      themePreference: json['theme_preference'] as String? ?? 'system',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'display_name': displayName,
      'profile_photo_url': profilePhotoUrl,
      'dicebear_seed': dicebearSeed,
      'dicebear_style': dicebearStyle,
      'total_stars': totalStars,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_login_date': lastLoginDate?.toIso8601String(),
      'preferred_language': preferredLanguage,
      'theme_preference': themePreference,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get daysLived =>
      dateOfBirth != null ? DateTime.now().difference(dateOfBirth!).inDays : 0;

  int get daysRemaining => (30000 - daysLived).clamp(0, 30000);

  double get lifeProgress => daysLived / 30000;

  String get avatarUrl =>
      profilePhotoUrl ??
      'https://api.dicebear.com/9.x/$dicebearStyle/png?seed=${dicebearSeed ?? id}';
}
