import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Stream<AuthState> get authStateStream => client.auth.onAuthStateChange;
}
