import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Unit tests for Note model and database operations

// Mock Note model
class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
    id: map['id'],
    title: map['title'],
    content: map['content'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  Note copyWith({String? title, String? content, DateTime? updatedAt}) => Note(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

void main() {
  group('Note Model', () {
    test('creates note and converts to/from map', () {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, equals('Test'));

      final map = note.toMap();
      final restored = Note.fromMap(map);
      expect(restored.title, equals('Test'));
    });

    test('copyWith updates fields', () {
      final now = DateTime.now();
      final note = Note(id: '1', title: 'A', content: 'B', createdAt: now, updatedAt: now);
      final updated = note.copyWith(title: 'C');

      expect(updated.title, equals('C'));
      expect(updated.content, equals('B'));
    });
  });

  group('Database Operations', () {
    late Box<Map> box;

    setUp(() async {
      Hive.init('./test_hive');
      box = await Hive.openBox<Map>('test');
    });

    tearDown(() async {
      await box.clear();
      await box.close();
      await Hive.deleteBoxFromDisk('test');
    });

    test('CRUD operations', () async {
      final now = DateTime.now();
      final note = Note(id: '1', title: 'Test', content: 'Content', createdAt: now, updatedAt: now);

      // Create
      await box.put(note.id, note.toMap());
      expect(box.length, equals(1));

      // Read
      final retrieved = Note.fromMap(Map<String, dynamic>.from(box.get('1') as Map));
      expect(retrieved.title, equals('Test'));

      // Update
      final updated = note.copyWith(title: 'Updated');
      await box.put(updated.id, updated.toMap());
      expect(box.length, equals(1));

      // Delete
      await box.delete('1');
      expect(box.length, equals(0));
    });

    test('handles multiple notes', () async {
      final now = DateTime.now();
      final notes = List.generate(3, (i) => Note(id: '$i', title: 'Note $i', content: 'C', createdAt: now, updatedAt: now),
      );

      for (var n in notes) {
        await box.put(n.id, n.toMap());
      }
      expect(box.length, equals(3));

      await box.deleteAll(['0', '1']);
      expect(box.length, equals(1));
    });
  });

  group('Search and Filter', () {
    late List<Note> notes;

    setUp(() async {
      final now = DateTime.now();
      notes = [
        Note(id: '1', title: 'Nákup', content: 'Mléko', createdAt: now, updatedAt: now),
        Note(id: '2', title: 'Úkoly', content: 'Projekt', createdAt: now, updatedAt: now),
        Note(id: '3', title: 'Recept', content: 'Mléko, mouka', createdAt: now, updatedAt: now),
      ];
    });


    test('filters by title or content', () {
      final filtered = notes.where((n) => n.title.toLowerCase().contains('mléko') || n.content.toLowerCase().contains('mléko')).toList();

      expect(filtered.length, equals(2));
    });

    test('case insensitive search', () {
      final queries = ['NÁKUP', 'nákup'];
      for (var q in queries) {
        final filtered = notes.where((n) => n.title.toLowerCase().contains(q.toLowerCase())).toList();
        expect(filtered.isNotEmpty, isTrue);
      }
    });
  });
}
