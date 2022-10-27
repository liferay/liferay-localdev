FROM node:16

RUN \
  export ARCH=$(dpkg --print-architecture) && \
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/${ARCH}" && \
    chmod +x mkcert-v*-linux-${ARCH} && \
    cp mkcert-v*-linux-${ARCH} /usr/local/bin/mkcert && \
    mkdir /var/lib/caroot
ENV TRUST_STORES=system
ENV CAROOT=/var/lib/caroot
COPY rootCA.pem /var/lib/caroot
RUN mkcert -install

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install --only=production
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY src/* /usr/src/app/
COPY . .

EXPOSE 3000
CMD [ "npm", "run", "startLocaldev" ]