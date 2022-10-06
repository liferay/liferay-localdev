FROM rotty3000/dxp:7.4.13.SNAPSHOT-20221005164010

ENV LIFERAY_WORKSPACE_ENVIRONMENT=lxc
ENV JPDA_ADDRESS=0.0.0.0:8000
ENV LIFERAY_JPDA_ENABLED=true
ENV LIFERAY_MODULE_PERIOD_FRAMEWORK_PERIOD_PROPERTIES_PERIOD_OSGI_PERIOD_CONSOLE=0.0.0.0:11311

COPY --chown=liferay:liferay configs /home/liferay/configs
COPY --chown=liferay:liferay 101_copy_configs.sh /usr/local/liferay/scripts/pre-configure/101_copy_configs.sh

USER root

COPY ca.crt /usr/lib/jvm/zulu11/lib/security

RUN \
	keytool -noprompt -trustcacerts -importcert \
		-alias project-cert \
		-storepass changeit \
		-cacerts \
		-file /usr/lib/jvm/zulu11/lib/security/ca.crt

USER liferay:liferay