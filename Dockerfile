FROM alpine:3.6
MAINTAINER ototadana@gmail.com

ENV POSTFIX_VERSION 3.1.4-r1
ENV MAILX_VERSION 8.1.1-r1

RUN apk add --no-cache ca-certificates mailx=${MAILX_VERSION} postfix=${POSTFIX_VERSION} rsyslog

COPY ./config/. /config/
RUN chmod +x /config/*

EXPOSE 25

CMD ["/config/start.sh"]
