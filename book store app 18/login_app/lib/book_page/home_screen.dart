import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app/book_page/custom_bottomn_avigationbar.dart';
import 'package:login_app/customDrawer.dart';
import 'package:login_app/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently signed-in user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'Book Store App'),
      //------ Start Drawer from here --------
      drawer: CustomDrawer(user: user),

      body: Column(
        children: [
          // Upper part: Text
          const Expanded(
            flex: 1, // Gives this part 1/3 of the available space
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Welcome to the Book Management App! Organize your library, explore new titles, and keep track of all your books easily. Happy reading!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Lower part: Background Image
          Expanded(
            flex: 2, // Gives this part 2/3 of the available space
            child: Image.asset(
              'assets/img/home_page.png',
              fit: BoxFit.cover,
              width: double.infinity, // Full width of the screen
            ),
          ),
        ],
      ),

      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
