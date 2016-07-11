#!/bin/sh

MAIN_CF=/etc/postfix/main.cf
PASSWORD_FILE=/etc/postfix/smtp_password
ALIASES_FILE=/etc/aliases

mkdir /var/mail
chgrp mail /var/mail

echo "smtputf8_enable = no" >>${MAIN_CF}
echo "alias_maps = hash:/etc/aliases" >>${MAIN_CF}
echo "alias_database = hash:/etc/aliases" >>${MAIN_CF}

MYDESTINATION='localhost, $myhostname, localhost.$mydomain, $mydomain'
if [ -n "${SMTP_MYDESTINATION}" ]; then
    MYDESTINATION="${MYDESTINATION}, ${SMTP_MYDESTINATION}"
fi
echo "mydestination = ${MYDESTINATION}" >>${MAIN_CF}

if [ -n "${SMTP_MYNETWORKS}" ]; then
    echo "mynetworks = ${SMTP_MYNETWORKS}"  >>${MAIN_CF}
fi

if [ -n "${SMTP_RELAYHOST}" ]; then
    echo "relayhost = ${SMTP_RELAYHOST}" >>${MAIN_CF}

    if [ -n "${SMTP_PASSWORD}" ]; then
        echo "${SMTP_RELAYHOST} ${SMTP_PASSWORD}" >${PASSWORD_FILE}
        chmod 400 ${PASSWORD_FILE}
        postmap hash:${PASSWORD_FILE}

        echo "smtp_tls_security_level = may" >>${MAIN_CF}
        echo "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt" >>${MAIN_CF}
        echo "smtp_sasl_auth_enable = yes" >>${MAIN_CF}
        echo "smtp_sasl_security_options = noanonymous" >>${MAIN_CF}
        echo "smtp_sasl_password_maps = hash:${PASSWORD_FILE}" >>${MAIN_CF}
    fi
fi

if [ -n "${SMTP_ALIASES}" ]; then
    for i in ${SMTP_ALIASES}; do
      echo $i >>${ALIASES_FILE}
    done
fi
newaliases
postconf -n

/usr/sbin/rsyslogd
/usr/sbin/postfix start
tail -f /var/log/maillog
