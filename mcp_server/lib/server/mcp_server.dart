import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../config/server_config.dart';
import '../infrastructure/circuit_breaker.dart';
import '../infrastructure/isolate_pool.dart';
import '../infrastructure/rate_limiter.dart';
import '../security/audit_logger.dart';
import '../security/sandbox.dart';
import '../security/secret_scanner.dart';
import '../tools/command_tools.dart';
import '../tools/file_tools.dart';
import '../tools/validation_tools.dart';

/// MCP server state machine.
enum ServerState { initializing, ready, shuttingDown, stopped }

/// The main MCP server that orchestrates all components.
///
/// Communicates via stdio using JSON-RPC-style messages for MCP protocol.
/// Each tool call goes through: auth → rate limit → circuit breaker → execute → audit.
class McpServer {
  final ServerConfig _config;
  final SecurityManager _securityManager;
  final SecretScanner _secretScanner;
  final TokenBucketRateLimiter _rateLimiter;
  final AuditLogger _auditLogger;
  final CircuitBreaker _circuitBreaker;
  final IsolatePool _isolatePool;

  late final FileTools _fileTools;
  late final CommandTools _commandTools;
  late final ValidationTools _validationTools;

  final Logger _logger = Logger('McpServer');
  ServerState _state = ServerState.initializing;
  Timer? _heartbeat;
  StreamSubscription<String>? _stdinSub;

  McpServer({
    required ServerConfig config,
    required SecurityManager securityManager,
    required SecretScanner secretScanner,
    required TokenBucketRateLimiter rateLimiter,
    required AuditLogger auditLogger,
    required CircuitBreaker circuitBreaker,
    required IsolatePool isolatePool,
  })  : _config = config,
        _securityManager = securityManager,
        _secretScanner = secretScanner,
        _rateLimiter = rateLimiter,
        _auditLogger = auditLogger,
        _circuitBreaker = circuitBreaker,
        _isolatePool = isolatePool {
    _fileTools = FileTools(
      config: config,
      security: securityManager,
      secretScanner: secretScanner,
    );
    _commandTools = CommandTools(
      config: config,
      security: securityManager,
    );
    _validationTools = ValidationTools(
      config: config,
      security: securityManager,
      secretScanner: secretScanner,
      commandTools: _commandTools,
    );
  }

  /// Current server state.
  ServerState get state => _state;

  /// Starts the MCP server in stdio mode.
  Future<void> start() async {
    _state = ServerState.ready;
    _logger.info('MCP server ready — listening on stdio');

    // Start heartbeat
    _heartbeat = Timer.periodic(_config.heartbeatInterval, (_) {
      _logger.fine('Heartbeat: ok');
    });

    // Listen on stdin for JSON-RPC requests
    final stdinStream = stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    _stdinSub = stdinStream.listen(
      _handleRequest,
      onError: (error) {
        _logger.severe('stdin stream error: $error');
      },
      onDone: () {
        _logger.info('stdin stream closed');
      },
    );

    // Send ready signal
    _sendResponse({'type': 'ready', 'version': '1.0.0'});
  }

  /// Handles an incoming MCP request line.
  Future<void> _handleRequest(String line) async {
    if (line.trim().isEmpty) return;

    try {
      final request = jsonDecode(line) as Map<String, dynamic>;
      final tool = request['tool'] as String?;
      final params = request['params'] as Map<String, dynamic>? ?? {};
      final requestId = request['id'] as String? ?? 'unknown';

      _logger.info('Request: $tool (id: $requestId)');

      if (tool == null) {
        _sendError(requestId, 'Missing "tool" field in request');
        return;
      }

      // Rate limiting
      if (!await _rateLimiter.acquire('$tool:${params['user_id'] ?? 'anon'}')) {
        _sendError(requestId, 'Rate limit exceeded for tool: $tool');
        await _auditLogger.log(
          operation: tool,
          tool: tool,
          parameters: params,
          result: 'RATE_LIMITED',
          duration: Duration.zero,
        );
        return;
      }

      // Execute via circuit breaker
      final startTime = DateTime.now();
      try {
        final result = await _circuitBreaker.execute(
          () => _executeTool(tool, params),
        );

        final duration = DateTime.now().difference(startTime);
        _sendResponse({
          'id': requestId,
          'tool': tool,
          'result': result,
        });

        await _auditLogger.log(
          operation: tool,
          tool: tool,
          parameters: params,
          result: 'SUCCESS',
          duration: duration,
        );
      } on CircuitBreakerOpenException {
        _sendError(requestId, 'Service temporarily unavailable (circuit open)');
        await _auditLogger.log(
          operation: tool,
          tool: tool,
          parameters: params,
          result: 'CIRCUIT_OPEN',
          duration: DateTime.now().difference(startTime),
          error: 'Circuit breaker is open',
        );
      } catch (e) {
        _sendError(requestId, 'Tool execution failed: $e');
        await _auditLogger.log(
          operation: tool,
          tool: tool,
          parameters: params,
          result: 'ERROR',
          duration: DateTime.now().difference(startTime),
          error: e.toString(),
        );
      }
    } catch (e) {
      _logger.severe('Error parsing request: $e');
      _sendError('parse_error', 'Invalid JSON: $e');
    }
  }

  /// Routes a tool name to its handler.
  Future<Map<String, dynamic>> _executeTool(
    String tool,
    Map<String, dynamic> params,
  ) async {
    return switch (tool) {
      'read_file' => await _handleReadFile(params),
      'write_file' => await _handleWriteFile(params),
      'multi_edit' => await _handleMultiEdit(params),
      'run_command' => await _handleRunCommand(params),
      'validate_ui_layer' => await _handleValidateUiLayer(params),
      'scan_secrets' => await _handleScanSecrets(params),
      'analyze_project' => await _handleAnalyzeProject(params),
      'health_check' => await _handleHealthCheck(params),
      _ => {'error': 'Unknown tool: $tool'},
    };
  }

  // --- Tool Handlers ---

  Future<Map<String, dynamic>> _handleReadFile(
    Map<String, dynamic> params,
  ) async {
    final result = await _fileTools.readFile(
      path: params['path'] as String,
      maxSize: params['max_size'] as int?,
      offset: params['offset'] as int?,
      limit: params['limit'] as int?,
    );

    return {
      'success': result.success,
      if (result.content != null) 'content': result.content,
      if (result.error != null) 'error': result.error,
      if (result.secretFindings != null)
        'warnings': result.secretFindings!.map((s) => s.toJson()).toList(),
    };
  }

  Future<Map<String, dynamic>> _handleWriteFile(
    Map<String, dynamic> params,
  ) async {
    final result = await _fileTools.writeFile(
      path: params['path'] as String,
      content: params['content'] as String,
      checksum: params['checksum'] as String,
      backup: params['backup'] as bool? ?? true,
    );

    return {
      'success': result.success,
      if (result.error != null) 'error': result.error,
    };
  }

  Future<Map<String, dynamic>> _handleMultiEdit(
    Map<String, dynamic> params,
  ) async {
    final operations =
        (params['operations'] as List).cast<Map<String, dynamic>>();
    final result = await _fileTools.multiEdit(
      operations: operations,
      atomic: params['atomic'] as bool? ?? true,
    );

    return {
      'success': result.success,
      if (result.content != null) 'message': result.content,
      if (result.error != null) 'error': result.error,
    };
  }

  Future<Map<String, dynamic>> _handleRunCommand(
    Map<String, dynamic> params,
  ) async {
    final result = await _commandTools.runCommand(
      command: params['command'] as String,
      args: (params['args'] as List?)?.cast<String>() ?? [],
      cwd: params['cwd'] as String?,
      timeout: params['timeout'] as int?,
      env: params['env'] != null
          ? Map<String, String>.from(params['env'] as Map)
          : null,
    );

    return {
      'success': result.isSuccess,
      'exit_code': result.exitCode,
      'stdout': result.stdout,
      'stderr': result.stderr,
      'timed_out': result.timedOut,
    };
  }

  Future<Map<String, dynamic>> _handleValidateUiLayer(
    Map<String, dynamic> params,
  ) async {
    final result = await _validationTools.validateUiLayer(
      filePath: params['file_path'] as String,
      layer: params['layer'] as String,
    );

    return {
      'passed': result.passed,
      'violations': result.violations,
    };
  }

  Future<Map<String, dynamic>> _handleScanSecrets(
    Map<String, dynamic> params,
  ) async {
    final paths = (params['paths'] as List).cast<String>();
    final results = await _validationTools.scanSecrets(paths: paths);

    final allFindings = <Map<String, dynamic>>[];
    for (final entry in results.entries) {
      allFindings.addAll(
        entry.value.map((f) => {
              ...f.toJson(),
              'source': entry.key,
            }),
      );
    }

    return {
      'findings_count': allFindings.length,
      'findings': allFindings,
    };
  }

  Future<Map<String, dynamic>> _handleAnalyzeProject(
    Map<String, dynamic> params,
  ) async {
    final paths = (params['paths'] as List).cast<String>();
    final fatalWarnings = params['fatal_warnings'] as bool? ?? true;

    final result = await _validationTools.analyzeProject(
      paths: paths,
      fatalWarnings: fatalWarnings,
    );

    return {
      'success': result.isSuccess,
      'exit_code': result.exitCode,
      'stdout': result.stdout,
      'stderr': result.stderr,
    };
  }

  Future<Map<String, dynamic>> _handleHealthCheck(
    Map<String, dynamic> params,
  ) async {
    return {
      'status': _state.name,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'version': '1.0.0',
      'circuit_breaker': _circuitBreaker.state.name,
      'isolate_pool': {
        'total': _isolatePool.totalIsolates,
        'busy': _isolatePool.busyIsolates,
        'available': _isolatePool.availableIsolates,
      },
    };
  }

  // --- Communication ---

  void _sendResponse(Map<String, dynamic> response) {
    stdout.writeln(jsonEncode(response));
  }

  void _sendError(String id, String message) {
    _sendResponse({
      'id': id,
      'error': message,
    });
  }

  /// Gracefully shuts down the server.
  Future<void> shutdown() async {
    _state = ServerState.shuttingDown;
    _logger.info('Shutting down MCP server...');

    _heartbeat?.cancel();
    await _stdinSub?.cancel();

    // Flush audit log
    await _auditLogger.log(
      operation: 'shutdown',
      tool: 'system',
      parameters: {},
      result: 'SHUTDOWN',
      duration: Duration.zero,
    );

    _state = ServerState.stopped;
  }
}
