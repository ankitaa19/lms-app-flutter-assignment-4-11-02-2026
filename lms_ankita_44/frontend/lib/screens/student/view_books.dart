import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../services/issue_book_service.dart';
import '../../utils/get_user_data_from_token.dart';
import '../../utils/custom_Alert_box.dart';

class ViewBooksScreen extends StatefulWidget {
  const ViewBooksScreen({super.key});

  @override
  State<ViewBooksScreen> createState() => _ViewBooksScreenState();
}

class _ViewBooksScreenState extends State<ViewBooksScreen> {
  List<Book> books = [];
  List<String> issuedBookIds = []; // Track books student has issued
  bool loading = true;
  String? studentId;

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final userData = getUserDataFromToken(token);
        setState(() {
          studentId = userData.id;
        });
        // Load books after getting student ID
        await loadBooks();
      }
    } catch (e) {
      print('Error loading student data: $e');
      setState(() => loading = false);
    }
  }

  Future<void> loadBooks() async {
    try {
      if (studentId == null) {
        if (mounted) {
          setState(() => loading = false);
        }
        return;
      }

      // Load both all books and student's issued books
      final allBooks = await BookService.getAllBooks();
      final issuedBooks = await IssueBookService.getMyIssuedBooks(studentId!);

      // Get IDs of books that are currently issued (not returned)
      final currentlyIssuedIds = issuedBooks
          .where((issue) => issue['returned'] == false)
          .map((issue) => (issue['book']?['_id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();

      // Filter out books that the student has currently issued
      final availableBooks = allBooks
          .where((book) => !currentlyIssuedIds.contains(book.id))
          .toList();

      if (mounted) {
        setState(() {
          books = availableBooks;
          issuedBookIds = currentlyIssuedIds;
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> handleIssueBook(Book book) async {
    if (studentId == null) {
      CustomAlertBox.showError(
        context,
        'Error',
        'Unable to identify student. Please login again.',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Book'),
        content: Text('Do you want to issue "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Issue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Issuing book...')));
      }

      await IssueBookService.issueBook(book.id, studentId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book issued successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the book list to show updated quantity
        loadBooks();
      }
    } catch (e) {
      if (mounted) {
        CustomAlertBox.showError(
          context,
          'Error',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void showBookDetailsModal(Book book) {
    final isAvailable = book.quantity > 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isAvailable ? Colors.blue : Colors.grey,
                      isAvailable ? Colors.blue.shade700 : Colors.grey.shade700,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.menu_book, size: 56, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Book Details Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Availability Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.cancel,
                              color: isAvailable ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAvailable
                                  ? 'Available - ${book.quantity} ${book.quantity == 1 ? "copy" : "copies"}'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Book Information Section
                      const Text(
                        'Book Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard([
                        if (book.isbn.isNotEmpty)
                          _buildDetailRow(Icons.qr_code_2, 'ISBN', book.isbn),
                        if (book.publisher.isNotEmpty)
                          _buildDetailRow(
                            Icons.business,
                            'Publisher',
                            book.publisher,
                          ),
                        if (book.publishedYear != null)
                          _buildDetailRow(
                            Icons.calendar_today,
                            'Year',
                            book.publishedYear.toString(),
                          ),
                        if (book.genre.isNotEmpty)
                          _buildDetailRow(Icons.category, 'Genre', book.genre),
                      ]),

                      if (book.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            book.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (isAvailable) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            handleIssueBook(book);
                          },
                          icon: const Icon(Icons.library_add),
                          label: const Text('Issue This Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          'No additional information available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Books')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (books.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Books')),
        body: const Center(child: Text('No books available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Books')),
      body: RefreshIndicator(
        onRefresh: loadBooks,
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final isAvailable = book.quantity > 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                onTap: () => showBookDetailsModal(book),
                leading: Icon(
                  Icons.book,
                  size: 40,
                  color: isAvailable ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Author: ${book.author}'),
                    if (book.genre.isNotEmpty)
                      Text(
                        'Genre: ${book.genre}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    if (book.publisher.isNotEmpty)
                      Text(
                        'Publisher: ${book.publisher}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (book.publishedYear != null)
                      Text(
                        'Year: ${book.publishedYear}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAvailable
                              ? 'Available (${book.quantity} copies)'
                              : 'Out of Stock',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                trailing: isAvailable
                    ? ElevatedButton.icon(
                        onPressed: () => handleIssueBook(book),
                        icon: const Icon(Icons.library_add, size: 18),
                        label: const Text('Issue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      )
                    : Chip(
                        label: const Text('Unavailable'),
                        backgroundColor: Colors.grey.shade300,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
