FROM liferay/jdk11:latest

RUN \
	echo "#!/usr/bin/env bash" >> /app.sh && \
	echo "export JAVA_VERSION=zulu11" >> /app.sh && \
	echo ". set_java_version.sh" >> /app.sh && \
	echo "export JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION"

# Use this to enable Localdev root CA, this is a no-op in the cloud
RUN \
	export ARCH=$(dpkg --print-architecture) && \
	curl -fsSL "https://dl.filippo.io/mkcert/latest?for=linux/${ARCH}" -o /usr/local/bin/mkcert && \
	chmod +x /usr/local/bin/mkcert && \
	mkdir /var/lib/caroot && \
	\
	echo "if [ -e /opt/liferay/caroot/rootCA.pem ];then" >> /app.sh && \
	echo "	export TRUST_STORES=java,system" >> /app.sh && \
	echo "	export CAROOT=/var/lib/caroot" >> /app.sh && \
	echo "	cp -f /opt/liferay/caroot/rootCA.pem /var/lib/caroot" >> /app.sh && \
	echo "	mkcert -install" >> /app.sh && \
	echo "fi" >> /app.sh

# Application specific parts
WORKDIR /opt/app

COPY *.jar app.jar

ENV DEBUG_PORT=""

# Append application start commands to /app.sh
RUN \
	echo "java -Xmx256m -agentlib:jdwp=transport=dt_socket,address=*:${DEBUG_PORT:-8001},server=y,suspend=n -jar /opt/app/app.jar" >> /app.sh && \
	chmod +x /app.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/app.sh"]