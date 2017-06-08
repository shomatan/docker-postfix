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

chown root:root /etc/postfix/vmailbox

newaliases
postmap /etc/postfix/vmailbox
postmap /etc/postfix/valias

#echo "** Preparing OpenDKIM"

echo "########################################################"

echo "** Executing postfix and syslog"

touch /var/log/maillog
rsyslogd ; postfix start

exec dumb-init tail -f /var/log/maillog