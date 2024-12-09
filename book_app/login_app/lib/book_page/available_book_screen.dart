import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AvailableBooksScreen extends StatelessWidget {
  const AvailableBooksScreen({super.key});

  // Method to handle drawer item taps
/*************  ✨ Codeium Command ⭐  *************/
  /// Handles navigation from the drawer by closing the drawer first and then
  /// navigating to the specified route.
  ///
  /// Parameters:
  /// - `context`: The BuildContext of the current widget.
  /// - `routeName`: The name of the route to navigate to.
  /// ****  3a088f48-7658-4db4-9852-a6b21fa06c0c  ******
  void _onDrawerItemTapped(BuildContext context, String routeName) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, routeName); // Navigate to the selected route
  }

  // Main build method for the AvailableBooksScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and menu button
      appBar: AppBar(
        elevation: 0, // Remove shadow for a cleaner look
        backgroundColor:
            Colors.transparent, // Transparent background for custom shape
        flexibleSpace: ClipPath(
          clipper: AppBarShapeClipper(), // Custom shape for AppBar
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open drawer
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      // Drawer for navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header for the drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Book Management Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Navigation items in the drawer
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () =>
                  _onDrawerItemTapped(context, '/home'), // Navigate to Home
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Add Book'),
              onTap: () => _onDrawerItemTapped(
                  context, '/addBook'), // Navigate to Add Book
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Available Books'),
              onTap: () => _onDrawerItemTapped(
                  context, '/availableBooks'), // Navigate to Available Books
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Search Books'),
              onTap: () => _onDrawerItemTapped(
                  context, '/searchBooks'), // Navigate to Search Books
            ),
          ],
        ),
      ),
      // ---- drawer end from here ----

      // Body of the screen, fetching books from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }
          // Retrieve the book documents
          final books = snapshot.data?.docs ?? [];

          // Displaying the list of books
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(bookData['title']),
                subtitle: Text('Author: ${bookData['author']}'),
                trailing: Text('ISBN: ${bookData['isbn']}'),
              );
            },
          );
        },
      ),
      // BottomNavigationBar for navigation
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
        //---- bottomNavigationBar start here ----
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
        //---- bottomNavigationBar end here ----
        currentIndex: 2, // Set to the Available Books index
        onTap: (index) {
          // Handle bottom navigation bar item tap
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home'); // Navigate to Home
              break;
            case 1:
              Navigator.pushNamed(context, '/addBook'); // Navigate to Add Book
              break;
            case 2:
              Navigator.pushNamed(context, '/availableBooks');

              // Already on Available Books, do nothing
              break;
            case 3:
              Navigator.pushNamed(
                  context, '/searchBooks'); // Navigate to Search Books
              break;
          }
        },
      ),
    );
  }
}

// Custom shape clipper for AppBar
class AppBarShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 10);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
