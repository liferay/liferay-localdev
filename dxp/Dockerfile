FROM rotty3000/dxp:7.4.13.SNAPSHOT-20220831094638
ENV LIFERAY_WORKSPACE_ENVIRONMENT=lxc
COPY --chown=liferay:liferay deploy /mnt/liferay/deploy
COPY --chown=liferay:liferay configs /home/liferay/configs
COPY --chown=liferay:liferay 101_copy_configs.sh /usr/local/liferay/scripts/pre-configure/101_copy_configs.sh
COPY ca.crt /opt/liferay
RUN \
	cd /opt/liferay \
	&& keytool -keystore cacerts -storepass changeit \
		-noprompt -trustcacerts -importcert -alias project-cert -file ca.crt
