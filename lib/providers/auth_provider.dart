import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';

/// Provides the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream of auth state changes (sign-in, sign-out, session refresh).
final authStateChangesProvider = StreamProvider<AuthState?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((state) => state);
});

/// The currently authenticated user, or null.
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Whether the user is authenticated.
///
/// Re-evaluates whenever [authStateChangesProvider] emits (sign-in, sign-out,
/// token refresh) so that [GoRouter] redirects and UI rebuild correctly.
final isAuthenticatedProvider = Provider<bool>((ref) {
  ref.watch(authStateChangesProvider);
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});

/// The current user's role from JWT app_metadata, or null.
final currentUserRoleProvider = Provider<String?>((ref) {
  ref.watch(authStateChangesProvider);
  final authService = ref.watch(authServiceProvider);
  return authService.currentRole;
});

/// The current user's company ID from JWT app_metadata, or null.
final currentUserCompanyIdProvider = Provider<String?>((ref) {
  ref.watch(authStateChangesProvider);
  final authService = ref.watch(authServiceProvider);
  return authService.currentCompanyId;
});
