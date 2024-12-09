import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  int _selectedIndex = 1; // Default to Add Book screen

  Future<void> _addBook() async {
    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'author': _authorController.text,
      'availability': _availabilityController.text,
      'pages': int.tryParse(_pagesController.text) ?? 0,
      'isbn': _isbnController.text,
    });

    // Clear the text fields after adding
    _titleController.clear();
    _authorController.clear();
    _availabilityController.clear();
    _pagesController.clear();
    _isbnController.clear();

    // Optionally, navigate back or show a success message
    Navigator.pop(context);
  }

  void _onDrawerItemTapped(BuildContext context, String routeName) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, routeName); // Navigate to the selected route
  }

  //-----bottomNavigation handler function start fore here-----
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Navigate to Home
        break;
      case 1:
        // Stay on Add Book
        Navigator.pushNamed(context, '/addBook'); // Navigate to Add Book
        break;
      case 2:
        Navigator.pushNamed(
            context, '/availableBooks'); // Navigate to Available Books
        break;
      case 3:
        Navigator.pushNamed(
            context, '/searchBooks'); // Navigate to Search Books
        break;
    }
  }
  //-----bottomNavigation handler function end here-----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 160, 59),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
      ),
      //-------start drawer from here-------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
            // Home Button in Drawer
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () =>
                  _onDrawerItemTapped(context, '/home'), // Navigate to Home
            ),
            // Add Book Button in Drawer
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Add Book'),
              onTap: () => _onDrawerItemTapped(
                  context, '/addBook'), // Navigate to Add Book
            ),
            // Available Books Button in Drawer
            ListTile(
              leading: const Icon(Icons.library_books, color: Colors.blue),
              title: const Text('Available Books'),
              onTap: () => _onDrawerItemTapped(
                  context, '/availableBooks'), // Navigate to Available Books
            ),
            // Search Books Button in Drawer
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Search Books'),
              onTap: () => _onDrawerItemTapped(
                  context, '/searchBooks'), // Navigate to Search Books
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _availabilityController,
              decoration: const InputDecoration(labelText: 'Availability'),
            ),
            TextField(
              controller: _pagesController,
              decoration: const InputDecoration(labelText: 'Number of Pages'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _isbnController,
              decoration: const InputDecoration(labelText: 'ISBN'),
            ),
            const SizedBox(height: 20),
            // add book button here
            ElevatedButton(
              onPressed: _addBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
              child:
                  const Text('Add Book', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      //-------end drawer from here-------

      // ----- Bottom Navigation Bar start here ------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Change background color
        selectedItemColor:
            const Color.fromRGBO(20, 201, 71, 1), // Color for selected item
        unselectedItemColor:
            const Color.fromARGB(255, 152, 9, 9), // Color for unselected items
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
