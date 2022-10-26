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
    const jwtSecret = await fetchJWTSecret();
    const publicKey = jwktopem(jwtSecret.keys[0]);

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

async function fetchJWTSecret() {
  const jwtSecretURIFileName = path.join('/etc/liferay/lxc/ext-init-metadata', 'coupon-function-nodejs-user-agent.oauth2.jwks.uri');

  const jwtSecretURI = fs.readFileSync(jwtSecretURIFileName);

  const res = await axios.get(jwtSecretURI);

  return res.data;
}

module.exports = authenticate;
