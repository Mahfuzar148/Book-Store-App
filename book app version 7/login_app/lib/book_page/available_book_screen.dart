import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableBooksScreen extends StatefulWidget {
  const AvailableBooksScreen({super.key});

  @override
  _AvailableBooksScreenState createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  // ---- Functionality for contacting to buy a book ----
  void _contactToBuy(BuildContext context, String phoneNumber, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact to Buy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: email,
                  query:
                      'subject=Book Inquiry&body=Hello, I am interested in your book.',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  _showError(context, 'Could not launch Email app');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call'),
              onTap: () async {
                final Uri callUri = Uri(
                  scheme: 'tel',
                  path: phoneNumber,
                );
                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                } else {
                  _showError(context, 'Could not initiate a phone call');
                }
              },
            ),
            //-----whatsapp and telegram----------
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.whatsapp, color: Colors.blue),
              title: const Text('WhatsApp'),
              onTap: () async {
                final Uri whatsappUri = Uri(
                  scheme: 'https',
                  path: 'api.whatsapp.com/send?phone=$phoneNumber',
                );
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri);
                } else {
                  _showError(context, 'Could not launch WhatsApp');
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () async {
                final Uri telegramUri = Uri(
                  scheme: 'https',
                  path: 't.me/$phoneNumber',
                );
                if (await canLaunchUrl(telegramUri)) {
                  await launchUrl(telegramUri);
                } else {
                  _showError(context, 'Could not launch Telegram');
                }
              },
            ),
            //-----whatsapp and telegram----------
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ---- Functionality to view a PDF file ----
  void _viewPdf(BuildContext context, String pdfUrl) async {
    final Uri pdfUri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(pdfUri)) {
      await launchUrl(pdfUri);
    } else {
      _showError(context, 'Could not open PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Books'),
      ),
      drawer: _buildDrawer(context, user),
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

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75, // Adjusting aspect ratio for image & text
            ),
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              return _buildBookCard(context, bookData);
            },
          );
        },
      ),
    );
  }

  // ---- Drawer implementation ----
  Drawer _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(FontAwesomeIcons.book,
                    size: 64, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Home'),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
    );
  }

  // ---- Build individual book card ----
  Widget _buildBookCard(BuildContext context, Map<String, dynamic> bookData) {
    return GestureDetector(
      onTap: () => _showBookDetails(context, bookData),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          children: [
            bookData['image'] != null
                ? Image.network(
                    bookData['image'],
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 50, color: Colors.grey),
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    bookData['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Author: ${bookData['author'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '৳${bookData['price'] ?? 'N/A'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ---- Book details popup when clicking the book card ----
  void _showBookDetails(BuildContext context, Map<String, dynamic> bookData) {
    final User? user =
        FirebaseAuth.instance.currentUser; // Get the current user

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookData['title'] ?? 'No Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Author: ${bookData['author'] ?? 'Unknown'}'),
            const SizedBox(height: 10),
            Text('Price: ৳${bookData['price'] ?? 'N/A'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (bookData['pdfUrl'] != null) {
                  _viewPdf(context, bookData['pdfUrl']);
                } else {
                  _showError(context, 'PDF not available');
                }
              },
              child: const Text('View PDF'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Fetch user's phone number and email from Firebase Auth
                // Use default values if user is not authenticated or values are null
                final String phoneNumber =
                    user?.phoneNumber ?? '01571319833'; // Default phone number
                final String email =
                    user?.email ?? 'mahfuzar148@gmail.com'; // Default email

                _contactToBuy(context, phoneNumber, email);
              },
              child: const Text('Contact to Buy'),
            ),
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
