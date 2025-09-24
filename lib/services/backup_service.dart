import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();

  /// Crear un backup completo de todos los datos
  Future<String> createFullBackup() async {
    try {
      final moodEntries = await _databaseService.getAllMoodEntries();
      final meditationSessions = await _databaseService
          .getAllMeditationSessions();
      final journalEntries = await _databaseService.getAllJournalEntries();

      final backupData = {
        'backupInfo': {
          'appName': 'MindSpace',
          'version': '1.0.0',
          'backupDate': DateTime.now().toIso8601String(),
          'platform': Platform.operatingSystem,
          'totalRecords': {
            'moodEntries': moodEntries.length,
            'meditationSessions': meditationSessions.length,
            'journalEntries': journalEntries.length,
          },
        },
        'data': {
          'moodEntries': moodEntries
              .map((entry) => _moodEntryToJson(entry))
              .toList(),
          'meditationSessions': meditationSessions
              .map((session) => _meditationSessionToJson(session))
              .toList(),
          'journalEntries': journalEntries
              .map((entry) => _journalEntryToJson(entry))
              .toList(),
        },
      };

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'mindspace_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw BackupException('Error al crear el backup: $e');
    }
  }

  /// Restaurar datos desde un archivo de backup
  Future<RestoreResult> restoreFromBackup(
    String filePath, {
    bool replaceExisting = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw BackupException('El archivo de backup no existe');
      }

      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      // Validar estructura del backup
      if (!_validateBackupStructure(backupData)) {
        throw BackupException(
          'El archivo de backup no tiene el formato correcto',
        );
      }

      final data = backupData['data'] as Map<String, dynamic>;
      int restoredCount = 0;
      int skippedCount = 0;
      List<String> errors = [];

      // Si se debe reemplazar los datos existentes, limpiar la base de datos
      if (replaceExisting) {
        await _databaseService.clearAllData();
      }

      // Restaurar mood entries
      if (data['moodEntries'] != null) {
        final result = await _restoreMoodEntries(
          data['moodEntries'] as List,
          replaceExisting,
        );
        restoredCount += result.restored;
        skippedCount += result.skipped;
        errors.addAll(result.errors);
      }

      // Restaurar meditation sessions
      if (data['meditationSessions'] != null) {
        final result = await _restoreMeditationSessions(
          data['meditationSessions'] as List,
          replaceExisting,
        );
        restoredCount += result.restored;
        skippedCount += result.skipped;
        errors.addAll(result.errors);
      }

      // Restaurar journal entries
      if (data['journalEntries'] != null) {
        final result = await _restoreJournalEntries(
          data['journalEntries'] as List,
          replaceExisting,
        );
        restoredCount += result.restored;
        skippedCount += result.skipped;
        errors.addAll(result.errors);
      }

      return RestoreResult(
        success: true,
        restoredCount: restoredCount,
        skippedCount: skippedCount,
        errors: errors,
        backupInfo: backupData['backupInfo'] as Map<String, dynamic>,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        restoredCount: 0,
        skippedCount: 0,
        errors: ['Error al restaurar el backup: $e'],
        backupInfo: {},
      );
    }
  }

  /// Compartir archivo de backup
  Future<void> shareBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final fileName = filePath.split('/').last;
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Backup de MindSpace - $fileName',
        subject: 'Backup de datos de MindSpace',
      );
    } else {
      throw BackupException('El archivo de backup no existe');
    }
  }

  /// Obtener información de un archivo de backup sin restaurarlo
  Future<BackupInfo> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw BackupException('El archivo de backup no existe');
      }

      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      if (!_validateBackupStructure(backupData)) {
        throw BackupException(
          'El archivo de backup no tiene el formato correcto',
        );
      }

      final backupInfo = backupData['backupInfo'] as Map<String, dynamic>;
      final data = backupData['data'] as Map<String, dynamic>;

      return BackupInfo(
        appName: backupInfo['appName'] as String,
        version: backupInfo['version'] as String,
        backupDate: DateTime.parse(backupInfo['backupDate'] as String),
        platform: backupInfo['platform'] as String,
        moodEntriesCount: (data['moodEntries'] as List?)?.length ?? 0,
        meditationSessionsCount:
            (data['meditationSessions'] as List?)?.length ?? 0,
        journalEntriesCount: (data['journalEntries'] as List?)?.length ?? 0,
      );
    } catch (e) {
      throw BackupException('Error al leer la información del backup: $e');
    }
  }

  /// Crear backup automático programado
  Future<String> createScheduledBackup() async {
    try {
      final backupPath = await createFullBackup();

      // Limpiar backups antiguos (mantener solo los últimos 5)
      await _cleanupOldBackups();

      return backupPath;
    } catch (e) {
      throw BackupException('Error al crear backup automático: $e');
    }
  }

  /// Limpiar backups antiguos
  Future<void> _cleanupOldBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final backupFiles = files
          .where(
            (file) =>
                file.path.contains('mindspace_backup_') &&
                file.path.endsWith('.json'),
          )
          .cast<File>()
          .toList();

      // Ordenar por fecha de modificación (más recientes primero)
      backupFiles.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      // Mantener solo los últimos 5 backups
      if (backupFiles.length > 5) {
        for (int i = 5; i < backupFiles.length; i++) {
          await backupFiles[i].delete();
        }
      }
    } catch (e) {
      // Ignorar errores de limpieza
      // print('Error al limpiar backups antiguos: $e');
    }
  }

  /// Validar estructura del backup
  bool _validateBackupStructure(Map<String, dynamic> backupData) {
    return backupData.containsKey('backupInfo') &&
        backupData.containsKey('data') &&
        backupData['backupInfo'] is Map<String, dynamic> &&
        backupData['data'] is Map<String, dynamic>;
  }

  /// Restaurar mood entries
  Future<_RestoreItemResult> _restoreMoodEntries(
    List data,
    bool replaceExisting,
  ) async {
    int restored = 0;
    int skipped = 0;
    List<String> errors = [];

    for (final item in data) {
      try {
        final entry = _moodEntryFromJson(item as Map<String, dynamic>);

        if (!replaceExisting) {
          // Verificar si ya existe
          final existing = await _databaseService.getAllMoodEntries();
          if (existing.any((e) => e.id == entry.id)) {
            continue;
          }
        }

        await _databaseService.insertMoodEntry(entry);
        restored++;
      } catch (e) {
        errors.add('Error al restaurar mood entry: $e');
      }
    }

    return _RestoreItemResult(
      restored: restored,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Restaurar meditation sessions
  Future<_RestoreItemResult> _restoreMeditationSessions(
    List data,
    bool replaceExisting,
  ) async {
    int restored = 0;
    int skipped = 0;
    List<String> errors = [];

    for (final item in data) {
      try {
        final session = _meditationSessionFromJson(
          item as Map<String, dynamic>,
        );

        if (!replaceExisting) {
          // Verificar si ya existe
          final existing = await _databaseService.getAllMeditationSessions();
          if (existing.any((s) => s.id == session.id)) {
            continue;
          }
        }

        await _databaseService.insertMeditationSession(session);
        restored++;
      } catch (e) {
        errors.add('Error al restaurar meditation session: $e');
      }
    }

    return _RestoreItemResult(
      restored: restored,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Restaurar journal entries
  Future<_RestoreItemResult> _restoreJournalEntries(
    List data,
    bool replaceExisting,
  ) async {
    int restored = 0;
    int skipped = 0;
    List<String> errors = [];

    for (final item in data) {
      try {
        final entry = _journalEntryFromJson(item as Map<String, dynamic>);

        if (!replaceExisting) {
          // Verificar si ya existe
          final existing = await _databaseService.getAllJournalEntries();
          if (existing.any((e) => e.id == entry.id)) {
            continue;
          }
        }

        await _databaseService.insertJournalEntry(entry);
        restored++;
      } catch (e) {
        errors.add('Error al restaurar journal entry: $e');
      }
    }

    return _RestoreItemResult(
      restored: restored,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Convertir MoodEntry a JSON
  Map<String, dynamic> _moodEntryToJson(MoodEntry entry) {
    return {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'overallMood': entry.overallMood.name,
      'notes': entry.notes,
      'categoryRatings': entry.categoryRatings.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'tags': entry.tags,
      'imagePath': entry.imagePath,
    };
  }

  /// Convertir JSON a MoodEntry
  MoodEntry _moodEntryFromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      overallMood: MoodLevel.values.firstWhere(
        (e) => e.name == json['overallMood'],
      ),
      notes: json['notes'],
      categoryRatings:
          (json['categoryRatings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              MoodCategory.values.firstWhere((e) => e.name == key),
              value as int,
            ),
          ) ??
          {},
      tags: List<String>.from(json['tags'] ?? []),
      imagePath: json['imagePath'],
    );
  }

  /// Convertir MeditationSession a JSON
  Map<String, dynamic> _meditationSessionToJson(MeditationSession session) {
    return {
      'id': session.id,
      'type': session.type.name,
      'duration': session.duration.inMinutes,
      'difficulty': session.difficulty.name,
      'completedAt': session.completedAt.toIso8601String(),
      'rating': session.rating,
      'notes': session.notes,
      'completed': session.completed,
      'actualDuration': session.actualDuration?.inMinutes,
    };
  }

  /// Convertir JSON a MeditationSession
  MeditationSession _meditationSessionFromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'],
      type: MeditationType.values.firstWhere((e) => e.name == json['type']),
      duration: Duration(minutes: json['duration']),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      completedAt: DateTime.parse(json['completedAt']),
      rating: json['rating'],
      notes: json['notes'],
      completed: json['completed'] ?? false,
      actualDuration: json['actualDuration'] != null
          ? Duration(minutes: json['actualDuration'])
          : null,
    );
  }

  /// Convertir JournalEntry a JSON
  Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'title': entry.title,
      'content': entry.content,
      'category': entry.category.name,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt?.toIso8601String(),
      'moodTags': entry.moodTags.map((tag) => tag.name).toList(),
      'customTags': entry.customTags,
      'isPrivate': entry.isPrivate,
      'imagePath': entry.imagePath,
      'audioPath': entry.audioPath,
      'wordCount': entry.wordCount,
    };
  }

  /// Convertir JSON a JournalEntry
  JournalEntry _journalEntryFromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: JournalCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      moodTags:
          (json['moodTags'] as List?)
              ?.map((tag) => MoodTag.values.firstWhere((e) => e.name == tag))
              .toList() ??
          [],
      customTags: List<String>.from(json['customTags'] ?? []),
      isPrivate: json['isPrivate'] ?? true,
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
    );
  }
}

/// Excepción para errores de backup
class BackupException implements Exception {
  final String message;
  BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}

/// Información de un backup
class BackupInfo {
  final String appName;
  final String version;
  final DateTime backupDate;
  final String platform;
  final int moodEntriesCount;
  final int meditationSessionsCount;
  final int journalEntriesCount;

  BackupInfo({
    required this.appName,
    required this.version,
    required this.backupDate,
    required this.platform,
    required this.moodEntriesCount,
    required this.meditationSessionsCount,
    required this.journalEntriesCount,
  });

  int get totalRecords =>
      moodEntriesCount + meditationSessionsCount + journalEntriesCount;
}

/// Resultado de una operación de restauración
class RestoreResult {
  final bool success;
  final int restoredCount;
  final int skippedCount;
  final List<String> errors;
  final Map<String, dynamic> backupInfo;

  RestoreResult({
    required this.success,
    required this.restoredCount,
    required this.skippedCount,
    required this.errors,
    required this.backupInfo,
  });
}

/// Resultado interno para restauración de elementos
class _RestoreItemResult {
  final int restored;
  final int skipped;
  final List<String> errors;

  _RestoreItemResult({
    required this.restored,
    required this.skipped,
    required this.errors,
  });
}
