import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Management App'),
      ),
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
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Add Book'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/addBook');
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Available Books'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/availableBooks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Search Books'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/searchBooks');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img/home_page.png',
              fit: BoxFit.cover,
            ),
          ),
          // Encouraging Text aligned at the top
          const Positioned(
            top:
                30, // Adjust this value as needed to place the text higher or lower
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.0),
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
        ],
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
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/'); // Navigate to Home
              break;
            case 1:
              Navigator.pushNamed(context, '/addBook'); // Navigate to Add Book
              break;
            case 2:
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
