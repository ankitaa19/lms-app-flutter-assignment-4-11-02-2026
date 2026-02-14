import 'package:flutter/material.dart';
import '../../services/issue_book_service.dart';
import '../../utils/custom_Alert_box.dart';

class MyIssuedBooksScreen extends StatefulWidget {
  final String studentId;
  const MyIssuedBooksScreen({super.key, required this.studentId});

  @override
  State<MyIssuedBooksScreen> createState() => _MyIssuedBooksScreenState();
}

class _MyIssuedBooksScreenState extends State<MyIssuedBooksScreen> {
  List<dynamic> issuedBooks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final books = await IssueBookService.getMyIssuedBooks(widget.studentId);

      // Filter out issues where the book has been deleted (book is null)
      final validBooks = books.where((issue) => issue['book'] != null).toList();

      if (mounted) {
        setState(() {
          issuedBooks = validBooks;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> handleReturn(String issueId, String bookTitle) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Book'),
        content: Text('Are you sure you want to return "$bookTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await IssueBookService.returnBook(issueId);
      if (mounted) {
        CustomAlertBox.showSuccess(
          context,
          'Success',
          'Book returned successfully!',
        );
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

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Color getStatusColor(bool returned, DateTime? returnDate) {
    if (returned) return Colors.green;
    if (returnDate != null && DateTime.now().isAfter(returnDate)) {
      return Colors.red;
    }
    return Colors.blue;
  }

  void showIssuedBookDetailsModal(dynamic issue) {
    final book = issue['book'];
    
    // Safety check - this shouldn't happen but prevents crashes
    if (book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book information is not available')),
      );
      return;
    }
    
    final isReturned = issue['returned'] ?? false;
    final issueDate = issue['issueDate'] != null
        ? DateTime.parse(issue['issueDate'])
        : null;
    final returnDate = issue['returnDate'] != null
        ? DateTime.parse(issue['returnDate'])
        : null;
    final actualReturnDate = issue['actualReturnDate'] != null
        ? DateTime.parse(issue['actualReturnDate'])
        : null;
    final isOverdue =
        !isReturned && returnDate != null && DateTime.now().isAfter(returnDate);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isReturned
                        ? [Colors.green, Colors.green.shade700]
                        : isOverdue
                        ? [Colors.red, Colors.red.shade700]
                        : [Colors.orange, Colors.orange.shade700],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isReturned ? Icons.check_circle : Icons.book,
                      size: 56,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book['title'] ?? 'Unknown',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book['author'] ?? 'Unknown'}',
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

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isReturned
                              ? Colors.green.shade50
                              : isOverdue
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReturned
                                ? Colors.green
                                : isOverdue
                                ? Colors.red
                                : Colors.orange,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isReturned
                                      ? Icons.check_circle
                                      : isOverdue
                                      ? Icons.warning
                                      : Icons.schedule,
                                  color: isReturned
                                      ? Colors.green
                                      : isOverdue
                                      ? Colors.red
                                      : Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isReturned
                                      ? 'RETURNED'
                                      : isOverdue
                                      ? 'OVERDUE'
                                      : 'ISSUED',
                                  style: TextStyle(
                                    color: isReturned
                                        ? Colors.green.shade900
                                        : isOverdue
                                        ? Colors.red.shade900
                                        : Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (issueDate != null)
                              Text(
                                'Issued: ${formatDate(issue['issueDate'])}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            if (returnDate != null && !isReturned)
                              Text(
                                'Due: ${formatDate(issue['returnDate'])}',
                                style: TextStyle(
                                  color: isOverdue
                                      ? Colors.red
                                      : Colors.grey.shade700,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            if (isReturned && actualReturnDate != null)
                              Text(
                                'Returned on: ${formatDate(issue['actualReturnDate'])}',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Book Information
                      const Text(
                        'Book Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard([
                        if (book['isbn'] != null &&
                            book['isbn'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.qr_code_2,
                            'ISBN',
                            book['isbn'],
                          ),
                        if (book['publisher'] != null &&
                            book['publisher'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.business,
                            'Publisher',
                            book['publisher'],
                          ),
                        if (book['publishedYear'] != null)
                          _buildDetailRow(
                            Icons.calendar_today,
                            'Year',
                            book['publishedYear'].toString(),
                          ),
                        if (book['genre'] != null &&
                            book['genre'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.category,
                            'Genre',
                            book['genre'],
                          ),
                      ]),

                      if (book['description'] != null &&
                          book['description'].toString().isNotEmpty) ...[
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
                            book['description'],
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
                    if (!isReturned) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            handleReturn(
                              issue['_id'],
                              book['title'] ?? 'Unknown',
                            );
                          },
                          icon: const Icon(Icons.assignment_return),
                          label: const Text('Return Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orange.shade700),
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
                    color: Colors.grey.shade900,
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
        appBar: AppBar(title: const Text('My Issued Books')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (issuedBooks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Issued Books')),
        body: const Center(child: Text('No books issued yet')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Issued Books')),
      body: RefreshIndicator(
        onRefresh: loadBooks,
        child: ListView.builder(
          itemCount: issuedBooks.length,
          itemBuilder: (context, index) {
            final issue = issuedBooks[index];
            final book = issue['book'];
            final isReturned = issue['returned'] ?? false;
            final returnDate = issue['returnDate'] != null
                ? DateTime.parse(issue['returnDate'])
                : null;
            final issueDate = issue['issueDate'] != null
                ? DateTime.parse(issue['issueDate'])
                : null;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isReturned ? Colors.grey.shade200 : null,
              child: ListTile(
                onTap: () => showIssuedBookDetailsModal(issue),
                leading: Icon(
                  isReturned ? Icons.check_circle : Icons.book,
                  color: getStatusColor(isReturned, returnDate),
                ),
                title: Text(
                  book['title'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Author: ${book['author'] ?? 'Unknown'}'),
                    if (issueDate != null)
                      Text('Issued: ${formatDate(issue['issueDate'])}'),
                    if (returnDate != null && !isReturned)
                      Text(
                        'Due: ${formatDate(issue['returnDate'])}',
                        style: TextStyle(
                          color: DateTime.now().isAfter(returnDate)
                              ? Colors.red
                              : null,
                          fontWeight: DateTime.now().isAfter(returnDate)
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    if (isReturned && issue['actualReturnDate'] != null)
                      Text(
                        'Returned: ${formatDate(issue['actualReturnDate'])}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                trailing: isReturned
                    ? Icon(Icons.check_circle, color: Colors.green, size: 32)
                    : Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ),
            );
          },
        ),
      ),
    );
  }
}
