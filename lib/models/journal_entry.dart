import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum JournalCategory {
  daily('Diario', Icons.edit),
  gratitude('Gratitud', Icons.celebration),
  reflection('Reflexión', Icons.psychology),
  goals('Metas', Icons.flag),
  dreams('Sueños', Icons.auto_awesome),
  challenges('Desafíos', Icons.trending_up),
  memories('Recuerdos', Icons.photo_camera),
  ideas('Ideas', Icons.lightbulb);

  const JournalCategory(this.name, this.icon);
  final String name;
  final IconData icon;
}

enum MoodTag {
  happy('Feliz', Icons.sentiment_very_satisfied),
  sad('Triste', Icons.sentiment_very_dissatisfied),
  excited('Emocionado', Icons.celebration),
  anxious('Ansioso', Icons.psychology),
  calm('Tranquilo', Icons.spa),
  angry('Enojado', Icons.mood_bad),
  grateful('Agradecido', Icons.favorite),
  confused('Confundido', Icons.help),
  hopeful('Esperanzado', Icons.auto_awesome),
  nostalgic('Nostálgico', Icons.history);

  const MoodTag(this.label, this.icon);
  final String label;
  final IconData icon;
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final JournalCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<MoodTag> moodTags;
  final List<String> customTags;
  final bool isPrivate;
  final String? imagePath;
  final String? audioPath;
  final int wordCount;

  JournalEntry({
    String? id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.moodTags = const [],
    this.customTags = const [],
    this.isPrivate = true,
    this.imagePath,
    this.audioPath,
  }) : id = id ?? const Uuid().v4(),
       wordCount = content.split(' ').length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'moodTags': moodTags.map((tag) => tag.name).toList(),
      'customTags': customTags,
      'isPrivate': isPrivate,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'wordCount': wordCount,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: JournalCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      moodTags:
          (json['moodTags'] as List<dynamic>?)
              ?.map(
                (tag) =>
                    MoodTag.values.firstWhere((moodTag) => moodTag.name == tag),
              )
              .toList() ??
          [],
      customTags: List<String>.from(json['customTags'] ?? []),
      isPrivate: json['isPrivate'] ?? true,
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
    );
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    JournalCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MoodTag>? moodTags,
    List<String>? customTags,
    bool? isPrivate,
    String? imagePath,
    String? audioPath,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodTags: moodTags ?? this.moodTags,
      customTags: customTags ?? this.customTags,
      isPrivate: isPrivate ?? this.isPrivate,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  String get preview {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }

  Duration get readingTime {
    // Average reading speed: 200 words per minute
    final minutes = (wordCount / 200).ceil();
    return Duration(minutes: minutes);
  }
}
