import 'dart:io';

import 'package:logging/logging.dart';

import '../config/server_config.dart';
import '../security/sandbox.dart';
import '../security/secret_scanner.dart';
import 'command_tools.dart';
import 'file_tools.dart';

/// Result of a UI layer validation check.
class ValidationResult {
  final bool passed;
  final List<String> violations;

  const ValidationResult({
    required this.passed,
    this.violations = const [],
  });

  String get summary => passed
      ? 'Validation passed'
      : 'Validation failed:\n${violations.map((v) => '  ❌ $v').join('\n')}';
}

/// Handles UI layer validation, secret scanning, and project analysis.
class ValidationTools {
  final ServerConfig _config;
  final SecurityManager _security;
  final SecretScanner _secretScanner;
  final CommandTools _commandTools;
  final Logger _logger;

  ValidationTools({
    required ServerConfig config,
    required SecurityManager security,
    required SecretScanner secretScanner,
    required CommandTools commandTools,
  })  : _config = config,
        _security = security,
        _secretScanner = secretScanner,
        _commandTools = commandTools,
        _logger = Logger('ValidationTools');

  /// Validates a file against the 4-layer UI architecture rules.
  ///
  /// [layer] must be one of: page, business, base, official.
  Future<ValidationResult> validateUiLayer({
    required String filePath,
    required String layer,
  }) async {
    if (!await _security.validatePath(filePath)) {
      return ValidationResult(
        passed: false,
        violations: ['Access denied: $filePath'],
      );
    }

    final file = File(filePath);
    if (!await file.exists()) {
      return ValidationResult(
        passed: false,
        violations: ['File not found: $filePath'],
      );
    }

    final content = await file.readAsString();
    final violations = <String>[];

    // Layer-specific rule checks
    switch (layer) {
      case 'page':
        if (content.contains("import 'package:flutter/material.dart'")) {
          violations.add(
            'Page layer must NOT import material.dart directly. '
            'Use Base layer widgets.',
          );
        }
        if (RegExp(r'Color\(|TextStyle\(|EdgeInsets\.only\(')
            .hasMatch(content)) {
          violations.add(
            'Page layer must NOT contain style logic (Color, TextStyle, '
            'EdgeInsets). Use design tokens.',
          );
        }
        if (content.contains('http.') || content.contains('dio.')) {
          violations.add(
            'Page layer must NOT make API calls. Delegate to providers.',
          );
        }
        break;

      case 'business':
        if (content.contains("import 'package:flutter/material.dart'")) {
          violations.add(
            'Business layer must NOT import material.dart directly. '
            'Use Base layer widgets.',
          );
        }
        if (content.contains('http.') || content.contains('dio.')) {
          violations.add(
            'Business layer must NOT make API calls directly. '
            'Receive data via constructor parameters.',
          );
        }
        // Check that widgets receive data via constructors
        final widgetDecls = RegExp(r'class\s+\w+\s+extends\s+\w*Widget');
        if (widgetDecls.hasMatch(content) &&
            !content.contains('required this.')) {
          violations.add(
            'Business layer widgets should receive data via '
            'constructor parameters.',
          );
        }
        break;

      case 'base':
        if (!content.contains("import 'package:flutter/material.dart'") &&
            !content.contains("import 'package:flutter/cupertino.dart'")) {
          violations.add(
            'Base layer MUST import material.dart or cupertino.dart — '
            'it is the ONLY layer allowed to do so.',
          );
        }
        break;

      case 'official':
        violations.add(
          'Official Material widgets must NEVER appear outside the '
          'Base layer. Always wrap in a Base layer abstraction.',
        );
        break;

      default:
        violations.add('Unknown layer: $layer');
    }

    return ValidationResult(
      passed: violations.isEmpty,
      violations: violations,
    );
  }

  /// Scans specified files for hardcoded secrets.
  Future<Map<String, List<SecretFinding>>> scanSecrets({
    required List<String> paths,
  }) async {
    final results = <String, List<SecretFinding>>{};

    for (final path in paths) {
      if (!await _security.validatePath(path)) continue;

      final file = File(path);
      if (!await file.exists()) continue;

      final content = await file.readAsString();
      final findings = _secretScanner.scan(content, path);

      if (findings.isNotEmpty) {
        results[path] = findings;
      }
    }

    return results;
  }

  /// Runs Dart/Flutter static analysis on specified paths.
  Future<CommandResult> analyzeProject({
    required List<String> paths,
    bool fatalWarnings = true,
  }) async {
    final args = <String>[
      'analyze',
      if (fatalWarnings) '--fatal-warnings',
      ...paths,
    ];

    return _commandTools.runCommand(
      command: 'flutter',
      args: args,
      timeout: 120, // 2 minutes for analysis
    );
  }
}
