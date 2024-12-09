import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'available_books_screen.dart';
import 'firebase_options.dart'; // Import the generated file
import 'home_screen.dart';
import 'search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Firebase is initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/addBook': (context) => const AddBookScreen(),
        '/availableBooks': (context) => const AvailableBooksScreen(),
        '/searchBooks': (context) => const SearchScreen(),
      },
    );
  }
}
