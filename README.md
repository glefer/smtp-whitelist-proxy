# SMTP Whitelist Proxy

Cette image a pour objectif de fournir un serveur mail avec la possibilité de filtrer par domaines.
Ceci est notamment utile sur les environnements de recette afin de ne pas envoyer de mails aux destinataires finaux.

# Quick reference
Les sources du projets sont disponibles via le repository [https://github.com/glefer/smtp-whitelist-proxy](https://github.com/glefer/smtp-whitelist-proxy)

# How to use this image
## Environnements
### MAILNAME
Afin de lancer l'image, il est obligatoire de lui fournir la variable d'environnement `MAILNAME` avec un nom de domaine 
dont l'entrée DNS A correspond au serveur hébergeant le container. 

Ce domaine est également utilisé pour configurer les enregistrements SPF (Sender Policy Framework). Cela permet de garantir que les emails envoyés depuis ce serveur sont autorisés par le domaine spécifié, réduisant ainsi le risque que les emails soient marqués comme spam.

### WHITELIST_DOMAINS
Afin de pouvoir spécifier la liste des domaines de destinations autorisés, vous pouvez renseigner la variable d'environnement
`WHITELIST_DOMAINS` avec la liste des domaines.
Cette liste est de la forme `domaine1:domaine2:domaineXXXX`.

Par exemple, si vous souhaitez ne permettre l'envoi que vers des mails domain1.fr et domain2.fr, la configuration correspondante est :
```yaml
WHITELIST_DOMAINS: 'domain1.fr:domain2.fr'
```

## Lancement de l'image

Vous trouverez ci-dessous un exemple de configuration via docker compose.
```yaml
# compose.yml
services:
  smtp:
    image: glefer/smtp-whitelist-proxy:latest
    environment:
      MAILNAME: '<server_domain>'
      # optional
      #WHITELIST_DOMAINS: 'domain1:domain2'
```

