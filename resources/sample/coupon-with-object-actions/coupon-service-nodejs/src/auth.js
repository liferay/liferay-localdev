const axios = require('axios');
const fs = require('fs');
const jwktopem = require("jwk-to-pem");
const jwt = require('jsonwebtoken');
const logger = require('./util/log');
const path = require('path');

async function authenticate(req, res, next) {
  const authorizationHeader = req.headers['authorization'];

  let token;
  if (authorizationHeader) {
    token = authorizationHeader.split(' ')[1];
  }

  if (req.path === '/') {
    next();
  }	else if (token) {
    const jwtKeySet = await fetchJwtKeySet();
    const publicKey = jwktopem(jwtKeySet.keys[0]);

    jwt.verify(token, publicKey, { algorithms: ['RS256'] }, (err) => {
      if (err) {
        logger.debug('ERR!', err);
        const errMessage = 'Authentication refused! Unauthorized action.';
        logger.error(errMessage);
        res.status(401).json({ error: errMessage});
        res.end();
      } else {
        logger.debug('VALID!');
        next();
      }
    });
  } else {
    res.status(401).json({ error: 'Unauthorized! You must be logged in to use this service!' });
    res.end();
  }
}

async function fetchJwtKeySet() {
  const dxpMainDomain = readDxpMetadata('com.liferay.lxc.dxp.mainDomain');
  const dxpServerProtocol = readDxpMetadata('com.liferay.lxc.dxp.server.protocol');
  const jwksUri = readInitMetadata('coupon-updated-nodejs-user-agent.oauth2.jwks.uri');

  const res = await axios.get(`${dxpServerProtocol}://${dxpMainDomain}${jwksUri}`);

  return res.data;
}

function readDxpMetadata(fileName) {
  const filePath = path.join('/etc/liferay/lxc/dxp-metadata', fileName);

  return fs.readFileSync(filePath);
}

function readInitMetadata(fileName) {
  const filePath = path.join('/etc/liferay/lxc/ext-init-metadata', fileName);

  return fs.readFileSync(filePath);
}

module.exports = authenticate;
