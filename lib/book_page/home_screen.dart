import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_app/admin_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently signed-in user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Management App'),
      ),
      //------ Start Drawer from here --------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            //------ Start Header from here --------
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(FontAwesomeIcons.book,
                      size: 64,
                      color: Colors.white), // Using Font Awesome book icon
                  const SizedBox(height: 8),
                  Text(
                    user?.displayName ??
                        'User', // Display user's name, fallback to 'User'
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            //------ End Header from here --------

            //----- Home Menu Start here ------
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            //----- Home Menu End here ------

            //----- Add Book Menu Start here ------
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Add Book'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/addBook');
              },
            ),
            //----- Add Book Menu End here ------

            //----- Available Books Menu Start here ------
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Available Books'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/availableBooks');
              },
            ),
            //----- Available Books Menu End here ------

            //----- Search Books Menu Start here ------
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Search Books'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/searchBooks');
              },
            ),
            //----- Search Books Menu End here ------

            // Admin Panel (only for 'mahfuzar148@gmail.com')
            if (user?.email == 'mahfuzar148@gmail.com')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminPanel(), // Navigate to AdminPanel
                    ),
                  );
                },
              ),
            //----- Admin Panel Menu End here ------

            // User Dashboard (for any other user)

            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('User Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/userdashboard');
              },
            ),
            //----- User Dashboard Menu End here ------
            //----- Log Out Button Start here ------
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                // Sign out from Firebase and Google Sign-In
                await FirebaseAuth.instance.signOut(); // Firebase sign out
                await GoogleSignIn()
                    .signOut(); // Google sign out (Reset Google sign-in)

                // Show a professional message after logout
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Thank You!'),
                      content: const Text(
                          'Thank you for using the app! We hope to see you again soon.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // Navigate to the sign-up page after showing the message
                            Navigator.of(context).pushReplacementNamed(
                                '/signup'); // Ensure user goes back to signup
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            //----- Log Out Button End here ------
          ],
        ),
      ),
      //------ End Drawer from here --------

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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4.0,
                        color: Colors.black45,
                      ),
                    ],
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
