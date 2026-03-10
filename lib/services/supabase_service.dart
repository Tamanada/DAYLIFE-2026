import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://udploueifisjjyhhsgyb.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkcGxvdWVpZmlzamp5aGhzZ3liIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwOTg4MjQsImV4cCI6MjA4ODY3NDgyNH0.iLRWwNe_zKH5NrdOYn7bOcvtbCj6aOKg4afx3s_iN9I',
  );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  SupabaseClient get client {
    if (!_initialized) throw StateError('Supabase not initialized');
    return Supabase.instance.client;
  }

  String? getCurrentUserId() {
    if (!isInitialized) return null;
    return client.auth.currentUser?.id;
  }
}
