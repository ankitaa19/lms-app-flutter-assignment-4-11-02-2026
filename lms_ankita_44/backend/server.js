const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const authRouter = require('./routes/authRouter');
const bookRouter = require('./routes/bookRouter');
const issueRouter = require('./routes/issueBookRouter');

// Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/lms')
  .then(() => console.log('Database connected successfully'))
  .catch((err) => console.error('Database connection error:', err));

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRouter);
app.use('/api/books', bookRouter);
app.use('/api/issue', issueRouter);

app.listen(4000, () => console.log('Server running on port 4000'));
