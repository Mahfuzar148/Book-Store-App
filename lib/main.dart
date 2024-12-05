import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_app/book_page/add_book_screen.dart';
import 'package:login_app/book_page/available_book_screen.dart';
import 'package:login_app/book_page/home_screen.dart';
import 'package:login_app/book_page/search_screen.dart';
import 'package:login_app/image_upload/image_view.dart';
import 'package:login_app/image_upload/upload_book_image.dart';
import 'package:login_app/user_dashboard_page.dart';

import 'login_page.dart';
import 'signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC_-V4WCfSvK54lHbw8CoJ2nbXLLCYiZNM",
      appId: "1:758942709283:android:2d12f129ec18a3ac516396",
      messagingSenderId: "758942709283",
      projectId: "fir-series-cb7fd",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpPage(),
        '/addBook': (context) => const AddBookScreen(),
        '/availableBooks': (context) => const AvailableBooksScreen(),
        '/searchBooks': (context) => const SearchScreen(),
        '/uploadImage': (context) => const UploadImage(),
        '/uploadbookimage': (context) => const UploadBookImage(),
        '/userdashboard': (context) => const UserDashboardPage(),
      },
    );
  }
}
