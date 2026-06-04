import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../config/server_config.dart';
import '../security/sandbox.dart';
import '../security/secret_scanner.dart';

/// Result of a file operation.
class FileOperationResult {
  final bool success;
  final String? content;
  final String? error;
  final List<SecretFinding>? secretFindings;

  const FileOperationResult({
    required this.success,
    this.content,
    this.error,
    this.secretFindings,
  });
}

/// Handles all file I/O operations with security validation.
class FileTools {
  final ServerConfig _config;
  final SecurityManager _security;
  final SecretScanner _secretScanner;
  final Logger _logger;

  FileTools({
    required ServerConfig config,
    required SecurityManager security,
    required SecretScanner secretScanner,
  })  : _config = config,
        _security = security,
        _secretScanner = secretScanner,
        _logger = Logger('FileTools');

  /// Reads file contents with security and size validation.
  Future<FileOperationResult> readFile({
    required String path,
    int? maxSize,
    int? offset,
    int? limit,
  }) async {
    try {
      // Security check
      if (!await _security.validatePath(path)) {
        return const FileOperationResult(
          success: false,
          error: 'Access denied: path outside sandbox',
        );
      }

      final file = File(path);
      if (!await file.exists()) {
        return FileOperationResult(
          success: false,
          error: 'File not found: $path',
        );
      }

      final stat = await file.stat();
      final effectiveMaxSize = maxSize ?? _config.maxFileSize;
      if (stat.size > effectiveMaxSize) {
        return FileOperationResult(
          success: false,
          error: 'File too large: ${stat.size} bytes (max: $effectiveMaxSize)',
        );
      }

      var content = await file.readAsString(encoding: utf8);

      // Apply offset/limit if provided
      if (offset != null || limit != null) {
        final lines = const LineSplitter().convert(content);
        final start = offset ?? 0;
        final end = limit != null ? start + limit : lines.length;
        content = lines.sublist(start, end.clamp(0, lines.length)).join('\n');
      }

      // Scan for secrets (warn only, don't block reads)
      final secrets = _secretScanner.scan(content, path);

      return FileOperationResult(
        success: true,
        content: content,
        secretFindings: secrets.isNotEmpty ? secrets : null,
      );
    } catch (e) {
      _logger.severe('Error reading file $path: $e');
      return FileOperationResult(
        success: false,
        error: 'Error reading file: $e',
      );
    }
  }

  /// Writes file content atomically with security checks.
  Future<FileOperationResult> writeFile({
    required String path,
    required String content,
    required String checksum,
    bool backup = true,
  }) async {
    try {
      // Security check
      if (!await _security.validatePath(path)) {
        return const FileOperationResult(
          success: false,
          error: 'Access denied: path outside sandbox',
        );
      }

      // Size check
      if (content.length > _config.maxWriteSize) {
        return FileOperationResult(
          success: false,
          error:
              'Content too large: ${content.length} bytes (max: ${_config.maxWriteSize})',
        );
      }

      // Checksum verification (integrity)
      final actualChecksum =
          sha256.convert(utf8.encode(content)).toString();
      if (actualChecksum != checksum) {
        return FileOperationResult(
          success: false,
          error: 'Checksum mismatch — content may be corrupted',
        );
      }

      // Secret scanning
      final secrets = _secretScanner.scan(content, path);
      if (secrets.isNotEmpty) {
        return FileOperationResult(
          success: false,
          error:
              'Potential secrets detected:\n${secrets.map((s) => '  ${s.line}: ${s.type}').join('\n')}',
          secretFindings: secrets,
        );
      }

      // Backup existing file
      final file = File(path);
      if (backup && await file.exists()) {
        final backupPath = '$path.bak.${DateTime.now().millisecondsSinceEpoch}';
        await file.copy(backupPath);
        _logger.fine('Backed up $path → $backupPath');
      }

      // Atomic write (write to temp, then rename)
      final tempFile = File('$path.tmp.${DateTime.now().millisecondsSinceEpoch}');
      await tempFile.writeAsString(content, flush: true);
      await tempFile.rename(path);

      _logger.info('File written: $path (${content.length} bytes)');
      return const FileOperationResult(success: true);
    } catch (e) {
      _logger.severe('Error writing file $path: $e');
      return FileOperationResult(
        success: false,
        error: 'Error writing file: $e',
      );
    }
  }

  /// Performs multiple file operations atomically.
  ///
  /// All paths are validated first. On failure, changes are rolled back.
  Future<FileOperationResult> multiEdit({
    required List<Map<String, dynamic>> operations,
    bool atomic = true,
  }) async {
    final backups = <String, String>{};

    try {
      // Validate all paths first
      for (final op in operations) {
        final path = op['path'] as String;
        if (!await _security.validatePath(path)) {
          return FileOperationResult(
            success: false,
            error: 'Access denied: $path',
          );
        }
      }

      // Execute operations
      for (final op in operations) {
        final path = op['path'] as String;
        final operation = op['operation'] as String;
        final content = op['content'] as String?;

        final file = File(path);

        // Backup for rollback if atomic
        if (atomic && await file.exists()) {
          backups[path] = await file.readAsString();
        }

        switch (operation) {
          case 'write':
            await file.writeAsString(content!, flush: true);
          case 'append':
            await file.writeAsString(
              content!,
              mode: FileMode.append,
              flush: true,
            );
          case 'delete':
            await file.delete();
        }
      }

      return FileOperationResult(
        success: true,
        content: '${operations.length} operations completed',
      );
    } catch (e) {
      // Rollback on failure
      if (atomic) {
        for (final entry in backups.entries) {
          try {
            await File(entry.key).writeAsString(entry.value);
          } catch (_) {
            // Best-effort rollback
          }
        }
        return FileOperationResult(
          success: false,
          error: 'Multi-edit failed and was rolled back: $e',
        );
      }
      return FileOperationResult(
        success: false,
        error: 'Multi-edit failed: $e',
      );
    }
  }
}
