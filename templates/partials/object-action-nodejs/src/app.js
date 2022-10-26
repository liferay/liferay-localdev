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

app.post('/coupons/issued', function(req, res) {
  const couponObject = req.body;

  const status = couponObject.objectEntry.values.issued ? 'issued' : 'not issued';
  const updatedDate = couponObject.objectEntry.modifiedDate || couponObject.objectEntry.createDate;
  const msg = `The status coupon '${couponObject.objectEntry.values.code}' changed to '${status}' by '${couponObject.objectEntry.statusByUserName}' at '${updatedDate}'`;

  logger.info(msg);

  res.status(200).send('OK');
});

module.exports = app;