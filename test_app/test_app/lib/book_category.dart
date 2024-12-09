// book_category.dart

class BookCategory {
  final String id;
  final String name;

  BookCategory({required this.id, required this.name});

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
