// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/book_page/contact_page.dart';
import 'package:login_app/book_page/customer_order_page.dart';
import 'package:login_app/book_page/view_pdf_page.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.15),
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section (fixed width, full height)
              GestureDetector(
                onTap: () => _showBookActions(context, bookData),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(20)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 200,
                    color: Colors.grey[300],
                    child: bookData['image'] != null
                        ? Image.network(
                            bookData['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          (progress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  FontAwesomeIcons.bookOpen,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              FontAwesomeIcons.bookOpen,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),

              // Book info section (remaining space)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book title (allows line breaks dynamically)
                      Text(
                        bookData['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Author name (allows line breaks dynamically)
                      Text(
                        'Author: ${bookData['author'] ?? 'Unknown'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Book price
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
      backgroundColor:
          Colors.transparent, // Transparent background for the sheet
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Rounded top corners
            topRight: Radius.circular(20),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add a Close Button to dismiss the modal sheet
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.timesCircle,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),

                  // Add the list items with Font Awesome icons
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.heart,
                      color: _isFavorite
                          ? Colors.red
                          : Colors.grey, // Red if favorited, gray if not
                      size: 30,
                    ),
                    title: const Text(
                      'Add to Favorites',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _toggleFavorite(
                          bookData); // Toggle the favorite status when clicked
                    },
                  ),
                  _divider(),

                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.shoppingCart,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      'Place Order',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerOrderPage(bookData: bookData),
                        ),
                      );
                    },
                  ),
                  _divider(),

                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.phoneAlt,
                      size: 30,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'Contact to Buy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _contactToBuy(context, bookData['ownersPhone'],
                          bookData['ownersEmail']);
                    },
                  ),
                  _divider(),

                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.bookReader,
                      size: 30,
                      color: Colors.purpleAccent,
                    ),
                    title: const Text(
                      'Read Book',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _viewPdf(context, bookData['pdf']);
                    },
                  ),
                  _divider(),

                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.infoCircle,
                      size: 30,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      'Book Info',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showBookDetails(context, bookData);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Divider widget for a cleaner separation between options
  Widget _divider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      indent: 10,
      endIndent: 10,
    );
  }

  void _showBookDetails(BuildContext context, Map<String, dynamic> bookData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Transparent background
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Rounded corners for the dialog
        ),
        elevation: 15, // Increase shadow for 3D effect
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white
                .withOpacity(0.9), // Slight opacity for the dialog content
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.bookOpen,
                          color: Colors.greenAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            bookData['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Allows the title to wrap if too long
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Author with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.user,
                          color: Color.fromARGB(255, 16, 48, 205),
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Author: ${bookData['author'] ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Handles long author names
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.tag,
                          color: Colors.purpleAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Category: ${bookData['category'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Handles long category names
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Publication with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.calendarAlt,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Publication: ${bookData['publication'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Handles long publication names
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Pages with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.fileAlt,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pages: ${bookData['pages'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines:
                                2, // Handles long page numbers or descriptions
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Description with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.alignLeft,
                          color: Colors.greenAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Description: ${bookData['description'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3, // Handles long descriptions
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Price with FontAwesome icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.dollarSign,
                          color: Colors.amber,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Price: ৳${bookData['price'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1, // Price should usually fit in one line
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Close button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Rounded button corners
                          ),
                          backgroundColor: Colors.deepPurple, // Button color
                          elevation: 5, // Button shadow
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
