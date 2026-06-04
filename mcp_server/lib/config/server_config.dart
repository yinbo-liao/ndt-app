/// Server configuration — all tunable parameters in one place.
///
/// In production, these values are loaded from environment variables
/// or a config file. Defaults are safe for local development.
class ServerConfig {
  /// Absolute path to the Flutter project root.
  final String projectRoot;

  /// Subdirectories within project root that the server can access.
  final List<String> allowedPaths;

  /// Whitelist of executable → allowed subcommands.
  final Map<String, List<String>> allowedCommands;

  /// Regex patterns that block command execution (injection prevention).
  final List<RegExp> forbiddenPatterns;

  /// Maximum file size for read operations (bytes).
  final int maxFileSize;

  /// Maximum file size for write operations (bytes).
  final int maxWriteSize;

  /// Maximum MCP tool calls per minute.
  final int rateLimitPerMinute;

  /// Maximum concurrent operations per isolate.
  final int maxConcurrentOperations;

  /// Per-operation timeout.
  final Duration operationTimeout;

  /// Heartbeat ping interval.
  final Duration heartbeatInterval;

  /// Maximum retry attempts for failed operations.
  final int maxRetries;

  /// Base delay for exponential backoff.
  final Duration retryBaseDelay;

  /// Path to the append-only audit log file.
  final String auditLogPath;

  /// Whether to scan file contents for secrets before writing.
  final bool enableSecretScanning;

  /// Shannon entropy threshold for flagging high-entropy strings.
  final double secretEntropyThreshold;

  ServerConfig({
    required this.projectRoot,
    this.allowedPaths = const [
      'lib/',
      'assets/',
      'test/',
      'integration_test/',
    ],
    this.allowedCommands = const {
      'flutter': ['pub', 'analyze', 'test', 'build', 'clean', 'doctor'],
      'dart': ['format', 'fix', 'compile', 'run'],
      'git': ['status', 'diff', 'log', 'blame'],
    },
    List<RegExp>? forbiddenPatterns,
  })  : forbiddenPatterns = forbiddenPatterns ?? _defaultForbiddenPatterns,
        maxFileSize = 1048576, // 1 MB
        maxWriteSize = 524288, // 500 KB
        rateLimitPerMinute = 100,
        maxConcurrentOperations = 4,
        operationTimeout = const Duration(seconds: 30),
        heartbeatInterval = const Duration(seconds: 30),
        maxRetries = 5,
        retryBaseDelay = const Duration(milliseconds: 100),
        auditLogPath = '.mcp/audit.log',
        enableSecretScanning = true,
        secretEntropyThreshold = 4.5;

  static final List<RegExp> _defaultForbiddenPatterns = [
    RegExp(r'rm\s+-rf'),
    RegExp(r'>\s*/dev/'),
    RegExp(r'curl.*\|.*sh'),
    RegExp(r'eval\s*\('),
    RegExp(r'System\.(exit|exec)'),
  ];
}
