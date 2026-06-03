import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  String get userName {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Guest User';
    final name = user.userMetadata?['full_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return user.email ?? 'User';
  }

  String get userEmail {
    final user = _supabase.auth.currentUser;
    return user?.email ?? '';
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone ?? ''},
    );

    // Auto-create profile in profiles table
    if (response.user != null) {
      try {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': name,
          'email': email,
          'phone': phone ?? '',
          'role': 'user',
        });
      } catch (e) {
        // Profile might already exist or RLS issue
      }
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
