import 'dart:math' as math;

import 'package:logging/logging.dart';

/// Result of a secret detection scan.
class SecretFinding {
  final String type;
  final String preview;
  final int line;
  final String source;
  final double? entropy;

  const SecretFinding({
    required this.type,
    required this.preview,
    required this.line,
    required this.source,
    this.entropy,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'preview': preview,
        'line': line,
        'source': source,
        if (entropy != null) 'entropy': entropy,
      };

  @override
  String toString() => '$source:$line — $type: $preview';
}

/// Scans file contents for potential secrets using:
/// 1. Shannon entropy analysis (high-entropy strings → likely tokens/keys)
/// 2. Regex pattern matching (known secret formats)
class SecretScanner {
  final double _entropyThreshold;
  final bool _enabled;
  final Logger _logger;

  SecretScanner({
    double entropyThreshold = 4.5,
    bool enabled = true,
  })  : _entropyThreshold = entropyThreshold,
        _enabled = enabled,
        _logger = Logger('SecretScanner');

  /// Scans [content] for secrets, attributing findings to [source] file.
  List<SecretFinding> scan(String content, String source) {
    if (!_enabled || content.isEmpty) return [];

    final findings = <SecretFinding>[];

    // 1. Entropy-based scanning (catches unknown token formats)
    findings.addAll(_scanEntropy(content, source));

    // 2. Pattern-based scanning (catches known formats)
    findings.addAll(_scanPatterns(content, source));

    if (findings.isNotEmpty) {
      _logger.warning(
        '${findings.length} potential secret(s) found in $source',
      );
    }

    return findings;
  }

  List<SecretFinding> _scanEntropy(String content, String source) {
    final findings = <SecretFinding>[];

    final tokenPattern = RegExp(r'[A-Za-z0-9+/=_-]{20,}');
    for (final match in tokenPattern.allMatches(content)) {
      final candidate = match.group(0)!;
      final entropy = _calculateShannon(candidate);

      if (entropy > _entropyThreshold) {
        findings.add(SecretFinding(
          type: 'high_entropy_token',
          preview: '${candidate.substring(0, 8)}...',
          line: _lineNumber(content, match.start),
          source: source,
          entropy: entropy,
        ));
      }
    }

    return findings;
  }

  List<SecretFinding> _scanPatterns(String content, String source) {
    final findings = <SecretFinding>[];

    final patterns = <String, RegExp>{
      'api_key': RegExp(
        r"""(?:api[_-]?key|apikey|API_KEY)\s*[:=]\s*["'][A-Za-z0-9._-]{16,}["']""",
        caseSensitive: false,
      ),
      'password_hardcoded': RegExp(
        r"""(?:password|passwd|pwd)\s*[:=]\s*["'][^"']{4,}["']""",
        caseSensitive: false,
      ),
      'bearer_token': RegExp(
        r'bearer\s+[A-Za-z0-9_\-.]{20,}',
        caseSensitive: false,
      ),
      'private_key': RegExp(
        r'-----BEGIN\s+(RSA|EC|DSA|OPENSSH)\s+PRIVATE\s+KEY-----',
      ),
      'aws_access_key': RegExp(r'AKIA[0-9A-Z]{16}'),
      'google_api_key': RegExp(r'AIza[0-9A-Za-z\-_]{35}'),
      'github_token': RegExp(r'(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}'),
      'jwt_token': RegExp(
        r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}',
      ),
    };

    for (final entry in patterns.entries) {
      for (final match in entry.value.allMatches(content)) {
        final matched = match.group(0)!;
        findings.add(SecretFinding(
          type: entry.key,
          preview: matched.length > 30
              ? '${matched.substring(0, 30)}...'
              : matched,
          line: _lineNumber(content, match.start),
          source: source,
        ));
      }
    }

    return findings;
  }

  double _calculateShannon(String input) {
    if (input.isEmpty) return 0.0;

    final frequency = <String, int>{};
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      frequency[char] = (frequency[char] ?? 0) + 1;
    }

    var entropy = 0.0;
    for (final count in frequency.values) {
      final probability = count / input.length;
      entropy -= probability * (math.log(probability) / math.ln2);
    }

    return entropy;
  }

  int _lineNumber(String content, int offset) {
    return '\n'.allMatches(content.substring(0, offset)).length + 1;
  }
}
