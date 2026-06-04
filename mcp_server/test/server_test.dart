import 'package:test/test.dart';

import '../lib/config/server_config.dart';
import '../lib/security/sandbox.dart';
import '../lib/security/secret_scanner.dart';
import '../lib/infrastructure/circuit_breaker.dart';
import '../lib/infrastructure/rate_limiter.dart';

void main() {
  group('SecurityManager', () {
    late ServerConfig config;
    late SecurityManager security;

    setUp(() {
      config = ServerConfig(projectRoot: '/test/project');
      security = SecurityManager(config);
    });

    test('rejects path traversal', () async {
      final result = await security.validatePath('/etc/passwd');
      expect(result, isFalse);
    });

    test('rejects command not in allowlist', () {
      final result = security.validateCommand('rm', ['-rf', '/']);
      expect(result, isFalse);
    });

    test('allows whitelisted flutter command', () {
      final result = security.validateCommand('flutter', ['analyze', 'lib/']);
      expect(result, isTrue);
    });

    test('accepts package subcommands', () {
      final result = security.validateCommand('flutter', ['pub', 'get']);
      expect(result, isTrue);
    });
  });

  group('SecretScanner', () {
    late SecretScanner scanner;

    setUp(() {
      scanner = SecretScanner(entropyThreshold: 4.5, enabled: true);
    });

    test('detects high-entropy tokens', () {
      final content = 'api_key = "dGhpcyBpcyBhIHRlc3QgdG9rZW4gZm9yIHNjYW5uaW5n"';
      final findings = scanner.scan(content, 'test.dart');
      expect(findings.any((f) => f.type == 'high_entropy_token'), isTrue);
    });

    test('detects AWS access keys', () {
      final content = 'const key = "AKIAIOSFODNN7EXAMPLE"';
      final findings = scanner.scan(content, 'test.dart');
      expect(findings.any((f) => f.type == 'aws_access_key'), isTrue);
    });

    test('detects hardcoded passwords', () {
      final content = "password = 'super_secret_123'";
      final findings = scanner.scan(content, 'test.dart');
      expect(findings.any((f) => f.type == 'password_hardcoded'), isTrue);
    });

    test('returns empty for clean content', () {
      final content = 'const message = "Hello, World!"';
      final findings = scanner.scan(content, 'test.dart');
      expect(findings, isEmpty);
    });

    test('respects enabled flag', () {
      final disabledScanner = SecretScanner(enabled: false);
      final content = 'api_key = "dGhpcyBpcyBhIHRlc3QgdG9rZW4gZm9yIHNjYW5uaW5n"';
      final findings = disabledScanner.scan(content, 'test.dart');
      expect(findings, isEmpty);
    });
  });

  group('CircuitBreaker', () {
    test('allows requests when closed', () async {
      final cb = CircuitBreaker(failureThreshold: 3, timeout: Duration(minutes: 1));
      expect(cb.state, CircuitState.closed);

      final result = await cb.execute(() async => 'success');
      expect(result, 'success');
      expect(cb.state, CircuitState.closed);
    });

    test('throws when open after threshold failures', () async {
      final cb = CircuitBreaker(failureThreshold: 2, timeout: Duration(minutes: 1));

      // Force failures
      for (var i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception('fail'));
        } catch (_) {}
      }

      expect(cb.state, CircuitState.open);

      // Next request should be rejected
      expect(
        () => cb.execute(() async => 'blocked'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test('can be manually reset', () async {
      final cb = CircuitBreaker(failureThreshold: 1, timeout: Duration(minutes: 1));

      try {
        await cb.execute(() async => throw Exception('fail'));
      } catch (_) {}

      expect(cb.state, CircuitState.open);

      cb.reset();
      expect(cb.state, CircuitState.closed);
    });
  });

  group('TokenBucketRateLimiter', () {
    test('allows requests within capacity', () async {
      final rl = TokenBucketRateLimiter(capacity: 5, refillPeriod: Duration(minutes: 1));

      for (var i = 0; i < 5; i++) {
        final allowed = await rl.acquire('test');
        expect(allowed, isTrue);
      }
    });

    test('blocks requests beyond capacity', () async {
      final rl = TokenBucketRateLimiter(capacity: 2, refillPeriod: Duration(minutes: 1));

      await rl.acquire('test');
      await rl.acquire('test');
      final allowed = await rl.acquire('test');

      expect(allowed, isFalse);
    });

    test('different keys have separate buckets', () async {
      final rl = TokenBucketRateLimiter(capacity: 1, refillPeriod: Duration(minutes: 1));

      await rl.acquire('key1');
      final allowed = await rl.acquire('key2');

      expect(allowed, isTrue);
    });
  });
}
