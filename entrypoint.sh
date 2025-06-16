#!/bin/sh

# Configure the mailname in the exim.conf file
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

# Function to retrieve the public IP address from the ipify API
get_public_ip(){
    curl -s https://api.ipify.org/ || echo "Error: Unable to retrieve public IP address."
}

# Function to print the configuration summary
# This function will provide instructions on how to set up the DNS records for SPF and DKIM
print_configuration() {
	DKIM_SELECTOR=${DKIM_SELECTOR:-default}
	PUBLIC_IP=$(get_public_ip)
	echo ""
	echo "=========================="
	echo "Configuration Summary"
	echo ""
	echo -e "\033[1mSPF DNS TXT record\033[0m"
	echo "v=spf1 a mx ip4:${PUBLIC_IP} -all"
	echo ""
	echo -e "\033[1mDKIM DNS TXT record\033[0m"
    echo "${DKIM_SELECTOR}._domainkey.${MAILNAME} IN TXT \"v=DKIM1; k=rsa; p=$(openssl rsa -in "${DKIM_PRIVATE_KEY}" -pubout -outform PEM 2>/dev/null | sed '/^-----/d' | tr -d '\n')\""
	echo "=========================="
	echo ""
	
}

configure_dkim(){
	if [ -z ${DKIM_PRIVATE_KEY} ]; then
		DKIM_PRIVATE_KEY="/etc/dkim/${MAILNAME}.key"
		echo "DKIM_PRIVATE_KEY not set, using default: ${DKIM_PRIVATE_KEY}"
	fi

	if [ ! -f "${DKIM_PRIVATE_KEY}" ]; then
		echo "Warning: DKIM private key file ${DKIM_PRIVATE_KEY} does not exist. Generating a new key."
		openssl genrsa -out "${DKIM_PRIVATE_KEY}" 2048
		openssl rsa -in "${DKIM_PRIVATE_KEY}" -out "${DKIM_PRIVATE_KEY}.pub" -pubout -outform PEM
		echo "DKIM private key generated at ${DKIM_PRIVATE_KEY} and public key at ${DKIM_PRIVATE_KEY}.pub"
		print_configuration
	fi
}

configure_macro() {
  {
    [ -n "${WHITELIST_DOMAINS}" ] && echo "ALLOWED_DOMAINS=${WHITELIST_DOMAINS}"
    [ -n "${DKIM_PRIVATE_KEY}" ] && echo "DKIM_PRIVATE_KEY=${DKIM_PRIVATE_KEY}"
    [ -n "${DKIM_SELECTOR}" ] && echo "DKIM_SELECTOR=${DKIM_SELECTOR}"
  } >> /etc/exim/macros.conf
}

configure_macro
configure_mailname
configure_dkim
print_configuration



echo "Start mailserver"
exec "$@"
