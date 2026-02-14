const express = require('express');
const Book = require('../models/book');
const authMiddleware = require('../middlewares/authMiddleware');
const { checkLibrarian } = require('../middlewares/checkRole');
const router = express.Router();

// GET all books
router.get('/', async (req, res) => {
  try {
    const books = await Book.find();
    res.json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET single book
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    res.json(book);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ADD book
router.post('/add', authMiddleware, checkLibrarian, async (req, res) => {
  try {
    const { title, author, isbn, publisher, publishedYear, genre, description, quantity } = req.body;
    if (!title || !author || quantity === undefined) {
      return res.status(400).json({ message: 'Title, Author, and Quantity are required' });
    }
    const newBook = await Book.create({
      title,
      author,
      isbn: isbn || '',
      publisher: publisher || '',
      publishedYear: publishedYear || null,
      genre: genre || '',
      description: description || '',
      quantity,
    });
    res.json({ message: 'Book added successfully', book: newBook });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// UPDATE book
router.put('/:id', authMiddleware, checkLibrarian, async (req, res) => {
  try {
    const book = await Book.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    res.json({ message: 'Book updated successfully', book });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// DELETE book
router.delete('/:id', authMiddleware, checkLibrarian, async (req, res) => {
  try {
    const book = await Book.findByIdAndDelete(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    res.json({ message: 'Book deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
