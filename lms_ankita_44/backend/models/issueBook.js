const mongoose = require('mongoose');

const issueSchema = new mongoose.Schema({
  book: { type: mongoose.Schema.Types.ObjectId, ref: 'Book' },
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  issueDate: { type: Date, default: Date.now },
  returnDate: { type: Date },
  returned: { type: Boolean, default: false },
  actualReturnDate: { type: Date },
});

module.exports =
  mongoose.models.Issue || mongoose.model('Issue', issueSchema);
