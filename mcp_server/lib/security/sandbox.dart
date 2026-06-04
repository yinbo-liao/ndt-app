import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../config/server_config.dart';

/// Path and command security validation.
///
/// Enforces:
/// - All file access must be within the project root
/// - Only whitelisted subdirectories are accessible
/// - All commands must match the allowlist
/// - Forbidden command patterns are blocked
class SecurityManager {
  final ServerConfig _config;
  final Logger _logger;

  SecurityManager(this._config) : _logger = Logger('SecurityManager');

  /// Validates that [path] is within the project root and an allowed
  /// subdirectory. Resolves symlinks to prevent bypass attacks.
  Future<bool> validatePath(String path) async {
    try {
      final canonical = await _resolveCanonical(path);
      final projectRoot = await _resolveCanonical(_config.projectRoot);

      // Must be within project root (prevents path traversal)
      if (!p.isWithin(projectRoot, canonical) && canonical != projectRoot) {
        _logger.warning(
          'Path traversal attempt blocked: $path → $canonical',
        );
        return false;
      }

      // Must be in an allowed subdirectory
      final relative = p.relative(canonical, from: projectRoot);
      final isAllowed = _config.allowedPaths.any(
        (allowed) =>
            relative.startsWith(allowed) ||
            relative == allowed.replaceAll('/', ''),
      );

      if (!isAllowed) {
        _logger.warning('Path outside allowed directories: $relative');
        return false;
      }

      return true;
    } catch (e) {
      _logger.warning('Path validation error: $e');
      return false;
    }
  }

  /// Validates that [command] and [args] match the allowlist and
  /// do not contain forbidden patterns.
  bool validateCommand(String command, List<String> args) {
    // Split command in case it contains args (e.g., "flutter analyze")
    final parts = command.split(' ');
    final executable = parts.first;
    final baseCommand = parts.length > 1 ? parts[1] : args.firstOrNull ?? '';
    final remainingArgs = parts.length > 1
        ? parts.sublist(2).followedBy(args.length > 1 ? args.sublist(1) : []).toList()
        : (args.length > 1 ? args.sublist(1) : <String>[]);

    // Check executable is allowed
    final allowedSubcommands = _config.allowedCommands[executable];
    if (allowedSubcommands == null) {
      _logger.warning('Executable not in allowlist: $executable');
      return false;
    }

    // Check base command is allowed
    if (!allowedSubcommands.contains(baseCommand)) {
      _logger.warning(
        'Command not allowed: $executable $baseCommand',
      );
      return false;
    }

    // Check for forbidden patterns in full command
    final fullCommand = '$executable $baseCommand ${remainingArgs.join(' ')}';
    for (final pattern in _config.forbiddenPatterns) {
      if (pattern.hasMatch(fullCommand)) {
        _logger.severe(
          'Forbidden pattern detected: $pattern in command: $fullCommand',
        );
        return false;
      }
    }

    return true;
  }

  /// Resolves a path to its canonical (real) absolute form,
  /// following symlinks to prevent bypass attacks.
  Future<String> _resolveCanonical(String pathStr) async {
    final file = File(pathStr);
    try {
      if (await file.exists()) {
        return p.canonicalize(await file.resolveSymbolicLinks());
      }
    } catch (_) {
      // Fall through to non-symlink resolution
    }
    return p.canonicalize(p.absolute(pathStr));
  }
}
