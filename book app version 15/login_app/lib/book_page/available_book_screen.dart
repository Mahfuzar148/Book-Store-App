// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/book_page/contact_page.dart';
import 'package:login_app/book_page/customer_order_page.dart';
import 'package:login_app/customDrawer.dart';
import 'package:login_app/custom_appbar.dart';

class AvailableBooksScreen extends StatefulWidget {
  final User? user;
  const AvailableBooksScreen({super.key, this.user});

  @override
  _AvailableBooksScreenState createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  void _contactToBuy(BuildContext context, String? phoneNumber, String? email) {
    final String contactPhone = phoneNumber ?? 'Not provided';
    final String contactEmail = email ?? 'Not provided';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          phoneNumber: contactPhone,
          email: contactEmail,
        ),
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

  void _viewPdf(BuildContext context, String? pdfUrl) {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      _showError(context, 'PDF not available for this book.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfUrl: pdfUrl),
      ),
    );
  }

  Future<void> _addToFavorites(Map<String, dynamic> bookData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // First, check if the email is available in the user object
        String userEmail = user.email ?? '';

        // If the email is still empty, check the provider data for Google email
        if (userEmail.isEmpty) {
          // Look through the providerData list to find the Google provider
          if (user.providerData.isNotEmpty) {
            for (var provider in user.providerData) {
              if (provider.providerId == 'google.com') {
                userEmail = provider.email ??
                    ''; // Fetch the email from the Google provider data
                break;
              }
            }
          }
        }

        // If email is still empty after checking, handle the error
        if (userEmail.isEmpty) {
          _showError(context, 'User not logged in or email not available.');
          return;
        }

        // Proceed with adding the book to the favorites
        final userFavorites =
            FirebaseFirestore.instance.collection('favorite_books');

        // Prepare data to store in the Firestore collection
        final favoriteBookData = {
          'userEmail': userEmail, // User's email
          'userName': user.displayName ?? 'Anonymous', // User's display name
          'bookTitle': bookData['title'] ?? 'No Title', // Book title
          'bookAuthor': bookData['author'] ?? 'Unknown', // Book author
          'bookImage': bookData['image'] ?? '', // Book image URL
          'bookPdf': bookData['pdf'] ?? '', // Book PDF URL
          'bookPrice': bookData['price'] ?? 'N/A', // Book price
          'bookDescription': bookData['description'] ?? '', // Book description
          'bookCategory': bookData['category'] ?? 'Unknown', // Book category
          'timestamp': FieldValue.serverTimestamp(), // Time of addition
          'userProfilePhoto': user.photoURL ?? '', // User profile photo
          'signInMethod': user.providerData[0].providerId == 'google.com'
              ? 'Google Sign-In'
              : 'Email/Password', // Track sign-in method
        };

        await userFavorites.add(favoriteBookData);

        // Notify user of success
        _showError(context, 'Book added to favorites successfully.');
      } else {
        // Notify user if not logged in
        _showError(context, 'User not logged in or email not available.');
      }
    } catch (e) {
      // Handle and display errors
      _showError(context, 'Failed to add to favorites: $e');
    }
  }

  String _getUserEmail(User user) {
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

  Future<bool> _checkIfFavorite(String userEmail, String bookTitle) async {
    try {
      final userFavorites =
          FirebaseFirestore.instance.collection('favorite_books');
      final favoriteSnapshot = await userFavorites
          .where('userEmail', isEqualTo: userEmail)
          .where('bookTitle', isEqualTo: bookTitle)
          .get();

      return favoriteSnapshot.docs.isNotEmpty;
    } catch (e) {
      _showError(context, 'Failed to check if book is favorite: $e');
      return false;
    }
  }

  bool _isFavorite = false; // State variable to track favorite status

  Future<void> _toggleFavorite(Map<String, dynamic> bookData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the user's email from Firebase Auth or Google provider data
      final userEmail = _getUserEmail(user);

      if (userEmail.isEmpty) {
        _showError(context, 'User not logged in or email not available.');
        return;
      }

      // Check if the book is currently in favorites
      final isCurrentlyFavorite =
          await _checkIfFavorite(userEmail, bookData['title'] ?? '');
      setState(() {
        _isFavorite = isCurrentlyFavorite; // Update the favorite status
      });

      if (_isFavorite) {
        // Remove from favorites
        final userFavorites =
            FirebaseFirestore.instance.collection('favorite_books');
        final favoriteSnapshot = await userFavorites
            .where('userEmail', isEqualTo: userEmail)
            .where('bookTitle', isEqualTo: bookData['title'] ?? '')
            .get();

        if (favoriteSnapshot.docs.isNotEmpty) {
          await favoriteSnapshot.docs[0].reference.delete();
          _showError(context, 'Book removed from favorites.');
        }
      } else {
        // Add to favorites
        await _addToFavorites(
            bookData); // Call the original method to add the book
        _showError(context, 'Book added to favorites.');
      }
    } else {
      _showError(context, 'User not logged in or email not available.');
    }
  }

  Future<void> _placeOrder(Map<String, dynamic> bookData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userOrders = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders');
        await userOrders.add(bookData);
        _showError(context, 'Book order placed.');
      } else {
        _showError(context, 'User not logged in.');
      }
    } catch (e) {
      _showError(context, 'Failed to place order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'Available Books'),
      drawer: CustomDrawer(user: user),
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

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              return _buildBookCard(context, bookData);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> bookData) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 15.0), // Padding on top and bottom
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0), // Orange padding on both sides
        // Set the background color to orange
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.15),
          color: Colors.white,
          child: Row(
            children: [
              // GestureDetector wrapping both the image and icon area (45% width)
              GestureDetector(
                onTap: () => _showBookActions(
                    context, bookData), // Trigger action on tap
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(20)),
                  child: bookData['image'] != null
                      ? Image.network(
                          bookData['image'],
                          height: 150,
                          width: MediaQuery.of(context).size.width *
                              0.45, // 45% of screen width
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width *
                              0.45, // 45% of screen width
                          color: Colors.grey[300],
                          child: const Icon(
                            FontAwesomeIcons
                                .bookOpen, // Font Awesome book icon for missing image
                            size: 60, // Icon size (adjust if needed)
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              // Book info on the right side (55% width)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                      15.0), // Padding for the book info side
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookData['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Author: ${bookData['author'] ?? 'Unknown'}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳${bookData['price'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookActions(BuildContext context, Map<String, dynamic> bookData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: _isFavorite
                    ? Colors.red
                    : Colors.grey, // Red if favorited, gray if not
              ),
              title: const Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(
                    bookData); // Toggle the favorite status when clicked
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Place Order'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerOrderPage(bookData: bookData),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Contact to Buy'),
              onTap: () {
                Navigator.pop(context);
                _contactToBuy(
                    context, bookData['ownersPhone'], bookData['ownersEmail']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Read Book'),
              onTap: () {
                Navigator.pop(context);
                _viewPdf(context, bookData['pdf']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Book Info'),
              onTap: () {
                Navigator.pop(context);
                _showBookDetails(context, bookData);
              },
            ),
          ],
        );
      },
    );
  }

  void _showBookDetails(BuildContext context, Map<String, dynamic> bookData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookData['title'] ?? 'No Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bookData['title'] ?? 'No Title'),
            Text('Author: ${bookData['author'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Category: ${bookData['category'] ?? 'N/A'}'),
            Text('Publication: ${bookData['publication'] ?? 'N/A'}'),
            Text('Pages: ${bookData['pages'] ?? 'N/A'}'),
            Text('Description: ${bookData['description'] ?? 'N/A'}'),
            Text('Price: ৳${bookData['price'] ?? 'N/A'}'),
            const SizedBox(height: 8),
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
}

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerPage({required this.pdfUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
