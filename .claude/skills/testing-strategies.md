# Testing Strategies

## Test Pyramid

```
       /\
      /  \    Integration (E2E flows, native interactions)
     /    \
    /------\
   / Widget \   Widget Tests (pumpWidget, interaction, state)
  /----------\
 /   Unit      \   Unit Tests (pure logic, providers, use cases)
/--------------\
```

## Unit Tests (`test/unit/`)

### What to test:
- Pure Dart logic: use cases, entities, value objects
- State management: provider state transitions
- Utility functions: extensions, formatters, validators
- Error mapping: exception → failure conversion

### Framework:
- `flutter_test` (test runner)
- `mockito` + `build_runner` (mock generation)
- `dartz` (Either for result checking)

### Example pattern:
```dart
test('login emits loading then authenticated on success', () async {
  when(mockRepo.login(any, any)).thenAnswer((_) async => Right(user));
  
  final states = <AuthState>[];
  notifier.addListener((s) => states.add(s));
  
  await notifier.login('test@example.com', 'pass123');
  
  expect(states, [
    const AuthState.loading(),
    AuthState.authenticated(user: user),
  ]);
});
```

## Widget Tests (`test/widget/`)

### What to test:
- Rendering: all variants (enabled, disabled, loading, error, empty)
- Interactions: tap, long-press, scroll, input
- Accessibility: semantic labels, touch targets >= 48×48
- Theme: verify appearance in light and dark mode

### Framework:
- `flutter_test` with `pumpWidget`
- `Finder` API for locating widgets

### Test all states:
```dart
// Every Base widget must test all states:
// ✅ enabled
// ✅ disabled
// ✅ loading
// ✅ error
// ✅ with icon
// ✅ without icon
```

## Golden Tests (`test/golden/`)

### What to test:
- Base layer widgets (pixel-perfect design system)
- Critical UI screens
- All theme variants (light, dark, high-contrast)

### Framework:
- `alchemist` package
- CI runs golden tests on every PR
- Golden files checked into git

## Integration Tests (`integration_test/`)

### What to test:
- Complete user flows (login → home → profile → logout)
- Native interactions (biometrics, notifications, deep links)
- Network error handling and retry behavior

### Framework:
- `patrol` (extends flutter_test with native capabilities)
- `patrol_finders` for native UI elements

## Coverage Targets
- Unit tests: 90%+ line coverage
- Widget tests: 80%+ line coverage  
- Integration tests: critical path coverage
- Overall: 80%+ line coverage (enforced by CI)
