import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_app/book_page/add_book_screen.dart';
import 'package:login_app/book_page/available_book_screen.dart';
import 'package:login_app/book_page/home_screen.dart';
import 'package:login_app/book_page/reloadScreen.dart';
import 'package:login_app/book_page/search_screen.dart';
import 'package:login_app/book_page/user_uploaded_book.dart';
import 'package:login_app/image_upload/image_view.dart';
import 'package:login_app/image_upload/upload_book_image.dart';
import 'package:login_app/pdf_upload_and_view/pdf_viewer.dart';
import 'package:login_app/user_profile_page.dart';

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
      title: 'Book Store App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          // Check if the user is already logged in
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // If user is logged in, navigate to home screen
            return const HomeScreen();
          } else {
            // If user is not logged in, show sign up page
            return const SignUpPage();
          }
        },
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpPage(),
        '/addBook': (context) => const AddBookScreen(),
        '/availableBooks': (context) => const AvailableBooksScreen(),
        '/searchBooks': (context) => const SearchScreen(),
        '/uploadImage': (context) => const UploadImage(),
        '/uploadbookimage': (context) => const UploadBookImage(),
        '/userprofile': (context) => const UserProfilePage(),
        '/pdfview': (context) => const CustomPdfViewer(
              filePath: '',
            ),
        '/youruploadedbooks': (context) => const UserUploadedBooksPage(),
        '/reloadData': (context) => const ReloadScreen(),
      },
    );
  }
}
