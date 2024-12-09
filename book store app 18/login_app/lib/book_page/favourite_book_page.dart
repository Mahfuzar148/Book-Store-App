import 'package:flutter/material.dart';
import 'package:login_app/custom_appbar.dart';

class FavoriteBooksPage extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final Function(String) onDelete;

  const FavoriteBooksPage({
    super.key,
    required this.favorites,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Favorite Books'),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      appBar: const CustomAppBarForAll(title: 'Favorite Books'),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite books added.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final book = favorites[index];
                return _buildFavoriteBookCard(context, book);
              },
            ),
    );
  }

  Widget _buildFavoriteBookCard(
      BuildContext context, Map<String, dynamic> bookData) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Left: Book image or default icon
            Expanded(
              flex: 1,
              child: bookData['bookImage'] != null &&
                      bookData['bookImage'].isNotEmpty
                  ? Container(
                      height: 150,
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
                      size: 50,
                    ),
            ),

            // Space between image and text
            const SizedBox(width: 10),

            // Right: Book details
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${bookData['bookPrice'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      onDelete(bookData['id']);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
