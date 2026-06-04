# Flutter Core Best Practices

## SDK Compatibility
- Target: Flutter 3.44+, Dart 3.12+
- Use `flutter doctor` before any code generation
- Check deprecated APIs: `dart fix --dry-run`

## Project Structure
- Follow Clean Architecture: `core/ → data/ → domain/ → presentation/`
- All new files follow the 4-layer UI architecture
- Test files mirror source structure: `lib/foo/bar.dart` → `test/foo/bar_test.dart`

## Build Commands
```bash
flutter pub get          # Install / refresh dependencies
flutter analyze          # Static analysis (must pass before commit)
flutter test             # Run all tests
flutter test --coverage  # Run with coverage
flutter build apk --release --obfuscate --split-debug-info=symbols/
```

## Null Safety
- Everything is non-nullable by default
- Use `?` only when null is semantically meaningful
- Use late initialization only when value is guaranteed before first read
- Prefer `const` constructors for compile-time constant widgets

## Performance
- Prefer `const` constructors (reduces rebuilds by 50%+)
- Use `ListView.builder` for long lists (not `ListView(children: [...])`)
- Wrap animated subtrees in `RepaintBoundary`
- Use `const` widgets where possible in build methods
- Deferred loading for non-critical modules: `import 'heavy.dart' deferred as heavy;`

## Exports
- Prefer barrel files (`export`) for public API surfaces
- Keep implementation details private (prefix with `_`)
