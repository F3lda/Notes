

import 'package:flutter/foundation.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';

class NoteChangeNotifier extends ChangeNotifier {
  final NoteService _service;

  List<Note> notes = [];
  String query = '';

  NoteChangeNotifier(this._service) {
    load();
  }

  void load() {
    notes = _service.getAll();
    notifyListeners();
  }

  void search(String query) {
    this.query = query;
    notes = _service.search(query);
    notifyListeners();
  }

  Future<void> add(Note note) async {
    await _service.add(note);
    load();
  }

  Future<void> delete(int key) async {
    await _service.delete(key);
    load();
  }
}
