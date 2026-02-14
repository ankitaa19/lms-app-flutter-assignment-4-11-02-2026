const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const router = express.Router();

/* ================= REGISTER ================= */
router.post('/register', async (req, res) => {
  try {
    const { name, username, email, password, userType } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name,
      username,
      email,
      password: hashedPassword,
      userType: userType || 'STUDENT',
    });

    await user.save();

    res.json({
      message: 'User registered successfully',
    });
  } catch (error) {
    res.status(400).json({
      message: error.message,
    });
  }
});

/* ================= LOGIN ================= */
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username });

    if (!user) {
      return res.status(400).json({
        message: 'Invalid username or password',
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: 'Invalid username or password',
      });
    }

    const token = jwt.sign(
      {
        _id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        userType: user.userType
      },
      'itm',
      { expiresIn: '1d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        _id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        userType: user.userType,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

/* ================= GET ALL STUDENTS ================= */
router.get('/students', async (req, res) => {
  try {
    const students = await User.find({ userType: 'STUDENT' })
      .select('-password');

    res.json(students);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

module.exports = router;
