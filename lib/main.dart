import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize local notifications (mobile only; web is a no-op).
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    if (!kIsWeb) {
      await notificationService.requestPermissions();
    }
  } catch (_) {
    // Notifications are non-critical — silently ignore failures.
  }

  runApp(
    const ProviderScope(
      child: NdtManagementApp(),
    ),
  );
}
