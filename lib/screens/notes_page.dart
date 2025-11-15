import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';



class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> allNotes = [
    Note(title: 'Nákup', content: 'Koupit mléko, chleba, sýr'),
    Note(title: 'Workout', content: 'Trénink v 18:00'),
    Note(title: 'Flutter', content: 'Dodělat Hive databázi'),
    Note(title: 'Nákup', content: 'Koupit mléko, chleba, sýr'),
  ];

  List<Note> filteredNotes = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    filteredNotes = allNotes;
  }

  void search(String text) {
    setState(() {
      query = text.toLowerCase();
      filteredNotes = allNotes.where((note) {
        return note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Poznámky")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: search,
              decoration: const InputDecoration(
                hintText: "Hledat…",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (_, i) {
                final note = filteredNotes[i];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
