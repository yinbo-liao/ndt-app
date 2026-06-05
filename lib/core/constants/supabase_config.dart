/// Supabase configuration constants.
///
/// Replace these values with your actual Supabase project credentials.
/// For production, load these from environment variables or a secure store.
class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase project URL
  static const String url = 'https://cgrkewpsxlkvycxpizth.supabase.co';

  /// Your Supabase anonymous (public) key
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNncmtld3BzeGxrdnljeHBpenRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NjUxNDMsImV4cCI6MjA5NjI0MTE0M30.FKunpfVmJ1PsXeBTpNWMnN43N8vaMVstCSfoh0k2V00';

  /// Deep link scheme for OAuth redirects and magic links
  static const String deepLinkScheme = 'ndtapp';

  /// Deep link host for authentication callbacks
  static const String deepLinkHost = 'auth';
}
