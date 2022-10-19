FROM gamerson/dxp:7.4.13.LOCALDEV-SNAPSHOT-20221018133757

ARG LFRDEV_DOMAIN

ENV LIFERAY_WORKSPACE_ENVIRONMENT=lxc
ENV JPDA_ADDRESS=0.0.0.0:8000
ENV LIFERAY_JPDA_ENABLED=true
ENV LIFERAY_MODULE_PERIOD_FRAMEWORK_PERIOD_PROPERTIES_PERIOD_OSGI_PERIOD_CONSOLE=0.0.0.0:11311

ENV LIFERAY_SQL_DEFAULT_WEBID=liferay.com
ENV LIFERAY_SQL_LOCALDEV_WEBID=dxp.${LFRDEV_DOMAIN}

COPY --chown=liferay:liferay configs /home/liferay/configs
COPY --chown=liferay:liferay 101_copy_configs.sh /usr/local/liferay/scripts/pre-configure/101_copy_configs.sh

# Fix the webId of the default instance
RUN \
	curl -fsSL https://cytranet.dl.sourceforge.net/project/hsqldb/hsqldb/hsqldb_2_7/hsqldb-2.7.0.zip -o hsqldb-2.7.0.zip && \
	unzip -q hsqldb-2.7.0.zip && \
	echo "urlid lportal" >> sqltool.rc && \
	echo "username sa" >> sqltool.rc && \
	echo "password" >> sqltool.rc && \
	echo "url jdbc:hsqldb:file:/opt/liferay/data/hypersonic/lportal" >> sqltool.rc && \
	java -cp hsqldb-2.7.0/hsqldb/lib/sqltool.jar:tomcat/webapps/ROOT/WEB-INF/shielded-container-lib/hsql.jar \
		org.hsqldb.cmdline.SqlTool --rcFile=/opt/liferay/sqltool.rc --autoCommit \
		--sql="\
			update virtualhost set hostname='${LIFERAY_SQL_LOCALDEV_WEBID}' where companyid= \
				(select companyid from company where webid='${LIFERAY_SQL_DEFAULT_WEBID}');\
			update company set mx='${LIFERAY_SQL_LOCALDEV_WEBID}', webId='${LIFERAY_SQL_LOCALDEV_WEBID}' where webId='${LIFERAY_SQL_DEFAULT_WEBID}';\
			update user_ set emailaddress='test@${LIFERAY_SQL_LOCALDEV_WEBID}' where emailaddress='test@${LIFERAY_SQL_DEFAULT_WEBID}';" lportal

USER root

RUN apt-get update && apt-get install libnss3-tools

RUN \
  export ARCH=$(dpkg --print-architecture) && \
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/${ARCH}" && \
    chmod +x mkcert-v*-linux-${ARCH} && \
    cp mkcert-v*-linux-${ARCH} /usr/local/bin/mkcert && \
    mkdir /var/lib/caroot

ENV TRUST_STORES=system,java
ENV CAROOT=/var/lib/caroot

COPY rootCA.pem /var/lib/caroot

RUN mkcert -install

USER liferay:liferay