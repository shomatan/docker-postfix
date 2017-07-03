set +e

POSTFIX_VDOMAINS=${POSTFIX_VDOMAINS:-"${POSTFIX_HOSTNAME}"}

echo "** Preparing Postfix"

echo "** Preparing main.cf"

postconf -e myhostname="${POSTFIX_HOSTNAME}"
postconf -e mydomain="${POSTFIX_DOMAIN}"
postconf -e inet_interfaces="${POSTFIX_INET_INTERFACES}"
postconf -e mydestination='localhost.$mydomain, localhost'
postconf -e home_mailbox="Maildir/"
postconf -e smtpd_banner="\$myhostname ESMTP unknown"
postconf -e message_size_limit=10485760
postconf -e postfix_default_privs="nobody"
# sasl
postconf -e smtpd_sasl_auth_enable=yes
postconf -e smtpd_sasl_local_domain='$mydomain'
postconf -e smtpd_recipient_restrictions="permit_mynetworks permit_sasl_authenticated reject_unauth_destination"
postconf -e smtpd_sasl_security_options="noanonymous,noplaintext"
# virtual mailbox
postconf -e virtual_mailbox_domains="${POSTFIX_VDOMAINS}"
postconf -e virtual_mailbox_base=/var/mail/vhosts
postconf -e virtual_mailbox_maps=hash:/etc/postfix/vmailbox
postconf -e virtual_alias_maps=hash:/etc/postfix/valias
postconf -e virtual_minimum_uid=1000
postconf -e virtual_uid_maps=static:1000
postconf -e virtual_gid_maps=static:1000
# Disable EAI support
postconf -e smtputf8_enable=no
# TLS
postconf -e smtpd_use_tls=yes
postconf -e smtp_tls_security_level=may
postconf -e smtpd_tls_cert_file=/etc/postfix/ssl.cert
postconf -e smtpd_tls_key_file=/etc/postfix/ssl.key

chown root:root /etc/postfix/vmailbox

newaliases
postmap /etc/postfix/vmailbox
postmap /etc/postfix/valias
postmap /etc/postfix/transport

#echo "** Preparing OpenDKIM"

echo "** Preparing sasl DB"
if [ ! -e /etc/postfix/sasl/sasldb2 ]; then
    mkdir /etc/postfix/sasl
    # Create init user
    echo 'test' | saslpasswd2 -f /etc/postfix/sasl/sasldb2 -c -u test test
    # Disable init user
    saslpasswd2 -f /etc/postfix/sasl/sasldb2 -d test
    ln -sf /etc/postfix/sasl/sasldb2 /etc/sasldb2
fi
chgrp postfix /etc/sasldb2

echo "########################################################"

echo "** Executing postfix and syslog"

touch /var/log/maillog
rsyslogd ; postfix start

exec dumb-init tail -f /var/log/maillog