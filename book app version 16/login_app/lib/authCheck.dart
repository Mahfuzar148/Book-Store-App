import 'package:flutter/material.dart';
import 'package:login_app/book_page/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedIn');
    setState(() {
      isLoggedIn = loggedIn ?? false; // Default to false if null
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading indicator while checking login status
    }

    // Return HomeScreen if logged in, otherwise LoginPage
    return isLoggedIn! ? const HomeScreen() : const LoginPage();
  }
}
