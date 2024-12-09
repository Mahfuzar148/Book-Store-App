import 'package:firebase_auth/firebase_auth.dart'; // Ensure you have the Firebase package added
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Ensure you have this package added
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_app/admin_panel.dart';

class CustomDrawer extends StatelessWidget {
  final User? user; // Pass the user object to display user information

  const CustomDrawer({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                const FaIcon(
                  FontAwesomeIcons.bookOpen, // You can choose a suitable icon
                  color: Colors.white,
                  size: 50.0,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.displayName ?? 'User', // Display user's name
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  user?.email ?? 'Email not available', // Display user's email
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Add the reload button
              ],
            ),
          ),
          //------ End Header from here --------

          //----- Home Menu Start here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.home,
            text: 'Home',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          //----- Home Menu End here ------

          //----- Add Book Menu Start here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.add,
            text: 'Add Book',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addBook');
            },
          ),
          //----- Add Book Menu End here ------

          //----- Available Books Menu Start here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.book,
            text: 'Available Books',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/availableBooks');
            },
          ),
          //----- Available Books Menu End here ------

          //----- Search Books Menu Start here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.search,
            text: 'Search Books',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/searchBooks');
            },
          ),
          //----- Search Books Menu End here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.refresh,
            text: 'Reload Data',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reloadData');
            },
          ),

          // Admin Panel (only for specific user)
          if (user?.email == 'mahfuzar148@gmail.com') // Dynamic admin check
            _createDrawerItem(
              context: context, // Pass context here
              icon: Icons.admin_panel_settings,
              text: 'Admin Panel',
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
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.library_books,
            text: 'Your Uploaded Books',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/youruploadedbooks');
            },
          ),
          // User Dashboard (for any other user)
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.person,
            text: 'User Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/userprofile');
            },
          ),
          //----- User Dashboard Menu End here ------

          //----- Log Out Button Start here ------
          _createDrawerItem(
            context: context, // Pass context here
            icon: Icons.logout,
            text: 'Log Out',
            onTap: () async {
              await _showLogoutDialog(context); // Show logout confirmation
            },
          ),
          //----- Log Out Button End here ------
        ],
      ),
    );
  }

  // Helper method to create a drawer item
  Widget _createDrawerItem({
    required BuildContext context, // Accept context as a parameter
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), // Change icon color to blue
      title: Text(text),
      onTap: onTap,
    );
  }

  // Logout confirmation dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    // Sign out from Firebase and Google Sign-In
    await FirebaseAuth.instance.signOut(); // Firebase sign out
    await GoogleSignIn().signOut(); // Google sign out

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
                // Ensure the user goes back to the login page
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // Go to the route associated with LoginPage
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
