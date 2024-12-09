import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Firestore Book Info')),
        body: const BookInfoScreen(),
      ),
    );
  }
}

class BookInfoScreen extends StatefulWidget {
  const BookInfoScreen({super.key});

  @override
  _BookInfoScreenState createState() => _BookInfoScreenState();
}

class _BookInfoScreenState extends State<BookInfoScreen> {
  // Fetching all books from Firestore
  Future<List<Map<String, dynamic>>> _fetchBooks() async {
    List<Map<String, dynamic>> books = [];

    try {
      CollectionReference booksCollection =
          FirebaseFirestore.instance.collection('books');

      // Fetching the snapshot of the books collection
      QuerySnapshot querySnapshot = await booksCollection.get();
      for (var doc in querySnapshot.docs) {
        books.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching books: $e');
    }

    return books;
  }

  // Displaying the book info in a pop-up (AlertDialog)
  void _showBookInfo(BuildContext context, List<Map<String, dynamic>> books) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Books Info'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) {
                final book = books[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${book['title']}'),
                    Text('Author: ${book['author']}'),
                    Text('Category: ${book['category']}'),
                    Text('Availability: ${book['availability']}'),
                    Text('ISBN: ${book['isbn']}'),
                    Text('Pages: ${book['pages']}'),
                    Text('Price: \$${book['price']}'),
                    Text('Owner\'s Email: ${book['ownersEmail']}'),
                    Text('Owner\'s Phone: ${book['ownersPhone']}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to PDF viewer when the PDF button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerCachedFromURL(
                              pdfUrl: book['pdf'], // Pass the PDF URL
                            ),
                          ),
                        );
                      },
                      child: const Text('View PDF'),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Fetching books and displaying in pop-up
          List<Map<String, dynamic>> books = await _fetchBooks();
          _showBookInfo(context, books);
        },
        child: const Text('Show Book Info'),
      ),
    );
  }
}

// Class to view PDF from a URL
class PDFViewerCachedFromURL extends StatelessWidget {
  final String pdfUrl;
  const PDFViewerCachedFromURL({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View PDF'),
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
