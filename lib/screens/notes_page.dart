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
  bool selectAll = false;

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
      appBar: AppBar(
        title: const Text("Poznámky"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          Center(child:
            Padding(padding:
              EdgeInsets.only(right: 12.0),
              child: Text("Celkem poznámek: 10", style: TextStyle(fontSize: 14),),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: search,
                    decoration: const InputDecoration(
                      hintText: "Hledat…",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Checkbox(
                  tristate: true,
                  value: selectAll,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAll = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (_, i) {
                final note = filteredNotes[i];
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      onTap: () {
                        // Handle tile tap, e.g., navigate to note detail page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Tapped on ${note.title}")),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                allNotes.remove(note);
                                filteredNotes.remove(note);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Item deleted")),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: false,
                            onChanged: (value) {
                              // Handle individual selection
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Přidat',
        child: const Icon(Icons.add),
      ),
    );
  }
}
