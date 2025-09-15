const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('./models/User');

const router = express.Router();
const JWT_SECRET = 'your_jwt_secret'; // store this securely

// Register
router.post('/register', async (req, res) => {
  const { username, password } = req.body;
  const hashed = await bcrypt.hash(password, 10);

  try {
    const user = await User.create({ username, password: hashed });
    res.status(201).json({ message: 'User created' });
  } catch (e) {
    res.status(400).json({ error: 'User already exists' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  const user = await User.findOne({ username });
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

  const token = jwt.sign({ userId: user._id, username }, JWT_SECRET, { expiresIn: '1h' });

  res.json({ token });
});

module.exports = router;
