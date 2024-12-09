// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For FontAwesome icons
import 'package:login_app/book_page/view_pdf_page.dart';
import 'package:login_app/customDrawer.dart';
import 'package:login_app/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs
// Make sure to import your PDF viewer page here

// Start of SearchScreen Widget
class SearchScreen extends StatefulWidget {
  final User? user;
  const SearchScreen({super.key, this.user});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// Start of _SearchScreenState class
class _SearchScreenState extends State<SearchScreen> {
  // Start of variables
  List<DocumentSnapshot> books = [];
  List<DocumentSnapshot> filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final int _selectedIndex =
      3; // To track the selected index for bottom navigation
  // End of variables

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('books')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        books = snapshot.docs;
        filteredBooks = [];
      });
    });
  }

  // Start of the search function
  void _searchBooks() {
    final query = _searchController.text.toLowerCase();
    final minPrice = _minPriceController.text.isNotEmpty
        ? double.tryParse(_minPriceController.text) ?? 0
        : 0;
    final maxPrice = _maxPriceController.text.isNotEmpty
        ? double.tryParse(_maxPriceController.text) ?? double.infinity
        : double.infinity;

    final filtered = books.where((book) {
      final bookData = book.data() as Map<String, dynamic>;
      final title = (bookData['title'] ?? '').toLowerCase();
      final author = (bookData['author'] ?? '').toLowerCase();
      final isbn = (bookData['isbn']?.toString() ?? '').toLowerCase();
      final category = (bookData['category'] ?? '').toLowerCase();
      final price = (bookData['price'] ?? 0).toDouble();

      return (title.contains(query) ||
              author.contains(query) ||
              isbn.contains(query) ||
              category.contains(query)) &&
          price >= minPrice &&
          price <= maxPrice;
    }).toList();

    setState(() {
      filteredBooks = filtered;
    });
  } // End of the search function

  // Start of button press function
  void _onSearchButtonPressed() {
    _searchBooks();
  } // End of button press function

  // Function to open URLs like PDF or contact
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Start of PDF viewing function
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
  } // End of PDF viewing function

  // Start of error handling function
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  } // End of error handling function

  // Start of build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'Search Books'),
      // appBar: AppBar(
      //   title: const Text('Search Books'),
      //   leading: Builder(
      //     builder: (context) => IconButton(
      //       icon: const Icon(Icons.menu),
      //       onPressed: () {
      //         Scaffold.of(context).openDrawer();
      //       },
      //     ),
      //   ),
      // ),
      drawer: CustomDrawer(user: widget.user),
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
                  'Search for books by title, author, ISBN, category, or price range.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Min Price',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Max Price',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                      final imageUrl = bookData['image'] ?? '';
                      final pdfUrl = bookData['pdf'] ?? '';
                      final contactEmail =
                          bookData['contact'] ?? 'mahfuzar148@gmail.com';
                      final phone = bookData['phone'] ?? '+8801571319833';
                      final whatsapp = bookData['whatsapp'] ?? '+8801571319833';
                      final telegram = bookData['telegram'] ?? '+8801571319833';

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    width: 80,
                                    height: 100,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookData['title'] ?? 'Unknown Title',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          'Author: ${bookData['author'] ?? 'Unknown Author'}',
                                        ),
                                        Text(
                                          'Pages: ${bookData['pages'] ?? 'N/A'}',
                                        ),
                                        Text(
                                          'Price: \$${bookData['price'] ?? 0}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _viewPdf(context, pdfUrl);
                                    },
                                    child: const Text('View PDF'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Show contact buttons
                                      _showContactOptions(context, contactEmail,
                                          phone, whatsapp, telegram);
                                    },
                                    child: const Text('Contact to Buy'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ) // listview builder endhere
                : const Center(
                    child: Text('No books found.'),
                  ),
          ),
        ],
      ),
    );
  } // End of build method

  // Start of contact options function
  void _showContactOptions(BuildContext context, String email, String phone,
      String whatsapp, String telegram) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to be larger than the viewport if needed
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          width: 300, // Set a fixed width for the modal (adjust as necessary)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact to Buy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center the title
              ),
              const SizedBox(height: 10),
              // Create a List of contact options
              Column(
                children: [
                  _contactButton(
                      'Email', FontAwesomeIcons.envelope, 'mailto:$email'),
                  const SizedBox(height: 10), // Space between buttons
                  _contactButton('Call', FontAwesomeIcons.phone, 'tel:$phone'),
                  const SizedBox(height: 10), // Space between buttons
                  _contactButton('WhatsApp', FontAwesomeIcons.whatsapp,
                      'https://wa.me/$whatsapp'),
                  const SizedBox(height: 10), // Space between buttons
                  _contactButton('Telegram', FontAwesomeIcons.telegram,
                      'https://t.me/$telegram'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// Helper method to create a contact button
  Widget _contactButton(String label, IconData icon, String url) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
            double.infinity, 50), // Ensures all buttons are the same size
        alignment: Alignment.center, // Center the content in the button
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        _launchUrl(url);
      },
    );
  }
} // End of _SearchScreenState class
// End of SearchScreen Widget