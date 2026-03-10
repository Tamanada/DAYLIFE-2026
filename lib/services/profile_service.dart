import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService() : _client = SupabaseService.instance.client;

  Future<UserProfileModel> getProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfileModel.fromJson(response);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('user_profiles').update(updates).eq('id', userId);
  }

  Future<void> completeOnboarding({
    required String userId,
    required String displayName,
    required DateTime dateOfBirth,
    String? dicebearSeed,
    String? dicebearStyle,
  }) async {
    await _client.from('user_profiles').update({
      'display_name': displayName,
      'full_name': displayName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'dicebear_seed': dicebearSeed ?? userId,
      'dicebear_style': dicebearStyle ?? 'adventurer',
      'onboarding_completed': true,
    }).eq('id', userId);
  }

  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    final ext = imageFile.path.split('.').last;
    final path = '$userId/avatar.$ext';

    await _client.storage.from('profile-photos').upload(
      path,
      imageFile,
      fileOptions: const FileOptions(upsert: true),
    );

    final url = _client.storage.from('profile-photos').getPublicUrl(path);

    await _client.from('user_profiles').update({
      'profile_photo_url': url,
    }).eq('id', userId);

    return url;
  }

  Future<void> updateAvatar(String userId, String seed, String style) async {
    await _client.from('user_profiles').update({
      'dicebear_seed': seed,
      'dicebear_style': style,
      'profile_photo_url': null,
    }).eq('id', userId);
  }

  Future<void> updateTheme(String userId, String theme) async {
    await _client.from('user_profiles').update({
      'theme_preference': theme,
    }).eq('id', userId);
  }
}
