import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../../utils/custom_Alert_box.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController publishedYearController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    isbnController.dispose();
    publisherController.dispose();
    publishedYearController.dispose();
    genreController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void handleAddBook() async {
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final isbn = isbnController.text.trim();
    final publisher = publisherController.text.trim();
    final publishedYearText = publishedYearController.text.trim();
    final genre = genreController.text.trim();
    final description = descriptionController.text.trim();
    final qtyText = quantityController.text.trim();

    // 🔐 VALIDATION
    if (title.isEmpty || author.isEmpty || qtyText.isEmpty) {
      CustomAlertBox.showError(
        context,
        'Error',
        'Title, Author, and Quantity are required',
      );
      return;
    }

    final int? quantity = int.tryParse(qtyText);
    if (quantity == null || quantity <= 0) {
      CustomAlertBox.showError(
        context,
        'Error',
        'Quantity must be a valid positive number',
      );
      return;
    }

    int? publishedYear;
    if (publishedYearText.isNotEmpty) {
      publishedYear = int.tryParse(publishedYearText);
      if (publishedYear == null ||
          publishedYear < 1000 ||
          publishedYear > DateTime.now().year) {
        CustomAlertBox.showError(context, 'Error', 'Please enter a valid year');
        return;
      }
    }

    setState(() => loading = true);

    try {
      // ✅ FIX: NAMED PARAMETERS
      await BookService.addBook(
        title: title,
        author: author,
        isbn: isbn,
        publisher: publisher,
        publishedYear: publishedYear,
        genre: genre,
        description: description,
        quantity: quantity,
      );

      if (mounted) {
        // Show success alert
        CustomAlertBox.showSuccess(
          context,
          'Success',
          'Book "$title" added successfully',
        );

        // Wait a moment for the alert to be visible, then navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          // Navigate to librarian dashboard
          Navigator.pushReplacementNamed(context, '/librarian_dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception:', '').trim();
        }
        CustomAlertBox.showError(
          context,
          'Error',
          errorMessage.isEmpty
              ? 'Failed to add book. Please try again.'
              : errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                hintText: 'e.g., 978-3-16-148410-0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: publisherController,
              decoration: const InputDecoration(
                labelText: 'Publisher',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: publishedYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Published Year',
                hintText: 'e.g., 2024',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                hintText: 'e.g., Fiction, Science, History',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the book',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* Required fields',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: handleAddBook,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Book'),
                  ),
          ],
        ),
      ),
    );
  }
}
