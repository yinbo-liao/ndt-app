// =============================================================================
// FLUTTER DESIGN MCP SERVER — ENTRY POINT
// =============================================================================
// Starts the MCP server in stdio mode for Claude subagent integration.
//
// Usage: dart run bin/server.dart <project-root-path>
//
// Dependencies (from pubspec.yaml):
//   crypto, path, logging, synchronized, stream_channel
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../lib/config/server_config.dart';
import '../lib/infrastructure/circuit_breaker.dart';
import '../lib/infrastructure/isolate_pool.dart';
import '../lib/infrastructure/rate_limiter.dart';
import '../lib/security/audit_logger.dart';
import '../lib/security/sandbox.dart';
import '../lib/security/secret_scanner.dart';
import '../lib/server/mcp_server.dart';

// ---------------------------------------------------------------------------
// ENTRY POINT
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  // Configure structured logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final entry = {
      'timestamp': record.time.toUtc().toIso8601String(),
      'level': record.level.name,
      'logger': record.loggerName,
      'message': record.message,
      if (record.error != null) 'error': record.error.toString(),
      if (record.stackTrace != null) 'stack': record.stackTrace.toString(),
    };
    stderr.writeln(jsonEncode(entry));
  });

  final logger = Logger('mcp-server');

  // Determine project root from args or current directory
  final projectRoot = args.isNotEmpty ? args.first : Directory.current.path;
  logger.info('Starting MCP server for project: $projectRoot');

  // Initialize configuration
  final config = ServerConfig(projectRoot: projectRoot);
  logger.info('Config loaded: allowed paths=${config.allowedPaths}');

  // Initialize security infrastructure
  final securityManager = SecurityManager(config);
  final secretScanner = SecretScanner(
    entropyThreshold: config.secretEntropyThreshold,
    enabled: config.enableSecretScanning,
  );

  // Initialize resilience infrastructure
  final rateLimiter = TokenBucketRateLimiter(
    capacity: config.rateLimitPerMinute,
    refillPeriod: const Duration(minutes: 1),
  );
  final auditLogger = AuditLogger(config.auditLogPath);
  final circuitBreaker = CircuitBreaker(
    failureThreshold: 10,
    timeout: const Duration(minutes: 1),
  );
  final isolatePool = IsolatePool(minIsolates: 2, maxIsolates: 8);

  await isolatePool.initialize();
  logger.info('Isolate pool initialized: 2-8 workers');

  // Initialize and start the MCP server
  final server = McpServer(
    config: config,
    securityManager: securityManager,
    secretScanner: secretScanner,
    rateLimiter: rateLimiter,
    auditLogger: auditLogger,
    circuitBreaker: circuitBreaker,
    isolatePool: isolatePool,
  );

  // Handle graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    logger.info('Received SIGINT — shutting down gracefully...');
    await server.shutdown();
    await isolatePool.dispose();
    logger.info('Server stopped.');
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((_) async {
    logger.info('Received SIGTERM — shutting down gracefully...');
    await server.shutdown();
    await isolatePool.dispose();
    logger.info('Server stopped.');
    exit(0);
  });

  // Start serving (stdio mode)
  try {
    await server.start();
  } catch (e, stackTrace) {
    logger.severe('Fatal error starting server: $e\n$stackTrace');
    exit(1);
  }
}
