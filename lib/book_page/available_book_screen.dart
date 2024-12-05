import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_app/admin_panel.dart';
import 'package:login_app/book_page/reloadScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableBooksScreen extends StatefulWidget {
  const AvailableBooksScreen({super.key});

  @override
  _AvailableBooksScreenState createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  static const int itemsPerPage = 1; // One book per page
  int currentPage = 0; // Current page index
  // ----- start functionality for contact to buy books
  void _contactToBuy(BuildContext context, String phoneNumber, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact to Buy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: email,
                  query:
                      'subject=Book Inquiry&body=Hello, I am interested in your book.',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  _showError(context, 'Could not launch Email app');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call'),
              onTap: () async {
                final Uri callUri = Uri(
                  scheme: 'tel',
                  path:
                      phoneNumber, // Ensure phoneNumber is properly initialized
                );

                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                } else {
                  // Show an error if the call cannot be initiated
                  _showError(context, 'Could not initiate a phone call');
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () async {
                final Uri whatsappUri = Uri(
                  scheme: 'https',
                  host: 'wa.me',
                  path: '/$phoneNumber',
                );
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri);
                } else {
                  _showError(context, 'Could not launch WhatsApp');
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () async {
                String urlScheme = kIsWeb
                    ? 'https://t.me/$phoneNumber'
                    : 'tg://resolve?domain=$phoneNumber'; // native telegram scheme for Android

                final Uri telegramUri = Uri.parse(urlScheme);
                if (await canLaunchUrl(telegramUri)) {
                  await launchUrl(telegramUri);
                } else {
                  _showError(context, 'Could not launch Telegram');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  //-----End function for contact to buy----

  void _nextPage() {
    setState(() {
      currentPage++;
    });
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Books'),
      ),
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
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Reload App Data'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReloadScreen()),
                );
              },
            ),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }
          final books = snapshot.data?.docs ?? [];
          final totalPages =
              (books.length / itemsPerPage).ceil(); // Calculate total pages

          if (currentPage >= totalPages) {
            return const Center(child: Text('No more books to display.'));
          }

          final startIndex = currentPage * itemsPerPage;
          final bookData = books[startIndex].data()
              as Map<String, dynamic>; // Get current book data

          return Center(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display book cover or default book icon if no image is available
                  bookData['image'] == null
                      ? Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.book,
                            size: 100,
                            color: Colors.grey,
                          ),
                        )
                      : Image.network(
                          bookData['image'],
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                  const SizedBox(height: 20),
                  Text(
                    bookData['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bookData['author'] ?? 'Unknown Author',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Price: ৳${bookData['price'] ?? 'N/A'}', // Displaying in BDT
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      const String phoneNumber =
                          '+8801751032769'; // Replace with bookData['phoneNumber'] if available
                      const String email =
                          'mahfuzar148@gmail.com'; // Replace with bookData['email'] if available
                      _contactToBuy(context, phoneNumber, email);
                    },
                    child: const Text('Contact to Buy',
                        style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _previousPage,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
        currentIndex: 2, // Set to the Available Books index
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
