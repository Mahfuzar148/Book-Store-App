import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<DocumentSnapshot> books = [];
  List<DocumentSnapshot> filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // To track the selected index for bottom navigation

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('books')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        books = snapshot.docs;
        filteredBooks = []; // Initially show no results
      });
    });
  }

  void _searchBooks() {
    final query = _searchController.text.toLowerCase();
    final filtered = books.where((book) {
      final bookData = book.data() as Map<String, dynamic>;
      final title = (bookData['title'] ?? '').toLowerCase();
      final author = (bookData['author'] ?? '').toLowerCase();
      final isbn = (bookData['isbn']?.toString() ?? '').toLowerCase();
      final category = (bookData['category'] ?? '').toLowerCase();

      return title.contains(query) ||
          author.contains(query) ||
          isbn.contains(query) ||
          category.contains(query);
    }).toList();

    setState(() {
      filteredBooks = filtered; // Update the filtered list based on the search
    });
  }

  void _onSearchButtonPressed() {
    _searchBooks();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/'); // Home
        break;
      case 1:
        Navigator.pushNamed(context, '/searchBooks'); // Search Books
        break;
      case 2:
        Navigator.pushNamed(context, '/availableBooks'); // Available Books
        break;
      case 3:
        Navigator.pushNamed(context, '/addBook'); // Add Book
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Use Builder context to open the drawer
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
      ),
      drawer: SizedBox(
        width: 250, // Set a smaller width for the drawer
        child: Drawer(
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
                  Navigator.pushNamed(context, '/'); // Navigate to home
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.blue),
                title: const Text('Add Book'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/addBook'); // Navigate to add book
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: const Text('Available Books'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context,
                      '/availableBooks'); // Navigate to available books
                },
              ),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.blue),
                title: const Text('Search Books'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/searchBooks'); // Navigate to search books
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.lightBlueAccent,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.book,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Search for books by entering the title, author name, ISBN, or category. The search is case-insensitive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _onSearchButtonPressed,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredBooks.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      final bookData = book.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(bookData['title'] ?? ''),
                        subtitle: Text(bookData['author'] ?? ''),
                      );
                    },
                  )
                : const Center(child: Text('No results found')),
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
