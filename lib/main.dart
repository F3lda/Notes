import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/change_notifiers/notes_change_notifier.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/notes_page.dart';
import 'package:notes/services/note_service.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the User adapter
  Hive.registerAdapter(NoteAdapter());

  //await Hive.deleteBoxFromDisk('notes');
  const notesHiveBox = 'notes';
  await Hive.openBox<Note>(notesHiveBox);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<NoteChangeNotifier>(create: (context) => NoteChangeNotifier(NoteService(Hive.box<Note>(notesHiveBox)))),
    ],
    child: const NotesApp(),
  ));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}
