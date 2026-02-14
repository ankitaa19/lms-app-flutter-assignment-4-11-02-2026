import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../models/user.dart';

import '../../services/book_service.dart';
import '../../services/user_service.dart';
import '../../services/issue_book_service.dart';

import '../../utils/custom_Alert_box.dart';
import 'view_issued_books.dart';

class IssueBookScreen extends StatefulWidget {
  const IssueBookScreen({super.key});

  @override
  State<IssueBookScreen> createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  List<Book> books = [];
  List<User> students = [];

  Book? selectedBook;
  User? selectedStudent;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final allBooks = await BookService.getAllBooks();
      final allStudents = await UserService.getStudents();

      // ✅ Only show books that are in stock
      books = allBooks.where((b) => b.quantity > 0).toList();
      students = allStudents;
    } catch (e) {
      if (mounted) {
        CustomAlertBox.showError(context, 'Error', e.toString());
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> handleIssue() async {
    if (selectedBook == null || selectedStudent == null) {
      CustomAlertBox.showError(
        context,
        'Error',
        'Please select both book and student',
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issue this book to student?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow('Book:', '${selectedBook!.title}'),
            _buildInfoRow('Author:', selectedBook!.author),
            _buildInfoRow('Student:', selectedStudent!.name),
            _buildInfoRow('Email:', selectedStudent!.email),
            const SizedBox(height: 8),
            Text(
              'Return Date: ${_getReturnDate()}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
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

    if (confirm != true) return;

    try {
      await IssueBookService.issueBook(
        selectedBook!.id,
        selectedStudent!.id,
      );

      if (mounted) {
        CustomAlertBox.showSuccess(
          context,
          'Success',
          'Book "${selectedBook!.title}" issued to ${selectedStudent!.name}',
        );

        // Reset selections
        setState(() {
          selectedBook = null;
          selectedStudent = null;
        });

        // Reload data to update available books
        await loadData();

        // Navigate to view all issued books to see the assignment
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ViewIssuedBooksScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomAlertBox.showError(
          context,
          'Error',
          e.toString().replaceAll('Exception:', '').trim(),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getReturnDate() {
    final returnDate = DateTime.now().add(const Duration(days: 7));
    return '${returnDate.day}/${returnDate.month}/${returnDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Book')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (books.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Book')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No books available to issue',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    if (students.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Book')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'No Students Registered',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Students need to register first before you can issue books to them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register New Student'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Book and Student',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a book and student to issue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Book Selection
              const Text(
                '1. Select Book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Book>(
                value: selectedBook,
                decoration: const InputDecoration(
                  labelText: 'Choose a Book',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: books.map((b) {
                  return DropdownMenuItem<Book>(
                    value: b,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${b.author} | Available: ${b.quantity} copies',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedBook = v),
              ),
              const SizedBox(height: 24),
              // Student Selection
              const Text(
                '2. Select Student',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<User>(
                value: selectedStudent,
                decoration: const InputDecoration(
                  labelText: 'Choose a Student',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: students.map((s) {
                  return DropdownMenuItem<User>(
                    value: s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          s.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedStudent = v),
              ),
              // Preview Card
              if (selectedBook != null && selectedStudent != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Issue Preview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Book:', selectedBook!.title),
                        _buildPreviewRow('Author:', selectedBook!.author),
                        _buildPreviewRow('Student:', selectedStudent!.name),
                        _buildPreviewRow('Email:', selectedStudent!.email),
                        const SizedBox(height: 8),
                        Text(
                          'Return Date: ${_getReturnDate()}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: (selectedBook != null && selectedStudent != null)
                    ? handleIssue
                    : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Issue Book to Student'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
