/// Supabase configuration constants.
///
/// Replace these values with your actual Supabase project credentials.
/// For production, load these from environment variables or a secure store.
class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase project URL
  static const String url = 'https://terykodkbgztrvsevgat.supabase.co';

  /// Your Supabase anonymous (public) key
  static const String anonKey = 'sb_publishable_i0S4jUU2qNTBWfUSf_uZ8Q_K3XAy-mr';

  /// Deep link scheme for OAuth redirects and magic links
  static const String deepLinkScheme = 'ndtapp';

  /// Deep link host for authentication callbacks
  static const String deepLinkHost = 'auth';
}
