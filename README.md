# SMTP Whitelist Proxy

This image aims to provide a mail server with the ability to filter by domains.  
This is particularly useful in staging environments to avoid sending emails to final recipients.


<div align="center">
  <img src="docs/assets/logo.webp" alt="SMTP Whitelist Proxy Logo" width="400" height="400">
</div>

[![Docker](https://img.shields.io/docker/pulls/glefer/smtp-whitelist-proxy)](https://hub.docker.com/r/glefer/smtp-whitelist-proxy)

# Quick reference
The project sources are available via the repository [https://github.com/glefer/smtp-whitelist-proxy](https://github.com/glefer/smtp-whitelist-proxy)

# How to use this image
## Environments
### MAILNAME
To run the image, it is mandatory to provide the environment variable `MAILNAME` with a domain name whose DNS A record corresponds to the server hosting the container.

This domain is also used to configure SPF (Sender Policy Framework) records. This ensures that emails sent from this server are authorized by the specified domain, reducing the risk of emails being marked as spam.

### WHITELIST_DOMAINS
To specify the list of allowed destination domains, you can set the environment variable `WHITELIST_DOMAINS` with the list of domains.  
This list should be in the format `domain1:domain2:domainXXXX`.

For example, if you want to allow sending only to emails from domain1.fr and domain2.fr, the corresponding configuration is:
```yaml
WHITELIST_DOMAINS: 'domain1.fr:domain2.fr'
```

## DKIM Management

The image supports DKIM (DomainKeys Identified Mail) configuration to sign outgoing emails. This ensures the authenticity of emails and reduces the risk of them being marked as spam.

### DKIM Key Generation
On the first startup, if no DKIM private key is provided via the mounted volume or the `DKIM_PRIVATE_KEY` environment variable, the image automatically generates a DKIM private key for the domain specified in `MAILNAME`. The generated key is stored in the `/etc/dkim` directory.

### DNS Records to Configure
To ensure DKIM and SPF work correctly, the required DNS records are displayed in the SMTP container logs during startup. Here is an example of generated logs:

```
smtp-1  | DKIM_PRIVATE_KEY not set, using default: /etc/dkim/mydomain.fr.key
smtp-1  | 
smtp-1  | ==========================
smtp-1  | Configuration Summary
smtp-1  | 
smtp-1  | SPF DNS TXT record
smtp-1  | v=spf1 a mx ip4:X.X.X.X -all
smtp-1  | 
smtp-1  | DKIM DNS TXT record
smtp-1  | default._domainkey.mydomain.fr IN TXT "v=DKIM1; k=rsa; p=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
smtp-1  | ==========================
```

The following information must be configured in your DNS:

1. **SPF (Sender Policy Framework)**  
   Add a TXT record based on the `SPF DNS TXT record` line from the logs. For example:
   ```
   @ IN TXT "v=spf1 a mx ip4:X.X.X.X -all"
   ```

2. **DKIM (DomainKeys Identified Mail)**  
   Add a TXT record based on the `DKIM DNS TXT record` line from the logs. For example:
   ```
   default._domainkey.mydomain.fr IN TXT "v=DKIM1; k=rsa; p=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   ```

## Running the Image

Below is an example configuration using Docker Compose:
```yaml
# compose.yml
services:
  smtp:
    image: glefer/smtp-whitelist-proxy:latest
    environment:
      MAILNAME: '<server_domain>'
      # (Optional) domain to whitelist, defaults to no whitelist
      #WHITELIST_DOMAINS: 'domain1.fr:domain2.com'
      # (Optional) Path where the private key is stored, defaults to /etc/dkim/${MAILNAME}.key 
      #DKIM_PRIVATE_KEY: '/etc/dkim/mydomain.fr.key'
    volumes:
      - ./dkim:/etc/dkim
```

