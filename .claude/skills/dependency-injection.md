# Dependency Injection — get_it + injectable

## Setup

```dart
// lib/core/di/injection.dart
final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

## Registration

### Singleton (one instance for app lifetime)
```dart
@singleton
class AuthRepositoryImpl implements AuthRepository { ... }
```

### Lazy Singleton (created on first use)
```dart
@lazySingleton
class AnalyticsService { ... }
```

### Factory (new instance each time)
```dart
@injectable
class LoginUseCase extends UseCase<User, LoginParams> { ... }
```

## Modules

Modules provide third-party dependencies:

### Network Module
```dart
@module
abstract class NetworkModule {
  @singleton
  Dio get dio => Dio(BaseOptions(baseUrl: '...'));
}
```

### Storage Module
```dart
@module
abstract class StorageModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(...);
}
```

## Environment-based Resolution

```dart
@InjectableInit()
void configureDependencies({String environment = 'dev'}) =>
    getIt.init(environment: environment);

// Usage:
configureDependencies(environment: 'prod'); // Resolves prod bindings

// Bindings:
@dev
@Injectable()
class MockAuthRepo implements AuthRepository { ... }

@prod
@Injectable()
class RealAuthRepo implements AuthRepository { ... }
```

## Code Generation

After adding/modifying `@injectable` annotations:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `injection.config.dart` which maps all annotated classes.
