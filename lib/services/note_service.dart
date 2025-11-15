import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/models/note.dart';

class NoteService {
  final Box<Note> _box;

  NoteService(this._box);

  List<Note> getAll() => _box.values.toList();

  Future<void> add(Note note) async {
    await _box.add(note);
  }

  Future<void> update(dynamic key, Note note) async {
    await _box.put(key, note);
  }

  Future<void> delete(dynamic key) async {
    await _box.delete(key);
  }

  Note? getByKey(dynamic key) {
    return _box.get(key);
  }

  List<Note> search(String query) {
    if (query.isEmpty) {
      return getAll();
    }

    final queryLow = query.toLowerCase();
    return _box.values.where((note) {
      return note.title.toLowerCase().contains(queryLow) || note.content.toLowerCase().contains(queryLow);
    }).toList();
  }
}
