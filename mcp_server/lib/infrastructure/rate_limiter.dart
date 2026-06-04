import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:synchronized/synchronized.dart';

/// Token bucket rate limiter — enforces per-tool, per-user rate limits.
///
/// Tokens refill at a constant rate over [refillPeriod].
/// Burst capacity is the bucket size.
class TokenBucketRateLimiter {
  final int _capacity;
  final Duration _refillPeriod;
  final Map<String, _Bucket> _buckets = {};
  final Lock _lock = Lock();
  final Logger _logger = Logger('RateLimiter');

  TokenBucketRateLimiter({
    required int capacity,
    required Duration refillPeriod,
  })  : _capacity = capacity,
        _refillPeriod = refillPeriod;

  /// Attempts to acquire [tokens] for the given [key].
  /// Returns true if allowed, false if rate limited.
  Future<bool> acquire(String key, {int tokens = 1}) async {
    return _lock.synchronized(() {
      final now = DateTime.now();
      final bucket = _buckets.putIfAbsent(
        key,
        () => _Bucket(tokens: _capacity, lastRefill: now),
      );

      // Refill tokens based on elapsed time
      final elapsedMs = now.difference(bucket.lastRefill).inMilliseconds;
      final refillMs = _refillPeriod.inMilliseconds;

      if (refillMs > 0) {
        final tokensToAdd =
            (elapsedMs / refillMs * _capacity).floor();
        if (tokensToAdd > 0) {
          bucket.tokens = math.min(_capacity, bucket.tokens + tokensToAdd);
          bucket.lastRefill = now;
        }
      }

      if (bucket.tokens >= tokens) {
        bucket.tokens -= tokens;
        return true;
      }

      _logger.warning('Rate limit exceeded for $key');
      return false;
    });
  }

  /// Resets the bucket for the given key.
  Future<void> reset(String key) async {
    await _lock.synchronized(() {
      _buckets.remove(key);
    });
  }

  /// Returns the current token count for a key (for monitoring).
  Future<int> tokensAvailable(String key) async {
    return _lock.synchronized(() {
      return _buckets[key]?.tokens ?? _capacity;
    });
  }
}

class _Bucket {
  int tokens;
  DateTime lastRefill;

  _Bucket({required this.tokens, required this.lastRefill});
}
