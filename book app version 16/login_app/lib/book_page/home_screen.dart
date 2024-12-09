import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

      //----start BottomNavigationBar for navigation------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal, // Change background color
        selectedItemColor:
            const Color.fromRGBO(20, 201, 71, 1), // Color for selected item
        unselectedItemColor:
            const Color.fromARGB(255, 152, 9, 9), // Color for unselected items
        selectedLabelStyle:
            const TextStyle(color: Colors.white), // Style for selected label
        unselectedLabelStyle:
            const TextStyle(color: Colors.white), // Style for unselected label
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Available Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Books',
          ),
        ],
        currentIndex: 0, // Set to the Available Books index
        onTap: (index) {
          // Handle bottom navigation bar item tap
          // Navigate to the selected screen based on the index
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home'); // Navigate to Home
              break;
            case 1:
              Navigator.pushNamed(context, '/addBook'); // Navigate to Add Book
              break;
            case 2:
              Navigator.pushNamed(context, '/availableBooks');
              break;
            case 3:
              Navigator.pushNamed(
                  context, '/searchBooks'); // Navigate to Search Books
              break;
          }
        },
        // end of switch case
      ),
      //-----End bottom navigation bar from here-----
    );
  }
}
