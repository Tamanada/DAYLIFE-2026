import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/star_transaction_model.dart';

class StarService {
  final SupabaseClient _client;

  StarService() : _client = SupabaseService.instance.client;

  Future<Map<String, dynamic>> recordDailyLogin(String userId) async {
    final response = await _client.rpc('record_daylife_login', params: {
      'p_user_id': userId,
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<int> getStarBalance(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select('total_stars')
        .eq('id', userId)
        .single();
    return response['total_stars'] as int? ?? 0;
  }

  Future<List<StarTransactionModel>> getTransactions(String userId, {int limit = 50}) async {
    final response = await _client
        .from('star_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => StarTransactionModel.fromJson(e)).toList();
  }

  Future<Map<String, int>> getStats(String userId) async {
    final dreamsCreated = await _client
        .from('dreams').select().eq('user_id', userId).count(CountOption.exact);
    final dreamsCompleted = await _client
        .from('dreams').select().eq('user_id', userId).eq('is_completed', true).count(CountOption.exact);
    final reflections = await _client
        .from('reflections').select().eq('user_id', userId).count(CountOption.exact);
    final daysActive = await _client
        .from('daily_logins').select().eq('user_id', userId).count(CountOption.exact);

    return {
      'dreams_created': dreamsCreated.count,
      'dreams_completed': dreamsCompleted.count,
      'reflections': reflections.count,
      'days_active': daysActive.count,
    };
  }
}
