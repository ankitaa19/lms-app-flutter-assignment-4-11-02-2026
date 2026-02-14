const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: { type: String, required: true },
  author: { type: String, required: true },
  isbn: { type: String, default: '' },
  publisher: { type: String, default: '' },
  publishedYear: { type: Number, default: null },
  genre: { type: String, default: '' },
  description: { type: String, default: '' },
  quantity: { type: Number, required: true },
}, {
  timestamps: true
});

module.exports = mongoose.models.Book || mongoose.model('Book', bookSchema);
