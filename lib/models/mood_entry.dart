import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum MoodLevel {
  excellent(5, 'Excelente', Icons.sentiment_very_satisfied, '😄'),
  good(4, 'Bien', Icons.sentiment_satisfied, '😊'),
  neutral(3, 'Neutral', Icons.sentiment_neutral, '😐'),
  bad(2, 'Mal', Icons.sentiment_dissatisfied, '😔'),
  terrible(1, 'Terrible', Icons.sentiment_very_dissatisfied, '😢');

  const MoodLevel(this.value, this.label, this.icon, this.emoji);
  final int value;
  final String label;
  final IconData icon;
  final String emoji;
}

enum MoodCategory {
  energy('Energía', Icons.bolt),
  stress('Estrés', Icons.psychology),
  happiness('Felicidad', Icons.celebration),
  anxiety('Ansiedad', Icons.psychology),
  motivation('Motivación', Icons.trending_up),
  sleep('Sueño', Icons.bedtime),
  social('Social', Icons.people),
  work('Trabajo', Icons.work);

  const MoodCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class MoodEntry {
  final String id;
  final DateTime date;
  final MoodLevel overallMood;
  final Map<MoodCategory, int> categoryRatings;
  final String? notes;
  final List<String> tags;
  final String? imagePath;

  MoodEntry({
    String? id,
    required this.date,
    required this.overallMood,
    required this.categoryRatings,
    this.notes,
    this.tags = const [],
    this.imagePath,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'overallMood': overallMood.name,
      'categoryRatings': categoryRatings.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'notes': notes,
      'tags': tags,
      'imagePath': imagePath,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      overallMood: MoodLevel.values.firstWhere(
        (mood) => mood.name == json['overallMood'],
      ),
      categoryRatings: (json['categoryRatings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          MoodCategory.values.firstWhere((cat) => cat.name == key),
          value as int,
        ),
      ),
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      imagePath: json['imagePath'],
    );
  }

  MoodEntry copyWith({
    DateTime? date,
    MoodLevel? overallMood,
    Map<MoodCategory, int>? categoryRatings,
    String? notes,
    List<String>? tags,
    String? imagePath,
  }) {
    return MoodEntry(
      id: id,
      date: date ?? this.date,
      overallMood: overallMood ?? this.overallMood,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
