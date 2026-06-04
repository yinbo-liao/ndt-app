# CI/CD Pipeline

## CI Pipeline (on every PR)

```
Push/PR → Analyze → Tests → Golden Tests → Build → Security Scan
```

### Jobs:
1. **Analyze**: `dart format --check` + `flutter analyze --fatal-infos --fatal-warnings`
2. **Tests**: `flutter test --coverage --test-randomize-ordering-seed random` + Codecov upload
3. **Golden Tests**: `flutter test --tags golden` (pixel-perfect visual regression)
4. **Build**: Verify APK, iOS, Web release builds compile
5. **Security Scan**: TruffleHog (secrets) + Semgrep (SAST) + `flutter pub audit`

## CD Pipeline (on git tag `v*`)

```
v1.0.0 tag → Build → Sign → Deploy to Stores
```

### Deploy Targets:
- **Google Play**: Internal track (staging), Production track (production)
- **App Store Connect**: TestFlight (staging), App Store (production)
- **Firebase Hosting**: Staging channel / Live (production)

## Environment Configurations

| Environment | --dart-define key | Values |
|-------------|-------------------|--------|
| Development | `ENV=dev` | Debug enabled, mock APIs, no analytics |
| Staging | `ENV=staging` | Real APIs, limited analytics |
| Production | `ENV=prod` | Real APIs, full analytics, crash reporting |

## CI Commands for Local Testing

```bash
# Format check
dart format lib/ test/ --set-exit-if-changed

# Full static analysis
flutter analyze --fatal-infos --fatal-warnings

# Run all tests
flutter test --coverage

# Build verification
flutter build apk --release --obfuscate --split-debug-info=symbols/
flutter build ios --release --no-codesign
flutter build web --release

# Security scans (requires tools installed)
trufflehog filesystem ./
flutter pub outdated
```
