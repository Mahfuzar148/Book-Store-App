// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/customDrawer.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableBooksScreen extends StatefulWidget {
  final User? user;
  const AvailableBooksScreen({super.key, this.user});

  @override
  _AvailableBooksScreenState createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  // Functionality for contacting to buy a book
  void _contactToBuy(BuildContext context, String phoneNumber, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact to Buy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Contact
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
                if (await canLaunch(emailUri.toString())) {
                  await launch(emailUri.toString());
                } else {
                  _showError(context, 'Could not launch Email app');
                }
              },
            ),
            // Call Contact
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call'),
              onTap: () async {
                final Uri callUri = Uri(
                  scheme: 'tel',
                  path: phoneNumber,
                );
                if (await canLaunch(callUri.toString())) {
                  await launch(callUri.toString());
                } else {
                  _showError(context, 'Could not initiate a phone call');
                }
              },
            ),
            // WhatsApp Contact
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () async {
                final Uri whatsappUri = Uri.parse(
                    'https://wa.me/${phoneNumber.replaceFirst('+', '')}?text=Hello, I am interested in your book');
                if (await canLaunch(whatsappUri.toString())) {
                  await launch(whatsappUri.toString());
                } else {
                  _showError(context, 'Could not launch WhatsApp');
                }
              },
            ),
            // Telegram Contact
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () async {
                final Uri telegramUri = Uri.parse('https://t.me/$phoneNumber');
                if (await canLaunch(telegramUri.toString())) {
                  await launch(telegramUri.toString());
                } else {
                  _showError(context, 'Could not launch Telegram');
                }
              },
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // Functionality to view a PDF file using URL
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Books'),
      ),
      //drawer: _buildDrawer(context, user),
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

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
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

  void _showBookDetails(BuildContext context, Map<String, dynamic> bookData) {
    final ownerPhone = bookData['ownersPhone'] != null
        ? '+88${bookData['ownersPhone']}' // Append +88 to the owner's phone number
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookData['title'] ?? 'No Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${bookData['author'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Price: ৳${bookData['price'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _viewPdf(context, bookData['pdf']),
              child: const Text('View PDF'),
            ),
            const SizedBox(height: 8),
            const Text('Contact Owner:'),
            Text('Phone: $ownerPhone'),
            Text('Email: ${bookData['ownersEmail'] ?? 'Unknown'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                _contactToBuy(context, ownerPhone, bookData['ownersEmail']),
            child: const Text('Contact to Buy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// A new screen to view the PDF file using flutter_cached_pdfview
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
