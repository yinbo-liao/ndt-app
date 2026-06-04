import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import '../config/server_config.dart';
import '../security/sandbox.dart';

/// Result of a command execution.
class CommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final bool timedOut;

  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.timedOut = false,
  });

  bool get isSuccess => exitCode == 0 && !timedOut;

  String get summary {
    if (timedOut) return 'TIMED OUT';
    if (exitCode == 0) return 'SUCCESS';
    return 'FAILED (exit code: $exitCode)';
  }
}

/// Handles whitelisted command execution with security validation.
class CommandTools {
  final ServerConfig _config;
  final SecurityManager _security;
  final Logger _logger;

  CommandTools({
    required ServerConfig config,
    required SecurityManager security,
  })  : _config = config,
        _security = security,
        _logger = Logger('CommandTools');

  /// Executes a whitelisted command in the project workspace.
  ///
  /// [command] is the executable (e.g., "flutter").
  /// [args] is the list of arguments (e.g., ["analyze", "lib/"]).
  /// [cwd] is an optional subdirectory within project root.
  /// [timeout] overrides the default 30-second timeout.
  Future<CommandResult> runCommand({
    required String command,
    required List<String> args,
    String? cwd,
    int? timeout,
    Map<String, String>? env,
  }) async {
    // Security validation
    if (!_security.validateCommand(command, args)) {
      return CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command rejected by security policy: $command ${args.join(' ')}',
      );
    }

    // Determine working directory
    String workingDirectory = _config.projectRoot;
    if (cwd != null) {
      workingDirectory = '${_config.projectRoot}/$cwd';
    }

    final effectiveTimeout = Duration(
      seconds: timeout ?? _config.operationTimeout.inSeconds,
    );

    _logger.info('Executing: $command ${args.join(' ')} in $workingDirectory');

    try {
      final result = await Process.run(
        command,
        args,
        workingDirectory: workingDirectory,
        runInShell: false, // Prevent shell injection
        environment: env,
      ).timeout(effectiveTimeout);

      final stdout = (result.stdout as String).trim();
      final stderr = (result.stderr as String).trim();

      if (result.exitCode != 0) {
        _logger.warning(
          'Command failed (exit ${result.exitCode}): $command ${args.join(' ')}',
        );
        if (stderr.isNotEmpty) {
          _logger.warning('STDERR: ${stderr.substring(0, 200)}');
        }
      }

      return CommandResult(
        exitCode: result.exitCode,
        stdout: stdout,
        stderr: stderr,
      );
    } on TimeoutException {
      _logger.warning(
        'Command timed out after ${effectiveTimeout.inSeconds}s: '
        '$command ${args.join(' ')}',
      );
      return CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command timed out after ${effectiveTimeout.inSeconds} seconds',
        timedOut: true,
      );
    } on ProcessException catch (e) {
      _logger.severe('Process error: ${e.message}');
      return CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Process error: ${e.message}',
      );
    }
  }
}
