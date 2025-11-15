import 'package:flutter/material.dart';
import 'package:notes/change_notifiers/notes_change_notifier.dart';
import 'package:notes/dialogs/note_dialog.dart';
import 'package:notes/models/note.dart';
import 'package:provider/provider.dart';



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
    final controller = context.watch<NoteChangeNotifier>();
    final notes = controller.notes;

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
                    onChanged: controller.search,
                    decoration: const InputDecoration(
                      hintText: "Hledat…",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Smazat poznámku'),
                        content: Text('Opravdu chcete smazat označené poznámky?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Zrušit'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);

                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Smazat'),
                          ),
                        ],
                      ),
                    );
                  },
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
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final note = notes[i];
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => NoteDialog(
                            initialTitle: note.title,
                            initialContent: note.content,
                            onSave: (title, content) async {
                              // Handle tile tap, e.g., navigate to note detail page
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Tapped on ${note.title}")),
                              );
                            },
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Smazat poznámku'),
                                  content: Text('Opravdu chcete smazat poznámku: ${note.title}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Zrušit'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);

                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Smazat'),
                                    ),
                                  ],
                                ),
                              );

                              /*setState(() {
                                allNotes.remove(note);
                                filteredNotes.remove(note);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Item deleted")),
                              );*/
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => NoteDialog(
              onSave: (title, content) async {
                controller.add(Note(title: "Ahoj", content: "Test"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added: $title")),
                );
              },
            ),
          );
        },
        tooltip: 'Přidat',
        child: const Icon(Icons.add),
      ),
    );
  }
}
