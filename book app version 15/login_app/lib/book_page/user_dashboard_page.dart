import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/book_page/user_uploaded_book.dart';
import 'package:login_app/book_page/view_customer_order_page.dart';
import 'package:login_app/custom_appbar.dart';
import 'package:login_app/user_profile_page.dart';

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
      appBar: const CustomAppBarForAll(title: 'User Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First Row (Card for "View Favorite Books")
            _buildButtonCard(
              icon: const Icon(FontAwesomeIcons.heart),
              label: 'View Favorite Books',
              onPressed: () {
                setState(() {
                  showFavorites = true;
                });
                _fetchFavoriteBooks();
              },
            ),
            const SizedBox(height: 15),

            // Second Row (Card for "View Ordered Books")
            _buildButtonCard(
              icon: const Icon(FontAwesomeIcons.boxOpen),
              label: 'View Ordered Books',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewCustomerOrderPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // Third Row (Card for "View Your Uploaded Books")
            _buildButtonCard(
              icon: const Icon(FontAwesomeIcons.upload),
              label: 'View Your Uploaded Books',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserUploadedBooksPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // Fourth Row (Card for "View Your Profile")
            _buildButtonCard(
              icon: const Icon(FontAwesomeIcons.user),
              label: 'View Your Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // The content displayed below depends on the selected button
            Expanded(
              child: showFavorites
                  ? _buildBookGrid(context, fetchedFavorites)
                  : _buildBookList(context, widget.orders, ''),
            ),
          ],
        ),
      ),
    );
  }

// Widget to create a card for the button
  Widget _buildButtonCard({
    required Icon icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 12, // Enhanced 3D effect with shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.blue], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(15), // Rounded corners for the button
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white, // White text for contrast
                ),
              ),
            ],
          ),
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
                    crossAxisCount: 1, // One item per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        1.5, // Adjust the aspect ratio for your card
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
      margin: const EdgeInsets.all(10.0), // Padding for the entire card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Padding inside the card
        child: Row(
          children: [
            // Left side: Book image
            Expanded(
              flex: 1, // Book image takes 50% width
              child: bookData['bookImage'] != null &&
                      bookData['bookImage'].isNotEmpty
                  ? Container(
                      height: 150, // Fixed height for image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(bookData['bookImage']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.book,
                      size: 50, // Default icon if image is missing
                    ),
            ),

            // Space between image and text
            const SizedBox(width: 10),

            // Right side: Book details
            Expanded(
              flex: 2, // Book details take the remaining 50% width
              child: SingleChildScrollView(
                // Enable scrolling for the right section
                child: Padding(
                  padding: const EdgeInsets.all(
                      10.0), // Same padding for both sections
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Left align book info
                    children: [
                      Text(
                        bookData['bookTitle'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Author: ${bookData['bookAuthor'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${bookData['bookCategory'] ?? 'N/A'}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${bookData['bookPrice'] ?? 'N/A'}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                      // Delete button at the bottom of the right section
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteFavoriteBook(bookData['id']);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
