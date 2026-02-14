import 'package:flutter/material.dart';
import '../../services/issue_book_service.dart';
import '../../utils/custom_Alert_box.dart';

class ViewIssuedBooksScreen extends StatefulWidget {
  const ViewIssuedBooksScreen({super.key});

  @override
  State<ViewIssuedBooksScreen> createState() => _ViewIssuedBooksScreenState();
}

class _ViewIssuedBooksScreenState extends State<ViewIssuedBooksScreen> {
  List<dynamic> issuedBooks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadIssuedBooks();
  }

  Future<void> loadIssuedBooks() async {
    try {
      final books = await IssueBookService.getAllIssuedBooks();
      setState(() {
        issuedBooks = books;
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomAlertBox.showError(context, 'Error', e.toString());
        setState(() => loading = false);
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

  String formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  int calculateDaysIssued(String? issueDateString) {
    if (issueDateString == null) return 0;
    try {
      final issueDate = DateTime.parse(issueDateString);
      final now = DateTime.now();
      return now.difference(issueDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  int calculateDaysRemaining(String? returnDateString) {
    if (returnDateString == null) return 0;
    try {
      final returnDate = DateTime.parse(returnDateString);
      final now = DateTime.now();
      final difference = returnDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  int calculateTotalDays(String? issueDateString, String? returnDateString) {
    if (issueDateString == null || returnDateString == null)
      return 7; // Default 7 days
    try {
      final issueDate = DateTime.parse(issueDateString);
      final returnDate = DateTime.parse(returnDateString);
      return returnDate.difference(issueDate).inDays;
    } catch (e) {
      return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Issued Books')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (issuedBooks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Issued Books')),
        body: const Center(child: Text('No books issued yet')),
      );
    }

    // Separate active and returned books
    final activeBooks = issuedBooks
        .where((issue) => !(issue['returned'] ?? false))
        .toList();
    final returnedBooks = issuedBooks
        .where((issue) => issue['returned'] ?? false)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Issued Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Could add filter functionality here
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadIssuedBooks,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.book), text: 'Active Issues'),
                  Tab(icon: Icon(Icons.check_circle), text: 'Returned'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Active Issues Tab
                    activeBooks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('No active book issues'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: activeBooks.length,
                            itemBuilder: (context, index) {
                              return _buildIssueCard(activeBooks[index], true);
                            },
                          ),
                    // Returned Books Tab
                    returnedBooks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('No returned books'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: returnedBooks.length,
                            itemBuilder: (context, index) {
                              return _buildIssueCard(
                                returnedBooks[index],
                                false,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue, bool isActive) {
    final book = issue['book'];
    final student = issue['student'];
    final isReturned = issue['returned'] ?? false;
    final issueDate = issue['issueDate'];
    final returnDate = issue['returnDate'] != null
        ? DateTime.parse(issue['returnDate'])
        : null;
    final isOverdue =
        returnDate != null && !isReturned && DateTime.now().isAfter(returnDate);

    final daysIssued = calculateDaysIssued(issueDate);
    final daysRemaining = calculateDaysRemaining(issue['returnDate']);
    final totalDays = calculateTotalDays(issueDate, issue['returnDate']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isReturned
          ? Colors.grey.shade100
          : isOverdue
          ? Colors.red.shade50
          : Colors.blue.shade50,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isReturned
              ? Colors.green
              : isOverdue
              ? Colors.red
              : Colors.blue,
          child: Icon(
            isReturned
                ? Icons.check_circle
                : isOverdue
                ? Icons.warning
                : Icons.book,
            color: Colors.white,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book['title'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  'Student: ${student['name'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Assignment Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned: ${formatDate(issueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Duration
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.purple.shade700),
                const SizedBox(width: 4),
                Text(
                  'Duration: $totalDays days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Status
            if (!isReturned)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue
                        ? 'Overdue by ${daysRemaining.abs()} days'
                        : '$daysRemaining days remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Returned after $daysIssued days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: isReturned
            ? const Chip(
                label: Text('Returned'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            : isOverdue
            ? const Chip(
                label: Text('Overdue'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white),
              )
            : const Chip(
                label: Text('Active'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Information Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Book Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Title:', book['title'] ?? 'Unknown'),
                      _buildDetailRow('Author:', book['author'] ?? 'Unknown'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Student Information Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.purple.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Name:', student['name'] ?? 'Unknown'),
                      _buildDetailRow('Email:', student['email'] ?? 'Unknown'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Assignment Details Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assignment Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Assigned Date:',
                        formatDateTime(issueDate),
                      ),
                      _buildDetailRow(
                        'Due Date:',
                        formatDateTime(issue['returnDate']),
                      ),
                      _buildDetailRow(
                        'Total Duration:',
                        '$totalDays days',
                        color: Colors.blue.shade700,
                      ),
                      if (!isReturned) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Days Issued:',
                          '$daysIssued days',
                          color: Colors.green.shade700,
                        ),
                        _buildDetailRow(
                          'Days Remaining:',
                          daysRemaining > 0 ? '$daysRemaining days' : 'Overdue',
                          color: isOverdue
                              ? Colors.red
                              : Colors.orange.shade700,
                        ),
                      ],
                      if (isReturned && issue['actualReturnDate'] != null) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Returned Date:',
                          formatDateTime(issue['actualReturnDate']),
                          color: Colors.green,
                        ),
                        _buildDetailRow(
                          'Total Days Issued:',
                          '$daysIssued days',
                          color: Colors.green.shade700,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overdue Notice',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This book is overdue by ${daysRemaining.abs()} days',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
