import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/book_page/favourite_book_page.dart';
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
  List<Map<String, dynamic>> fetchedFavorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'User Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row (Two Cards in One Row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Card 1 (View Favorite Books)
                _buildButtonCard(
                  icon: const Icon(FontAwesomeIcons.heart, color: Colors.blue),
                  label: 'View Favorite Books',
                  onPressed: () async {
                    await _fetchFavoriteBooks(); // Fetch favorite books
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteBooksPage(
                          favorites: fetchedFavorites,
                          onDelete: (String bookId) {
                            _deleteFavoriteBook(bookId);
                          },
                        ),
                      ),
                    );
                  },
                ),
                // Card 2 (View Ordered Books)
                _buildButtonCard(
                  icon:
                      const Icon(FontAwesomeIcons.boxOpen, color: Colors.blue),
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
              ],
            ),
            const SizedBox(height: 15),

            // Second Row (Two Cards in One Row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Card 3 (View Uploaded Books)
                _buildButtonCard(
                  icon: const Icon(FontAwesomeIcons.upload, color: Colors.blue),
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
                // Card 4 (View Profile)
                _buildButtonCard(
                  icon: const Icon(FontAwesomeIcons.user, color: Colors.blue),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to create a card for the button
  // Widget to create a card for the button
  Widget _buildButtonCard({
    required Icon icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 35, horizontal: 20), // Increased height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Expanded(
                    child: Text(
                      label,
                      overflow:
                          TextOverflow.visible, // Ensures full text is visible
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
