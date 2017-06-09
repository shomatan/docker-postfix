# Docker: Postfix

Mail Transfer Agent image based on Alpine Linux.

## Environment variables

- POSTFIX_HOSTNAME
- POSTFIX_DOMAIN
- POSTFIX_VDOMAINS

### Note

#### /etc/postfix/vmailbox

    shoma@example.com example.com/shoma/ # <- Add slash enabled Maildir format

#### Create auth password
    
    docker exec -it postfix saslpasswd2 -c -u ${POSTFIX_DOMAIN} ${USERNAME}