# Docker Exim Relay Image

[Exim](http://exim.org/) relay [Docker](https://docker.com/) image based on [Alpine](https://alpinelinux.org/) Linux.


A light weight Docker image for an Exim mail relay, based on the official Alpine image.

For extra security, the container runs as exim not root.

## [Docker Run](https://docs.docker.com/engine/reference/run)

### Default setup

This will allow relay from all private address ranges and will relay directly to the internet receiving mail servers

Smtp Auth (`SMTP_PLAINAUTH_USERNAME` / `SMTP_PLAINAUTH_PASSWORD` ) is optional.

```shell
docker run \
       --name smtp \
       --restart always \
       -e SMTP_PLAINAUTH_USERNAME= \
       -e SMTP_PLAINAUTH_PASSWORD= \
       -h my.host.name \
       -d \
       -p 25:25 \
       akit042/exim-smtp
```

### Smarthost setup

To send forward outgoing email to a smart relay host

```shell
docker run \
       --restart always \
       -h my.host.name \
       -d \
       -p 25:25 \
       -e SMARTHOST=some.relayhost.name \
       -e SMTP_USERNAME=someuser \
       -e SMTP_PASSWORD=password \
       akit042/exim-smtp
```

## [Docker Compose](https://docs.docker.com/compose/compose-file)

```yml
version: "2"
  services:
    smtp:
      image: akit042/exim-smtp
      restart: always
      ports:
        - "25:25"
      hostname: my.host.name
      environment:
        - SMARTHOST=some.relayhost.name
        - SMTP_USERNAME=someuser
        - SMTP_PASSWORD=password
```

## Other Variables

###### LOCAL_DOMAINS

* List (colon separated) of domains that are delivered to the local machine
* Defaults to the hostname of the local machine
* Set blank to have no mail delivered locally

###### RELAY_FROM_HOSTS

* A list (colon separated) of subnets to allow relay from
* Set to "\*" to allow any host to relay - use this with RELAY_TO_DOMAINS to allow any client to relay to a list of domains
* Defaults to private address ranges: 10.0.0.0/8:172.16.0.0/12:192.168.0.0/16

###### RELAY_TO_DOMAINS

* A list (colon separated) of domains to allow relay to
* Defaults to "\*" to allow relaying to all domains
* Setting both RELAY_FROM_HOSTS and RELAY_TO_DOMAINS to "\*" will make this an open relay
* Setting both RELAY_FROM_HOSTS and RELAY_TO_DOMAINS to other values will limit which clients can send and who they can send to

###### RELAY_TO_USERS

* A whitelist (colon separated) of recipient email addresses to allow relay to
* This list is processed in addition to the domains in RELAY_TO_DOMAINS
* Use this for more precise whitelisting of relayable mail
* Defaults to "" which doesn't whitelist any addresses

###### SMARTHOST

* A relay host to forward all non-local email through

###### SMTP_USERNAME

* The username for authentication to the smarthost

###### SMTP_PASSWORD

* The password for authentication to the smarthost - leave this blank to disable authenticaion

## Docker Secrets

The smarthost password can also be supplied via docker swarm secrets / rancher secrets.  Create a secret called SMTP_PASSWORD and don't use the SMTP_PASSWORD environment variable

## Persist Data

You may want to persist your mail queue

Just mount your desired path to /var/spool/exim

## Debugging

The logs are sent to /dev/stdout and /dev/stderr and can be viewed via docker logs

```shell
docker logs smtp
```

```shell
docker logs -f smtp
```

Exim commands can be run to check the status of the mail server as well

Print a count of the messages in the queue:

```shell
docker exec -it smtp exim -bpc
```

Print a listing of the messages in the queue (time queued, size, message-id, sender, recipient):

```shell
docker exec -it smtp exim -bp
```

Remove all frozen messages:

```shell
docker exec -it smtp exim -bpu | grep frozen | awk {'print $3'} | xargs docker exec -i smtp exim -Mrm
```

Test how exim will route a given address:

```shell
docker exec -it smtp exim -bt test@gmail.com
```

```
test@gmail.com
  router = dnslookup, transport = remote_smtp
  host gmail-smtp-in.l.google.com      [2a00:1450:400c:c0a::1b] MX=5
  host gmail-smtp-in.l.google.com      [64.233.167.27]          MX=5
  host alt1.gmail-smtp-in.l.google.com [2a00:1450:4010:c09::1b] MX=10
  host alt1.gmail-smtp-in.l.google.com [173.194.220.27]         MX=10
  host alt2.gmail-smtp-in.l.google.com [2404:6800:4003:c02::1a] MX=20
  host alt2.gmail-smtp-in.l.google.com [74.125.68.27]           MX=20
  host alt3.gmail-smtp-in.l.google.com [2404:6800:4008:c00::1a] MX=30
  host alt3.gmail-smtp-in.l.google.com [108.177.97.27]          MX=30
  host alt4.gmail-smtp-in.l.google.com [2607:f8b0:400e:c09::1a] MX=40
  host alt4.gmail-smtp-in.l.google.com [74.125.195.27]          MX=40
```

Display all of Exim's configuration settings:

```shell
docker exec -it smtp exim -bP
```

View a message's headers:

```shell
docker exec -it smtp exim -Mvh <message-id>
```

View a message's body:

```shell
docker exec -it smtp exim -Mvb <message-id>
```

View a message's logs:

```shell
docker exec -it smtp exim -Mar <message-id>
```

Remove a message from the queue:

```shell
docker exec -it smtp exim -Mrm <message-id> [ <message-id> ... ]
```
