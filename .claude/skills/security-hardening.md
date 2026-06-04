# Security Hardening

## OWASP Mobile Top 10 Coverage

### M1: Improper Credential Usage
- ❌ NEVER hardcode credentials: `const apiKey = 'sk-abc123'`
- ✅ Use `--dart-define`: `const String.fromEnvironment('API_KEY')`
- ✅ Tokens stored in `flutter_secure_storage` (AES-256 encrypted)
- ✅ Certificate pinning via Dio custom HTTP client adapter

### M2: Insecure Supply Chain
- Lock dependency versions in pubspec.yaml
- Run `flutter pub audit` regularly
- CI runs TruffleHog for secret detection on every PR
- CI runs Semgrep for SAST (static application security testing)

### M3: Insecure Authentication/Authorization
- Use `flutter_secure_storage` for tokens (NEVER SharedPreferences)
- Implement biometric auth via `local_auth` package
- Automatic token refresh with `RetryInterceptor`
- Session timeout after inactivity

### M4: Insufficient Input/Output Sanitization
- All user input validated with `AppValidators`
- Output encoded to prevent injection
- Never interpolate user data into SQL queries (use parameterized queries)

### M5: Insecure Communication
- ALL network calls use HTTPS
- Certificate pinning for production builds
- Dio interceptors enforce TLS 1.2+

### M6: Inadequate Privacy Controls
- Data minimization in API requests
- Local cache encryption for sensitive data
- Clear all stored data on logout

### M7: Insufficient Binary Protections
- Release builds use R8/ProGuard obfuscation: `--obfuscate --split-debug-info`
- Root/jailbreak detection via `jailbreak_root_detection`
- Emulator detection in release builds

### M8: Security Misconfiguration
- Debug mode disabled in release builds
- No `debugPrint` in production code paths
- Environment-specific configs via `--dart-define`

### M9: Insecure Data Storage
- `FlutterSecureStorage` with AES_GCM_NoPadding
- Hive boxes with encryption for local DB
- No sensitive data in app directory or external storage

### M10: Insufficient Cryptography
- AES-256-GCM for data at rest
- TLS 1.3 for data in transit
- SHA-256 for data integrity
- No MD5, SHA1, or weak ciphers

## Secret Scanning (MCP Server)
- Shannon entropy threshold: 4.5+
- Regex patterns for: API keys, passwords, tokens, private keys, AWS/GCP/GitHub
- Block writes that contain detected secrets
- Audit log records all scan results

## Code Signing
- Android: KeyStore with strong passwords, stored in CI secrets
- iOS: Automatic code signing via Xcode, distribution certificates in CI
