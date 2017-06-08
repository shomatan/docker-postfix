FROM alpine:3.5

MAINTAINER Shoma Nishitateno <shoma416@gmail.com>

ENV POSTFIX_HOSTNAME=mail.example.com POSTFIX_DOMAIN=example.com POSTFIX_INET_INTERFACES=all

RUN set -ex \
    && apk update \
    && apk add --no-cache \
        dumb-init \
        rsyslog \
        postfix=3.1.3-r0 \
        mailx=8.1.1-r1 \
        opendkim=2.10.3-r4 \
        cyrus-sasl=2.1.26-r8

RUN set -ex \
    && addgroup -S vpostfix -g 1000 \
    && adduser -D -S -h /var/mail -s /sbin/nologin -G vpostfix vpostfix -u 1000 \
    && touch /etc/postfix/valias \
    && touch /etc/postfix/vmailbox \
    && mkdir -p /var/mail/vhosts \
    && chown -R vpostfix:vpostfix /var/mail

ADD files/docker-entrypoint.sh /

EXPOSE 25 587

ENTRYPOINT ["/bin/sh"]

CMD ["/docker-entrypoint.sh"]