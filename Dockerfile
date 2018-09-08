FROM alpine:3.5

LABEL maintainer "Shoma Nishitateno <shoma416@gmail.com>"

ENV POSTFIX_HOSTNAME=mail.example.com POSTFIX_DOMAIN=example.com POSTFIX_INET_INTERFACES=all POSTFIX_VDOMAINS="${POSTFIX_HOSTNAME}"
ENV POSTFIX_TLS_CERT_FILE=/etc/postfix/ssl/ssl.cert POSTFIX_TLS_KEY_FILE=/etc/postfix/ssl/ssl.key

RUN set -ex \
    && apk update \
    && apk add --no-cache \
        dumb-init \
        rsyslog \
        postfix=3.1.3-r0 \
        mailx=8.1.1-r1 \
        opendkim=2.10.3-r4 \
        cyrus-sasl=2.1.26-r8 \
        cyrus-sasl-crammd5=2.1.26-r8 \
        cyrus-sasl-digestmd5=2.1.26-r8

RUN set -ex \
    && addgroup -S vpostfix -g 1000 \
    && adduser -D -S -h /var/mail -s /sbin/nologin -G vpostfix vpostfix -u 1000 \
    && touch /etc/postfix/valias \
    && touch /etc/postfix/vmailbox \
    && mkdir -p /var/mail/vhosts \
    && mkdir -p /etc/postfix/ssl \
    && chown -R vpostfix:vpostfix /var/mail \
    && echo 'pwcheck_method: auxprop' > /usr/lib/sasl2/smtpd.conf

ADD docker-entrypoint.sh /

EXPOSE 25 587

ENTRYPOINT ["/docker-entrypoint.sh"]