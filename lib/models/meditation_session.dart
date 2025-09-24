import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum MeditationType {
  breathing('Respiración', Icons.air, 'Técnicas de respiración consciente'),
  mindfulness(
    'Mindfulness',
    Icons.self_improvement,
    'Atención plena al momento presente',
  ),
  bodyScan(
    'Escaneo corporal',
    Icons.visibility,
    'Reconocimiento de sensaciones corporales',
  ),
  lovingKindness(
    'Bondad amorosa',
    Icons.favorite,
    'Cultivo de compasión y amor',
  ),
  walking(
    'Caminar consciente',
    Icons.directions_walk,
    'Meditación en movimiento',
  ),
  gratitude(
    'Gratitud',
    Icons.celebration,
    'Reflexión sobre lo que agradecemos',
  ),
  sleep('Para dormir', Icons.bedtime, 'Relajación profunda para el descanso'),
  anxiety(
    'Anti-ansiedad',
    Icons.water_drop,
    'Técnicas para calmar la ansiedad',
  );

  const MeditationType(this.name, this.icon, this.description);
  final String name;
  final IconData icon;
  final String description;
}

enum DifficultyLevel {
  beginner('Principiante', 1),
  intermediate('Intermedio', 2),
  advanced('Avanzado', 3);

  const DifficultyLevel(this.label, this.value);
  final String label;
  final int value;
}

class MeditationSession {
  final String id;
  final MeditationType type;
  final Duration duration;
  final DifficultyLevel difficulty;
  final DateTime completedAt;
  final int? rating; // 1-5 stars
  final String? notes;
  final bool completed;
  final Duration? actualDuration; // How long they actually meditated

  MeditationSession({
    String? id,
    required this.type,
    required this.duration,
    required this.difficulty,
    required this.completedAt,
    this.rating,
    this.notes,
    this.completed = false,
    this.actualDuration,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'duration': duration.inMinutes,
      'difficulty': difficulty.name,
      'completedAt': completedAt.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'completed': completed,
      'actualDuration': actualDuration?.inMinutes,
    };
  }

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'],
      type: MeditationType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      duration: Duration(minutes: json['duration']),
      difficulty: DifficultyLevel.values.firstWhere(
        (difficulty) => difficulty.name == json['difficulty'],
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

  MeditationSession copyWith({
    MeditationType? type,
    Duration? duration,
    DifficultyLevel? difficulty,
    DateTime? completedAt,
    int? rating,
    String? notes,
    bool? completed,
    Duration? actualDuration,
  }) {
    return MeditationSession(
      id: id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      actualDuration: actualDuration ?? this.actualDuration,
    );
  }

  double get completionRate {
    if (actualDuration == null) return 0.0;
    return (actualDuration!.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
  }

  // Getter for compatibility with statistics chart
  DateTime get date => completedAt;
}
