const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';
const SERVER_MESSAGE = process.env.SERVER_MESSAGE || 'Hello world\n';

// App
const app = express();
app.get(/.*/, (req, res) => {
  res.send(SERVER_MESSAGE);
});


module.exports = app;
