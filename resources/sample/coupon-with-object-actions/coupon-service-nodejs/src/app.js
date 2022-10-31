const authenticate = require('./auth.js');
const cookieParser = require('cookie-parser');
const express = require('express');
const logger = require('./util/log');

const app = express();

app.use(express.json({ limit: 64 * 1000 }));
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(authenticate);

app.get('/', function(req, res) {
  res.status(200).send('READY');
});

app.post('/coupon/updated', function(req, res) {
  const jsonObject = req.body;

  logger.info(jsonObject);

  res.status(200).send('OK');
});

module.exports = app;