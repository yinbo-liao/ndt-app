import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_client.dart';

/// Repository for authentication operations.
///
/// Wraps [AuthService] and provides Riverpod-friendly async methods
/// for sign-in, sign-up, sign-out, and session management.
class AuthRepository {
  final AuthService _authService;
  final SupabaseClient _client;

  AuthRepository({
    AuthService? authService,
    SupabaseClient? client,
  })  : _authService = authService ?? AuthService(),
        _client = client ?? SupabaseClientWrapper.instance;

  // ── Auth State ────────────────────────────────────────────

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  Session? get currentSession => _authService.currentSession;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentRole => _authService.currentRole;
  String? get currentCompanyId => _authService.currentCompanyId;

  // ── Email / Password ──────────────────────────────────────

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return _authService.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'ndt_team',
    String? ndtCompanyId,
  }) async {
    return _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      ndtCompanyId: ndtCompanyId,
    );
  }

  Future<void> signOut() => _authService.signOut();

  // ── Session ───────────────────────────────────────────────

  Future<Session?> refreshSession() => _authService.refreshSession();

  Future<void> resetPassword({required String email}) =>
      _authService.resetPassword(email: email);

  // ── Profile ───────────────────────────────────────────────

  /// Fetch the user's profile from the `users` table.
  Future<Map<String, dynamic>?> fetchProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from(SupabaseClientWrapper.tblUsers)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return response;
  }

  /// Update the user's profile in the `users` table.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _client
        .from(SupabaseClientWrapper.tblUsers)
        .update(updates)
        .eq('id', userId);
  }
}
