import 'package:logging/logging.dart';

/// Circuit breaker states.
enum CircuitState { closed, open, halfOpen }

/// Exception thrown when a circuit breaker blocks an operation.
class CircuitBreakerOpenException implements Exception {
  final String message;
  const CircuitBreakerOpenException(this.message);

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

/// Circuit breaker pattern implementation — prevents cascading failures.
///
/// - **Closed**: Normal operation, requests pass through.
/// - **Open**: Failures exceeded threshold, requests are rejected immediately.
/// - **Half-Open**: After timeout, a single test request is allowed.
///   If it succeeds → Closed. If it fails → Open again.
class CircuitBreaker {
  final int _failureThreshold;
  final Duration _timeout;
  final Logger _logger;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    required int failureThreshold,
    required Duration timeout,
  })  : _failureThreshold = failureThreshold,
        _timeout = timeout,
        _logger = Logger('CircuitBreaker');

  /// Current state of the circuit breaker.
  CircuitState get state => _state;

  /// Whether the circuit is currently allowing requests.
  bool get isAllowing => _state != CircuitState.open;

  /// Attempts a reset if conditions are met (for manual recovery).
  void reset() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _logger.info('Circuit breaker manually reset to CLOSED');
  }

  /// Executes [operation] with circuit breaker protection.
  ///
  /// If the circuit is OPEN, throws [CircuitBreakerOpenException] immediately.
  /// If HALF-OPEN, allows one test request through.
  /// On success, resets failure count and closes.
  /// On failure, increments failure count and may open the circuit.
  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check if circuit is open
    if (_state == CircuitState.open) {
      if (_lastFailureTime != null &&
          DateTime.now().difference(_lastFailureTime!) > _timeout) {
        _state = CircuitState.halfOpen;
        _logger.info('Circuit breaker: OPEN → HALF-OPEN');
      } else {
        _logger.warning('Circuit breaker: request rejected (OPEN)');
        throw const CircuitBreakerOpenException(
          'Circuit breaker is OPEN — requests are being rejected.',
        );
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    if (_state == CircuitState.halfOpen) {
      _logger.info('Circuit breaker: HALF-OPEN → CLOSED (test succeeded)');
    }
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= _failureThreshold) {
      _lastFailureTime = DateTime.now();
      if (_state != CircuitState.open) {
        _state = CircuitState.open;
        _logger.warning(
          'Circuit breaker: → OPEN ($_failureCount consecutive failures)',
        );
      }
    }
  }
}
