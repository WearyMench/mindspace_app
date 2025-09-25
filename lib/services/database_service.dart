import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'mindspace.db';
  static const int _databaseVersion = 1;

  // Tablas
  static const String moodTable = 'mood_entries';
  static const String meditationTable = 'meditation_sessions';
  static const String journalTable = 'journal_entries';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
      ;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        // Para web, usar una base de datos en memoria
        return await openDatabase(
          ':memory:',
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Para desktop, usar path_provider
        final directory = await getApplicationDocumentsDirectory();
        final path = join(directory.path, _databaseName);

        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      } else {
        // Para mobile, usar getDatabasesPath
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, _databaseName);

        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      }
    } catch (e) {
      // Si falla la inicialización, usar una base de datos en memoria como fallback
      // print('Error initializing database: $e');
      return await openDatabase(
        ':memory:',
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de mood entries
    await db.execute('''
      CREATE TABLE $moodTable (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        overallMood TEXT NOT NULL,
        notes TEXT,
        categoryRatings TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Crear tabla de meditation sessions
    await db.execute('''
      CREATE TABLE $meditationTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        rating INTEGER,
        notes TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        actualDuration INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Crear tabla de journal entries
    await db.execute('''
      CREATE TABLE $journalTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        moodTags TEXT,
        customTags TEXT,
        isPrivate INTEGER NOT NULL DEFAULT 1,
        imagePath TEXT,
        audioPath TEXT,
        wordCount INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Crear índices para mejorar el rendimiento
    await db.execute('''
      CREATE INDEX idx_mood_date ON $moodTable (date)
    ''');

    await db.execute('''
      CREATE INDEX idx_meditation_completedAt ON $meditationTable (completedAt)
    ''');

    await db.execute('''
      CREATE INDEX idx_journal_createdAt ON $journalTable (createdAt)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migraciones de base de datos aquí
    if (oldVersion < 2) {
      // Ejemplo de migración para futuras versiones
    }
  }

  // Métodos para Mood Entries
  Future<String> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(moodTable, {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'overallMood': entry.overallMood.name,
      'notes': entry.notes,
      'categoryRatings': _encodeCategoryRatings(entry.categoryRatings),
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return entry.id;
  }

  Future<List<MoodEntry>> getAllMoodEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      moodTable,
      orderBy: 'date DESC',
    );

    return maps.map((map) => _moodEntryFromMap(map)).toList();
  }

  Future<List<MoodEntry>> getMoodEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      moodTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return maps.map((map) => _moodEntryFromMap(map)).toList();
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      moodTable,
      {
        'date': entry.date.toIso8601String(),
        'overallMood': entry.overallMood.name,
        'notes': entry.notes,
        'categoryRatings': _encodeCategoryRatings(entry.categoryRatings),
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteMoodEntry(String id) async {
    final db = await database;
    await db.delete(moodTable, where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para Meditation Sessions
  Future<String> insertMeditationSession(MeditationSession session) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(meditationTable, {
      'id': session.id,
      'type': session.type.name,
      'duration': session.duration.inMinutes,
      'difficulty': session.difficulty.name,
      'completedAt': session.completedAt.toIso8601String(),
      'rating': session.rating,
      'notes': session.notes,
      'completed': session.completed ? 1 : 0,
      'actualDuration': session.actualDuration?.inMinutes,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return session.id;
  }

  Future<List<MeditationSession>> getAllMeditationSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      meditationTable,
      orderBy: 'completedAt DESC',
    );

    return maps.map((map) => _meditationSessionFromMap(map)).toList();
  }

  Future<List<MeditationSession>> getMeditationSessionsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      meditationTable,
      where: 'completedAt BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'completedAt DESC',
    );

    return maps.map((map) => _meditationSessionFromMap(map)).toList();
  }

  Future<void> updateMeditationSession(MeditationSession session) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      meditationTable,
      {
        'type': session.type.name,
        'duration': session.duration.inMinutes,
        'difficulty': session.difficulty.name,
        'completedAt': session.completedAt.toIso8601String(),
        'rating': session.rating,
        'notes': session.notes,
        'completed': session.completed ? 1 : 0,
        'actualDuration': session.actualDuration?.inMinutes,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteMeditationSession(String id) async {
    final db = await database;
    await db.delete(meditationTable, where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para Journal Entries
  Future<String> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(journalTable, {
      'id': entry.id,
      'title': entry.title,
      'content': entry.content,
      'category': entry.category.name,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt?.toIso8601String(),
      'moodTags': _encodeMoodTags(entry.moodTags),
      'customTags': _encodeCustomTags(entry.customTags),
      'isPrivate': entry.isPrivate ? 1 : 0,
      'imagePath': entry.imagePath,
      'audioPath': entry.audioPath,
      'wordCount': entry.wordCount,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return entry.id;
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      journalTable,
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _journalEntryFromMap(map)).toList();
  }

  Future<List<JournalEntry>> getJournalEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      journalTable,
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _journalEntryFromMap(map)).toList();
  }

  Future<List<JournalEntry>> searchJournalEntries(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      journalTable,
      where: 'title LIKE ? OR content LIKE ? OR customTags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _journalEntryFromMap(map)).toList();
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      journalTable,
      {
        'title': entry.title,
        'content': entry.content,
        'category': entry.category.name,
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt?.toIso8601String(),
        'moodTags': _encodeMoodTags(entry.moodTags),
        'customTags': _encodeCustomTags(entry.customTags),
        'isPrivate': entry.isPrivate ? 1 : 0,
        'imagePath': entry.imagePath,
        'audioPath': entry.audioPath,
        'wordCount': entry.wordCount,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteJournalEntry(String id) async {
    final db = await database;
    await db.delete(journalTable, where: 'id = ?', whereArgs: [id]);
  }

  // Métodos de utilidad para codificar/decodificar datos complejos
  String _encodeCategoryRatings(Map<MoodCategory, int> ratings) {
    final Map<String, int> encoded = {};
    for (final entry in ratings.entries) {
      encoded[entry.key.name] = entry.value;
    }
    return encoded.toString();
  }

  Map<MoodCategory, int> _decodeCategoryRatings(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return {};
    }

    // Implementación simple - en producción usar JSON
    final Map<MoodCategory, int> decoded = {};
    // Por simplicidad, retornamos un mapa vacío
    // En una implementación real, se usaría JSON para codificar/decodificar
    return decoded;
  }

  String _encodeMoodTags(List<MoodTag> tags) {
    return tags.map((tag) => tag.name).join(',');
  }

  List<MoodTag> _decodeMoodTags(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return [];
    }
    return encoded.split(',').map((name) {
      try {
        return MoodTag.values.firstWhere((tag) => tag.name == name);
      } catch (e) {
        return MoodTag.happy; // Valor por defecto
      }
    }).toList();
  }

  String _encodeCustomTags(List<String> tags) {
    return tags.join(',');
  }

  List<String> _decodeCustomTags(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return [];
    }
    return encoded.split(',');
  }

  // Métodos de conversión de Map a Model
  MoodEntry _moodEntryFromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      overallMood: MoodLevel.values.firstWhere(
        (level) => level.name == map['overallMood'],
      ),
      notes: map['notes'],
      categoryRatings: _decodeCategoryRatings(map['categoryRatings']),
    );
  }

  MeditationSession _meditationSessionFromMap(Map<String, dynamic> map) {
    return MeditationSession(
      id: map['id'],
      type: MeditationType.values.firstWhere(
        (type) => type.name == map['type'],
      ),
      duration: Duration(minutes: map['duration']),
      difficulty: DifficultyLevel.values.firstWhere(
        (difficulty) => difficulty.name == map['difficulty'],
      ),
      completedAt: DateTime.parse(map['completedAt']),
      rating: map['rating'],
      notes: map['notes'],
      completed: map['completed'] == 1,
      actualDuration: map['actualDuration'] != null
          ? Duration(minutes: map['actualDuration'])
          : null,
    );
  }

  JournalEntry _journalEntryFromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: JournalCategory.values.firstWhere(
        (category) => category.name == map['category'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      moodTags: _decodeMoodTags(map['moodTags']),
      customTags: _decodeCustomTags(map['customTags']),
      isPrivate: map['isPrivate'] == 1,
      imagePath: map['imagePath'],
      audioPath: map['audioPath'],
    );
  }

  // Métodos de estadísticas
  Future<Map<String, dynamic>> getMoodStatistics() async {
    final db = await database;

    final totalEntries =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $moodTable'),
        ) ??
        0;

    final averageMoodResult = await db.rawQuery('''
      SELECT AVG(
        CASE overallMood
          WHEN 'terrible' THEN 1
          WHEN 'bad' THEN 2
          WHEN 'neutral' THEN 3
          WHEN 'good' THEN 4
          WHEN 'excellent' THEN 5
        END
      ) as avg FROM $moodTable
    ''');
    final averageMood =
        (averageMoodResult.first['avg'] as num?)?.toDouble() ?? 0.0;

    return {'totalEntries': totalEntries, 'averageMood': averageMood};
  }

  Future<Map<String, dynamic>> getMeditationStatistics() async {
    final db = await database;

    final totalSessions =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $meditationTable WHERE completed = 1',
          ),
        ) ??
        0;

    final totalMinutes =
        Sqflite.firstIntValue(
          await db.rawQuery('''
        SELECT COALESCE(SUM(actualDuration), SUM(duration)) 
        FROM $meditationTable 
        WHERE completed = 1
      '''),
        ) ??
        0;

    return {'totalSessions': totalSessions, 'totalMinutes': totalMinutes};
  }

  Future<Map<String, dynamic>> getJournalStatistics() async {
    final db = await database;

    final totalEntries =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $journalTable'),
        ) ??
        0;

    final totalWords =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT SUM(wordCount) FROM $journalTable'),
        ) ??
        0;

    return {'totalEntries': totalEntries, 'totalWords': totalWords};
  }

  // Método para limpiar la base de datos
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(moodTable);
    await db.delete(meditationTable);
    await db.delete(journalTable);
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
