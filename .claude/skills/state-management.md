# State Management — Riverpod

## Provider Types

### Provider (read-only, derived state)
```dart
final userRepoProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(dio: ref.watch(dioProvider));
});
```

### StateNotifierProvider (mutable state with logic)
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(loginUseCase: ref.watch(loginUseCaseProvider));
});
```

### FutureProvider / StreamProvider (async data)
```dart
final userStreamProvider = StreamProvider<User>((ref) {
  return ref.watch(authRepositoryProvider).userStream();
});
```

## State Classes (Freezed)

ALL state classes use `@freezed` for:
- Exhaustive pattern matching (no missing variant at runtime)
- Immutability (compile-time guarantee)
- `copyWith` for partial updates
- JSON serialization support

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({required User user}) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error({required String message}) = AuthError;
}
```

## Watching & Reading

```dart
// Watch: rebuilds when value changes
final state = ref.watch(authProvider);

// Read: one-time access, no rebuild
final notifier = ref.read(authProvider.notifier);

// Listen: side effects (navigation, snackbars)
ref.listen<AuthState>(authProvider, (prev, next) {
  if (next is AuthAuthenticated) {
    context.goNamed('home');
  }
});

// Select: watches a specific field (reduces rebuilds)
final email = ref.watch(authProvider.select((s) => s.email));
```

## Patterns

**1. Scoped Providers**: Don't put everything globally. Scope providers to features.

**2. Auto-dispose**: Use `.autoDispose` for providers that should clean up.
```dart
final searchProvider = StateProvider.autoDispose<String>((ref) => '');
```

**3. Family providers**: Parameterize providers by ID.
```dart
final userProvider = FutureProvider.family<User, String>((ref, id) {
  return ref.watch(userRepoProvider).getUser(id);
});
```

**4. Error handling**: Every state must have an error variant. Errors are displayed in the Page layer, not swallowed in providers.
