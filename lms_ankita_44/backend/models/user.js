const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  username: {
    type: String,
    required: true,
    unique: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  userType: {
    type: String,
    enum: ['LIBRARIAN', 'STUDENT'],
    default: 'STUDENT',
  },
  password: {
    type: String,
    required: true,
  },
});

// 🔥 THIS LINE FIXES THE ERROR
module.exports =
  mongoose.models.User || mongoose.model('User', userSchema);
