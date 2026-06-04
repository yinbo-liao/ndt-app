import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Authentication service wrapping Supabase Auth.
///
/// Handles sign-in, sign-up, sign-out, session management,
/// and password reset flows.
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Auth State ────────────────────────────────────────────

  /// Stream of auth state changes (sign-in, sign-out, token refresh).
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// The current authenticated user, or null.
  User? get currentUser => _client.auth.currentUser;

  /// The current session, or null.
  Session? get currentSession => _client.auth.currentSession;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => currentSession != null;

  // ── Email / Password ──────────────────────────────────────

  /// Sign in with email and password.
  ///
  /// Returns the [AuthResponse] containing the session and user.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new account with email and password, plus user metadata.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'ndt_team',
    String? ndtCompanyId,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        if (ndtCompanyId != null) 'ndt_company_id': ndtCompanyId,
      },
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Password Reset ────────────────────────────────────────

  /// Send a password reset email to the given address.
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'ndtapp://auth/reset-password',
    );
  }

  // ── Session ───────────────────────────────────────────────

  /// Refresh the current session token.
  Future<Session?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response.session;
  }

  /// Retrieve the current user's role from the session JWT claims.
  /// Falls back to 'ndt_team' if the claim is not present.
  String? get currentRole {
    final jwt = currentSession?.accessToken;
    if (jwt == null) return null;
    // JWT claims are available via auth.currentUser.appMetadata
    // after being set by a database trigger or edge function
    return currentUser?.appMetadata['role'] as String?;
  }

  /// Retrieve the current user's company ID from the session JWT.
  String? get currentCompanyId {
    return currentUser?.appMetadata['ndt_company_id'] as String?;
  }
}
