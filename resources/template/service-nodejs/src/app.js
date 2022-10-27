const cookieParser = require('cookie-parser');
const express = require('express');
const logger = require('./util/log');

const app = express();

app.use(express.json({ limit: 64 * 1000 }));
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.get('/', function(req, res) {
  res.status(200).send('READY');
});

module.exports = app;