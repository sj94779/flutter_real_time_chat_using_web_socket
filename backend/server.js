const bodyParser = require('body-parser');
const authRoutes = require('./auth');


const express = require('express');
const cors = require('cors');
const http = require('http');
const WebSocket = require('ws');
const mongoose = require('mongoose');
const Message = require('./models/Message');

const app = express();
app.use(cors());

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// MongoDB connection
 mongoose.connect('mongodb://localhost:27017/chat_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

const jwt = require('jsonwebtoken');
const JWT_SECRET = 'your_jwt_secret';

wss.on('connection', async (ws, req) => {
  const params = new URLSearchParams(req.url.replace('/?', ''));
  const token = params.get('token');

  let user;
  try {
    user = jwt.verify(token, JWT_SECRET);
  } catch (err) {
    ws.close();
    return;
  }

  console.log('Connected:', user.username);

  // Send history
  const history = await Message.find().sort({ timestamp: 1 }).limit(50);
  history.forEach((msg) => {
    ws.send(JSON.stringify({
      type: 'history',
      text: msg.text,
      username: msg.username,
      timestamp: msg.timestamp,
    }));
  });

  ws.on('message', async (messageText) => {
    const message = new Message({
      text: messageText,
      username: user.username,
    });

    await message.save();

    const payload = JSON.stringify({
      type: 'chat',
      text: message.text,
      username: message.username,
      timestamp: message.timestamp,
    });

    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(payload);
      }
    });
  });
});


app.use(bodyParser.json());
app.use('/auth', authRoutes);


server.listen(8080, () => {
  console.log('Server is listening on http://localhost:8080');
});
