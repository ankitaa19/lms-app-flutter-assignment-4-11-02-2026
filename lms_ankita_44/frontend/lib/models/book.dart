class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String publisher;
  final int? publishedYear;
  final String genre;
  final String description;
  final int quantity;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn = '',
    this.publisher = '',
    this.publishedYear,
    this.genre = '',
    this.description = '',
    required this.quantity,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'] ?? '',
      publisher: json['publisher'] ?? '',
      publishedYear: json['publishedYear'],
      genre: json['genre'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'publishedYear': publishedYear,
      'genre': genre,
      'description': description,
      'quantity': quantity,
    };
  }
}
