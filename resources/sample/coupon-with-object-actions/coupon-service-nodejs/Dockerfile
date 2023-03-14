FROM node:16

RUN apt-get update && \
	apt-get install -y tini && \
	rm -rf /var/lib/apt/lists/*

# Use this to enable Localdev root CA, this is a no-op in the cloud
RUN \
	export ARCH=$(dpkg --print-architecture) && \
	curl -fsSL "https://dl.filippo.io/mkcert/latest?for=linux/${ARCH}" -o /usr/local/bin/mkcert && \
	chmod +x /usr/local/bin/mkcert && \
	mkdir /var/lib/caroot && \
	\
	echo "if [ -e /etc/liferay/localdev/rootCA.pem ];then" >> /app.sh && \
	echo "	export TRUST_STORES=java,system" >> /app.sh && \
	echo "	export CAROOT=/var/lib/caroot" >> /app.sh && \
	echo "	cp -f /etc/liferay/localdev/rootCA.pem /var/lib/caroot" >> /app.sh && \
	echo "	mkcert -install" >> /app.sh && \
	echo "fi" >> /app.sh

# Application specific parts
WORKDIR /opt/app

COPY package*.json ./

RUN npm install --only=production

COPY src/* ./

# Append application start commands to /app.sh
RUN \
	echo "export DENO_TLS_CA_STORE=system" >> /app.sh && \
	echo "cd /opt/app" >> /app.sh && \
	echo "npm run start" >> /app.sh && \
	chmod +x /app.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/app.sh"]