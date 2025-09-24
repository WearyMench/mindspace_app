import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  // Exportar todos los datos a JSON
  Future<Map<String, dynamic>> exportAllData() async {
    final moodEntries = await _databaseService.getAllMoodEntries();
    final meditationSessions = await _databaseService
        .getAllMeditationSessions();
    final journalEntries = await _databaseService.getAllJournalEntries();

    return {
      'exportInfo': {
        'appName': 'MindSpace',
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalRecords': {
          'moodEntries': moodEntries.length,
          'meditationSessions': meditationSessions.length,
          'journalEntries': journalEntries.length,
        },
      },
      'moodEntries': moodEntries
          .map((entry) => _moodEntryToJson(entry))
          .toList(),
      'meditationSessions': meditationSessions
          .map((session) => _meditationSessionToJson(session))
          .toList(),
      'journalEntries': journalEntries
          .map((entry) => _journalEntryToJson(entry))
          .toList(),
    };
  }

  // Exportar datos de estado de ánimo
  Future<Map<String, dynamic>> exportMoodData() async {
    final moodEntries = await _databaseService.getAllMoodEntries();

    return {
      'exportInfo': {
        'type': 'mood_data',
        'appName': 'MindSpace',
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalRecords': moodEntries.length,
      },
      'moodEntries': moodEntries
          .map((entry) => _moodEntryToJson(entry))
          .toList(),
    };
  }

  // Exportar datos de meditación
  Future<Map<String, dynamic>> exportMeditationData() async {
    final meditationSessions = await _databaseService
        .getAllMeditationSessions();

    return {
      'exportInfo': {
        'type': 'meditation_data',
        'appName': 'MindSpace',
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalRecords': meditationSessions.length,
      },
      'meditationSessions': meditationSessions
          .map((session) => _meditationSessionToJson(session))
          .toList(),
    };
  }

  // Exportar datos de diario
  Future<Map<String, dynamic>> exportJournalData() async {
    final journalEntries = await _databaseService.getAllJournalEntries();

    return {
      'exportInfo': {
        'type': 'journal_data',
        'appName': 'MindSpace',
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalRecords': journalEntries.length,
      },
      'journalEntries': journalEntries
          .map((entry) => _journalEntryToJson(entry))
          .toList(),
    };
  }

  // Exportar datos a archivo JSON
  Future<String> exportToJsonFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'mindspace_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);

    return file.path;
  }

  // Exportar datos a archivo CSV
  Future<String> exportToCsvFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'mindspace_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');

    final csvContent = _generateCsvContent(data);
    await file.writeAsString(csvContent);

    return file.path;
  }

  // Compartir archivo
  Future<void> shareFile(String filePath, String fileName) async {
    await Share.shareXFiles([
      XFile(filePath),
    ], text: 'Datos exportados de MindSpace - $fileName');
  }

  // Generar contenido CSV
  String _generateCsvContent(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Información de exportación
    buffer.writeln('MindSpace Data Export');
    buffer.writeln('Export Date: ${data['exportInfo']['exportDate']}');
    buffer.writeln('Total Records: ${data['exportInfo']['totalRecords']}');
    buffer.writeln();

    // Datos de estado de ánimo
    if (data['moodEntries'] != null) {
      buffer.writeln('MOOD ENTRIES');
      buffer.writeln('Date,Overall Mood,Notes,Category Ratings');

      for (final entry in data['moodEntries']) {
        buffer.writeln(
          '${entry['date']},${entry['overallMood']},"${entry['notes'] ?? ''}","${entry['categoryRatings'] ?? ''}"',
        );
      }
      buffer.writeln();
    }

    // Datos de meditación
    if (data['meditationSessions'] != null) {
      buffer.writeln('MEDITATION SESSIONS');
      buffer.writeln(
        'Date,Type,Duration (min),Difficulty,Completed,Rating,Notes',
      );

      for (final session in data['meditationSessions']) {
        buffer.writeln(
          '${session['completedAt']},${session['type']},${session['duration']},${session['difficulty']},${session['completed']},${session['rating'] ?? ''},"${session['notes'] ?? ''}"',
        );
      }
      buffer.writeln();
    }

    // Datos de diario
    if (data['journalEntries'] != null) {
      buffer.writeln('JOURNAL ENTRIES');
      buffer.writeln('Date,Title,Category,Word Count,Content Preview');

      for (final entry in data['journalEntries']) {
        final preview = entry['content'].length > 50
            ? '${entry['content'].substring(0, 50)}...'
            : entry['content'];
        buffer.writeln(
          '${entry['createdAt']},${entry['title']},${entry['category']},${entry['wordCount']},"$preview"',
        );
      }
    }

    return buffer.toString();
  }

  // Convertir MoodEntry a JSON
  Map<String, dynamic> _moodEntryToJson(MoodEntry entry) {
    return {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'overallMood': entry.overallMood.name,
      'notes': entry.notes,
      'categoryRatings': entry.categoryRatings.map(
        (key, value) => MapEntry(key.name, value),
      ),
    };
  }

  // Convertir MeditationSession a JSON
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

  // Convertir JournalEntry a JSON
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

  // Generar reporte de estadísticas
  Future<Map<String, dynamic>> generateStatisticsReport() async {
    final moodStats = await _databaseService.getMoodStatistics();
    final meditationStats = await _databaseService.getMeditationStatistics();
    final journalStats = await _databaseService.getJournalStatistics();

    return {
      'reportInfo': {
        'generatedAt': DateTime.now().toIso8601String(),
        'appName': 'MindSpace',
        'version': '1.0.0',
      },
      'moodStatistics': moodStats,
      'meditationStatistics': meditationStats,
      'journalStatistics': journalStats,
      'summary': {
        'totalMoodEntries': moodStats['totalEntries'],
        'averageMood': moodStats['averageMood'],
        'totalMeditationSessions': meditationStats['totalSessions'],
        'totalMeditationMinutes': meditationStats['totalMinutes'],
        'totalJournalEntries': journalStats['totalEntries'],
        'totalWordsWritten': journalStats['totalWords'],
      },
    };
  }

  // Exportar reporte de estadísticas
  Future<String> exportStatisticsReport() async {
    final report = await generateStatisticsReport();
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'mindspace_statistics_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final jsonString = const JsonEncoder.withIndent('  ').convert(report);
    await file.writeAsString(jsonString);

    return file.path;
  }

  // Limpiar archivos de exportación antiguos
  Future<void> cleanupOldExports() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final now = DateTime.now();

      for (final file in files) {
        if (file is File && file.path.contains('mindspace_export_')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          // Eliminar archivos más antiguos de 7 días
          if (age.inDays > 7) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignorar errores de limpieza
      // print('Error cleaning up old exports: $e');
    }
  }
}
