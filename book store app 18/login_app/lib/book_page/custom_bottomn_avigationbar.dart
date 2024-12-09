import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  // Handle the tap event for navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Navigate to Home
        break;
      case 1:
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

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.teal, // Background color for BottomNavigationBar
      selectedItemColor:
          const Color.fromRGBO(20, 201, 71, 1), // Selected item color
      unselectedItemColor:
          const Color.fromARGB(255, 152, 9, 9), // Unselected item color
      selectedLabelStyle:
          const TextStyle(color: Colors.white), // Label style for selected item
      unselectedLabelStyle: const TextStyle(
          color: Colors.white), // Label style for unselected item
      currentIndex: _selectedIndex, // Current selected index
      onTap: _onItemTapped, // Handle taps on the items
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
    );
  }
}
