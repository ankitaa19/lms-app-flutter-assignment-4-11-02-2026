const express = require('express');
const Issue = require('../models/issueBook');
const Book = require('../models/book');
const authMiddleware = require('../middlewares/authMiddleware');
const { checkLibrarian } = require('../middlewares/checkRole');
const router = express.Router();

// ISSUE BOOK
router.post('/issue', authMiddleware, async (req, res) => {
  try {
    const { bookId, studentId } = req.body;

    if (!bookId || !studentId) {
      return res.status(400).json({ message: 'Book ID and Student ID are required' });
    }

    const book = await Book.findById(bookId);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    if (book.quantity <= 0) {
      return res.status(400).json({ message: 'Book out of stock' });
    }

    book.quantity -= 1;
    await book.save();

    const issue = await Issue.create({
      book: bookId,
      student: studentId,
      returnDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    });

    res.json({ message: 'Book issued successfully', issue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// RETURN BOOK
router.post('/return/:id', authMiddleware, async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id);
    if (!issue) {
      return res.status(404).json({ message: 'Issue record not found' });
    }

    if (issue.returned) {
      return res.status(400).json({ message: 'Book already returned' });
    }

    issue.returned = true;
    issue.actualReturnDate = new Date();
    await issue.save();

    // Increase book quantity
    const book = await Book.findById(issue.book);
    if (book) {
      book.quantity += 1;
      await book.save();
    }

    res.json({ message: 'Book returned successfully', issue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ALL ISSUED BOOKS (LIBRARIAN)
router.get('/', authMiddleware, checkLibrarian, async (req, res) => {
  try {
    const data = await Issue.find()
      .populate('book')
      .populate('student')
      .sort({ issueDate: -1 });
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// STUDENT ISSUED BOOKS
router.get('/student/:id', authMiddleware, async (req, res) => {
  try {
    const data = await Issue.find({ student: req.params.id })
      .populate('book')
      .sort({ issueDate: -1 });
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
