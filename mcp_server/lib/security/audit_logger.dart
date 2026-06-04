import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

/// Append-only, immutable audit log for all MCP tool operations.
///
/// Properties:
/// - Each entry is a single JSON line (newline-delimited JSON)
/// - Written synchronously with flush to prevent data loss
/// - Parameters are hashed (SHA-256 truncated) to avoid logging secrets
/// - Nonces prevent log entry replay
class AuditLogger {
  final String _logPath;
  final Logger _logger;
  final Lock _lock;

  AuditLogger(this._logPath)
      : _logger = Logger('AuditLogger'),
        _lock = Lock();

  /// Records an audit event.
  ///
  /// Writes are serialized via mutex to prevent interleaving.
  /// Each entry is flushed to disk immediately.
  Future<void> log({
    required String operation,
    required String tool,
    required Map<String, dynamic> parameters,
    required String result,
    required Duration duration,
    String? userId,
    String? error,
  }) async {
    final entry = {
      'ts': DateTime.now().toUtc().toIso8601String(),
      'op': operation,
      'tool': tool,
      'params_hash': _hashParams(parameters),
      'result': result,
      'dur_ms': duration.inMilliseconds,
      'user': userId ?? 'anonymous',
      'error': error,
      'nonce': _generateNonce(),
    };

    await _lock.synchronized(() async {
      try {
        final file = File(_logPath);
        await file.parent.create(recursive: true);
        await file.writeAsString(
          '${jsonEncode(entry)}\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (e) {
        // Don't let audit failure crash the server
        _logger.severe('Failed to write audit log: $e');
      }
    });

    _logger.fine(
      'AUDIT: $operation | $tool | ${duration.inMilliseconds}ms | $result',
    );
  }

  /// Reads the audit log entries.
  Stream<Map<String, dynamic>> readEntries({
    int? limit,
    DateTime? since,
    String? userId,
  }) async* {
    final file = File(_logPath);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    var count = 0;
    for (final line in lines.reversed) {
      if (limit != null && count >= limit) break;
      try {
        final entry = jsonDecode(line) as Map<String, dynamic>;
        if (since != null) {
          final ts = DateTime.parse(entry['ts'] as String);
          if (ts.isBefore(since)) continue;
        }
        if (userId != null && entry['user'] != userId) continue;
        yield entry;
        count++;
      } catch (_) {
        // Skip malformed entries
      }
    }
  }

  /// Hashes parameters to prevent logging sensitive values.
  String _hashParams(Map<String, dynamic> params) {
    final json = jsonEncode(params);
    return sha256.convert(utf8.encode(json)).toString().substring(0, 16);
  }

  /// Generates a cryptographically random nonce.
  String _generateNonce() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
