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
  Set<dynamic> selectedNotes = {};
  bool selectAll = false;

  void toggleSelectAll(List<Note> notes) {
    setState(() {
      if (selectAll) {
        selectedNotes.clear();
        selectAll = false;
      } else {
        selectedNotes = notes.map((note) => note.key).toSet();
        selectAll = true;
      }
    });
  }

  void toggleNoteSelection(dynamic key, List<Note> notes) {
    setState(() {
      if (selectedNotes.contains(key)) {
        selectedNotes.remove(key);
      } else {
        selectedNotes.add(key);
      }
      selectAll = selectedNotes.length == notes.length && notes.isNotEmpty;
    });
  }

  bool? getSelectAllState(List<Note> notes) {
    if (selectedNotes.isEmpty) return false;
    if (selectedNotes.length == notes.length && notes.isNotEmpty) return true;
    return null; // indeterminate
  }

  void showEditDialog(BuildContext context, Note note, NoteChangeNotifier controller) {
    showDialog(
      context: context,
      builder: (context) => NoteDialog(
        initialTitle: note.title,
        initialContent: note.content,
        onSave: (title, content) async {
          final updatedNote = note.copyWith(
            title: title,
            content: content,
          );
          await controller.update(note.key, updatedNote);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text("Poznámka '$title' byla upravena"),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> showDeleteDialog(BuildContext context, Note note, NoteChangeNotifier controller) async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat poznámku'),
        content: Text('Opravdu chcete smazat poznámku: ${note.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Smazat'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.delete(note.key);
      setState(() {
        selectedNotes.remove(note.key);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text("Poznámka '${note.title}' byla smazána"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteChangeNotifier>(
      builder: (context, controller, child) {
        final notes = controller.notes;

        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus(); // disable focus when clicking outside of the search input
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Poznámky"),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text("Celkem poznámek: ${notes.length}", style: const TextStyle(fontSize: 14),),
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
                          autofocus: false,
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
                        onPressed: selectedNotes.isEmpty ? null : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Smazat poznámky'),
                              content: Text('Opravdu chcete smazat ${selectedNotes.length} označených poznámek?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Zrušit'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    for (var key in selectedNotes) {
                                      await controller.delete(key);
                                    }
                                    setState(() {
                                      selectedNotes.clear();
                                      selectAll = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text("Poznámky byly smazány")),);
                                    }
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
                        value: getSelectAllState(notes),
                        onChanged: notes.isEmpty ? null : (bool? value) {
                          toggleSelectAll(notes);
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: notes.isEmpty ? Center(
                    child: Text(
                      controller.query.isEmpty ? "Žádné poznámky" : "Žádné výsledky",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ) : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (_, i) {
                      final note = notes[i];
                      final isSelected = selectedNotes.contains(note.key);

                      return Column(
                        children: <Widget>[
                          Dismissible(
                            key: ValueKey(note.key),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Edit action (swipe from left)
                                showEditDialog(context, note, controller);
                                return false; // Don't dismiss the item
                              } else if (direction == DismissDirection.endToStart) {
                                // Delete action (swipe from right)
                                await showDeleteDialog(context, note, controller);
                                return false; // Don't dismiss the item, we handle deletion manually
                              }
                              return false;
                            },
                            onDismissed: (direction) {
                              // We handle everything in confirmDismiss, so this is empty
                            },
                            background: Container(
                              color: Colors.blue,
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 20),
                                  Icon(Icons.edit, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upravit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Smazat',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 20),
                                ],
                              ),
                            ),
                            child: ListTile(
                              title: Text(note.title),
                              subtitle: Text(note.content),
                              onTap: () {
                                showEditDialog(context, note, controller);
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDeleteDialog(context, note, controller);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      toggleNoteSelection(note.key, notes);
                                    },
                                  ),
                                ],
                              ),
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
                      await controller.add(Note(title: title, content: content));
                      if (context.mounted) {
                        //Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 2), content: Text("Poznámka '$title' přidána")),);
                      }
                    },
                  ),
                );
              },
              tooltip: 'Přidat',
              child: const Icon(Icons.add),
            ),
          )
        );
      },
    );
  }
}
