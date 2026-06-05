import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

class NdtManagementApp extends ConsumerWidget {
  const NdtManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Listen to auth state changes and invalidate dependent providers
    // so GoRouter redirects and UI rebuild when the user signs in/out.
    // Using ref.listen avoids blocking on the stream's first emission —
    // the initial session check is synchronous via authService.currentSession.
    ref.listen(authStateChangesProvider, (prev, next) {
      ref.invalidate(isAuthenticatedProvider);
      ref.invalidate(currentUserRoleProvider);
      ref.invalidate(currentUserCompanyIdProvider);
      ref.invalidate(currentUserProvider);
    });

    return MaterialApp.router(
      title: 'NDT Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
