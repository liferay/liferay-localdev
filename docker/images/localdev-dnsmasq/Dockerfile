FROM alpine:latest

ARG LFRDEV_DOMAIN

RUN apk update \
	&& apk --no-cache add dnsmasq 

COPY dnsmasq.conf /etc/dnsmasq.conf

RUN sed -i "s/__LFRDEV_DOMAIN__/${LFRDEV_DOMAIN}/g" /etc/dnsmasq.conf

ENTRYPOINT [ "dnsmasq", "-d" ]
