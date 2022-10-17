FROM alpine:latest

ARG CUST_CODE

RUN apk --no-cache add dnsmasq

COPY dnsmasq.conf /etc/dnsmasq.conf

RUN sed -i "s/__CUST_CODE__/${CUST_CODE}/g" /etc/dnsmasq.conf

ENTRYPOINT [ "dnsmasq", "-d" ]