import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/reflection_model.dart';

class ReflectionService {
  final SupabaseClient _client;

  ReflectionService() : _client = SupabaseService.instance.client;

  Future<List<ReflectionModel>> getReflections(String userId, {int limit = 30, int offset = 0}) async {
    final response = await _client
        .from('reflections')
        .select()
        .eq('user_id', userId)
        .order('reflection_date', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List).map((e) => ReflectionModel.fromJson(e)).toList();
  }

  Future<ReflectionModel?> getReflectionForDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final response = await _client
        .from('reflections')
        .select()
        .eq('user_id', userId)
        .eq('reflection_date', dateStr)
        .maybeSingle();
    if (response == null) return null;
    return ReflectionModel.fromJson(response);
  }

  Future<ReflectionModel> saveReflection({
    required String userId,
    required DateTime date,
    String? learned,
    String? grateful,
    String? improve,
  }) async {
    final dateStr = date.toIso8601String().split('T').first;
    final existing = await getReflectionForDate(userId, date);
    final isNew = existing == null;

    final data = {
      'user_id': userId,
      'reflection_date': dateStr,
      'learned': learned,
      'grateful': grateful,
      'improve': improve,
      'updated_at': DateTime.now().toIso8601String(),
    };

    Map<String, dynamic> response;
    if (isNew) {
      response = await _client.from('reflections').insert(data).select().single();
      await _client.rpc('award_reflection_stars', params: {
        'p_user_id': userId,
        'p_reflection_id': response['id'],
      });
    } else {
      response = await _client
          .from('reflections')
          .update(data)
          .eq('id', existing.id)
          .select()
          .single();
    }

    return ReflectionModel.fromJson(response);
  }

  Future<void> deleteReflection(String reflectionId) async {
    await _client.from('reflections').delete().eq('id', reflectionId);
  }

  Future<int> getReflectionCount(String userId) async {
    final response = await _client
        .from('reflections')
        .select()
        .eq('user_id', userId)
        .count(CountOption.exact);
    return response.count;
  }
}
