import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'admin_panel.dart'; // Ensure you import the AdminPanel

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 64, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    user?.displayName ??
                        'User', // Display user's name, fallback to 'User'
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            // Home Button in Drawer
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),

            // Admin Panel only for mahfuzar148@gmail.com
            if (user?.email == 'mahfuzar148@gmail.com')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminPanel(),
                    ),
                  );
                },
              ),
            // Home Button in Drawer
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Upload Book Image'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/uploadImage');
              },
            ),
            // ===================== Start: Log Out Button Section =====================
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                // Sign out from Firebase and Google Sign-In
                await FirebaseAuth.instance.signOut(); // Firebase sign out
                await GoogleSignIn()
                    .signOut(); // Google sign out (Reset Google sign-in)

                // Navigate to the sign-up page
                Navigator.of(context).pushReplacementNamed(
                    '/signup'); // Ensure user goes back to signup
              },
            ),
// ===================== End: Log Out Button Section =====================
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? 'User'}!', // Show user's name, fallback to 'User'
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Removed Info button
          ],
        ),
      ),
    );
  }
}
