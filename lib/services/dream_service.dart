import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/dream_model.dart';

class DreamService {
  final SupabaseClient _client;

  DreamService() : _client = SupabaseService.instance.client;

  Future<List<DreamModel>> getDreams(String userId, {bool? isCompleted}) async {
    var query = _client.from('dreams').select().eq('user_id', userId);
    if (isCompleted != null) {
      query = query.eq('is_completed', isCompleted);
    }
    final response = await query.order('sort_order').order('created_at', ascending: false);
    return (response as List).map((e) => DreamModel.fromJson(e)).toList();
  }

  Future<DreamModel> createDream({
    required String userId,
    required String title,
    String? description,
    String category = 'general',
    String colorHex = '#C0C0C0',
    DateTime? deadline,
  }) async {
    final response = await _client.from('dreams').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'color_hex': colorHex,
      'deadline': deadline?.toIso8601String().split('T').first,
    }).select().single();

    final dream = DreamModel.fromJson(response);

    await _client.rpc('award_dream_stars', params: {
      'p_user_id': userId,
      'p_dream_id': dream.id,
    });

    return dream;
  }

  Future<void> updateDream(String dreamId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('dreams').update(updates).eq('id', dreamId);
  }

  Future<void> completeDream(String dreamId, String userId) async {
    await _client.from('dreams').update({
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', dreamId);

    await _client.rpc('award_completion_stars', params: {
      'p_user_id': userId,
      'p_dream_id': dreamId,
    });
  }

  Future<void> uncompleteDream(String dreamId) async {
    await _client.from('dreams').update({
      'is_completed': false,
      'completed_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', dreamId);
  }

  Future<void> deleteDream(String dreamId) async {
    await _client.from('dreams').delete().eq('id', dreamId);
  }
}
