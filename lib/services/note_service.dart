
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/models/note.dart';

class NoteService {
  final Box<Note> _box;

  NoteService(this._box);

  List<Note> getAll() => _box.values.toList();

  Future<void> add(Note note) async {
    await _box.add(note);
  }

  Future<void> update(int key, Note note) async {
    await _box.put(key, note);
  }

  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  List<Note> search(String query) {
    final queryLow = query.toLowerCase();
    return _box.values.where((note) {
      return note.title.toLowerCase().contains(queryLow) || note.content.toLowerCase().contains(queryLow);
    }).toList();
  }
}
