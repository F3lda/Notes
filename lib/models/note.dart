import 'package:hive_flutter/hive_flutter.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String content;
  @HiveField(2)
  final DateTime createdAt;
  @HiveField(3)
  DateTime updatedAt;

  Note({
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Update helper
  Note copyWith({
    String? title,
    String? content,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
