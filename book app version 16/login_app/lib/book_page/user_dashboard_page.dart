import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app/book_page/view_customer_order_page.dart';

class UserDashboardPage extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final List<Map<String, dynamic>> orders;

  const UserDashboardPage({
    super.key,
    required this.favorites,
    required this.orders,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool showFavorites =
      false; // Default state is false, so the favorites screen is not shown initially
  List<Map<String, dynamic>> fetchedFavorites = []; // Local state for favorites

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Row with buttons to toggle between favorites and orders
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showFavorites = true;
                    });
                    _fetchFavoriteBooks();
                  },
                  child: const Text('View Favorite Books'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the ViewCustomerOrderPage when this button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ViewCustomerOrderPage(), // Add your ViewCustomerOrderPage widget here
                      ),
                    );
                  },
                  child: const Text('View Ordered Books'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // The content displayed below depends on the selected button
            Expanded(
              child: showFavorites
                  ? _buildBookGrid(context, fetchedFavorites)
                  : _buildBookList(
                      context, widget.orders, 'No orders placed yet.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookGrid(
      BuildContext context, List<Map<String, dynamic>> books) {
    return Column(
      children: [
        // Back button that appears only when viewing favorite books
        if (showFavorites)
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showFavorites = false;
                  });
                },
              ),
            ),
          ),

        // The grid itself
        Expanded(
          child: books.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite books added.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildBookCard(context, book);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookList(
    BuildContext context,
    List<Map<String, dynamic>> books,
    String emptyMessage,
  ) {
    if (books.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(context, book);
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> bookData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        children: [
          // Book image
          bookData['bookImage'] != null && bookData['bookImage'].isNotEmpty
              ? Container(
                  width: double.infinity,
                  height: 150, // Set a fixed height for image
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    image: DecorationImage(
                      image: NetworkImage(bookData['bookImage']),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const Icon(Icons.book,
                  size: 50), // Default icon if image is missing

          // Book title and author
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookData['bookTitle'] ??
                      'No Title', // Default message if title is missing
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow
                      .ellipsis, // Ensure long titles don't overflow
                  maxLines: 1, // Limit to one line for title
                ),
                const SizedBox(height: 4),
                Text(
                    'Author: ${bookData['bookAuthor'] ?? 'Unknown'}'), // Default message for missing author
                const SizedBox(height: 4),
                Text(
                  'Category: ${bookData['bookCategory'] ?? 'N/A'}', // Display book category, or default if missing
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${bookData['bookPrice'] ?? 'N/A'}', // Display price, or default if missing
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _deleteFavoriteBook(bookData['id']);
            },
          ),
        ],
      ),
    );
  }

  // Function to fetch favorite books from Firestore
  Future<void> _fetchFavoriteBooks() async {
    String userEmail = await _getUserEmail();

    if (userEmail.isNotEmpty) {
      final userFavorites =
          FirebaseFirestore.instance.collection('favorite_books');

      final favoriteSnapshot =
          await userFavorites.where('userEmail', isEqualTo: userEmail).get();

      if (favoriteSnapshot.docs.isNotEmpty) {
        setState(() {
          fetchedFavorites = favoriteSnapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
      } else {
        setState(() {
          fetchedFavorites = [];
        });
      }
    }
  }

  // Function to delete a favorite book from Firestore
  Future<void> _deleteFavoriteBook(String bookId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorite_books')
          .doc(bookId)
          .delete();

      // Remove the book from local state
      setState(() {
        fetchedFavorites.removeWhere((book) => book['id'] == bookId);
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book removed from favorites!')),
      );
    } catch (e) {
      // Handle error (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove book from favorites')),
      );
    }
  }

  // Function to get the user's email from Firebase
  Future<String> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email ?? '';

      // If email is empty, check the provider data for Google email
      if (userEmail.isEmpty) {
        for (var provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            userEmail = provider.email ?? '';
            break;
          }
        }
      }
      return userEmail;
    }
    return '';
  }
}
