#!/bin/sh

configure_mailname() {

  if [ -z ${MAILNAME} ]; then
    echo "Error: The environment variable MAILNAME must be defined"
    exit 2
  fi

  NSLOOKUP_CHECK=$(nslookup ${MAILNAME} 2>/dev/null)
  if [ "$?" -ne "0" ]; then
    echo "Warning: DNS not found for the domain ${MAILNAME}"
  fi

  sed -i "s/^primary_hostname = .*/primary_hostname = ${MAILNAME}/" /etc/exim/exim.conf

}

configure_mailname

if [ -n "${MAILNAME}" ]; then
  echo "ALLOWED_DOMAINS=$WHITELIST_DOMAINS" >>/etc/exim/macros.conf
fi

echo "Start mailserver"
exec "$@"
