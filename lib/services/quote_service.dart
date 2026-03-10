import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quotes_data.dart';
import '../data/slogans_data.dart';
import '../models/quote_model.dart';
import '../models/slogan_model.dart';

class QuoteService {
  static const _keyQuoteDate = 'daily_quote_date';
  static const _keyQuoteId = 'daily_quote_id';
  static const _keySloganDate = 'daily_slogan_date';
  static const _keySloganId = 'daily_slogan_id';

  final Random _random = Random();

  Future<QuoteModel> getDailyQuote({List<int> unlockedPremiumIds = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final savedDate = prefs.getString(_keyQuoteDate);
    final savedId = prefs.getInt(_keyQuoteId);

    if (savedDate == today && savedId != null) {
      return allQuotes.firstWhere((q) => q.id == savedId, orElse: () => allQuotes.first);
    }

    final available = [
      ...freeQuotes,
      ...premiumQuotes.where((q) => unlockedPremiumIds.contains(q.id)),
    ];

    final quote = available[_random.nextInt(available.length)];
    await prefs.setString(_keyQuoteDate, today);
    await prefs.setInt(_keyQuoteId, quote.id);
    return quote;
  }

  Future<SloganModel> getDailySlogan() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final savedDate = prefs.getString(_keySloganDate);
    final savedId = prefs.getInt(_keySloganId);

    if (savedDate == today && savedId != null) {
      return allSlogans.firstWhere((s) => s.id == savedId, orElse: () => allSlogans.first);
    }

    final slogan = allSlogans[_random.nextInt(allSlogans.length)];
    await prefs.setString(_keySloganDate, today);
    await prefs.setInt(_keySloganId, slogan.id);
    return slogan;
  }
}
