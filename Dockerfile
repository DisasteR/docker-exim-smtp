FROM alpine:3.8

ARG VERSION=4.91-r1

ENV LOCAL_DOMAINS=@ \
    RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 \
    RELAY_TO_DOMAINS=* \
    RELAY_TO_USERS= \
    SMARTHOST= \
    SMTP_PASSWORD= \
    SMTP_USERDOMAIN= \
    SMTP_USERNAME= \
    SMTP_PLAINAUTH_USERNAME= \
    SMTP_PLAINAUTH_USERNAME=

RUN apk --no-cache add exim=$VERSION libcap && \
    mkdir -p /var/log/exim /usr/lib/exim /var/spool/exim && \
    ln -s /dev/stdout /var/log/exim/mainlog && \
    ln -s /dev/stderr /var/log/exim/paniclog && \
    ln -s /dev/stderr /var/log/exim/rejectlog && \
    chown -R exim: /var/log/exim /usr/lib/exim /var/spool/exim && \
    chmod 0755 /usr/sbin/exim && \
    setcap cap_net_bind_service=+ep /usr/sbin/exim && \
    apk del libcap

COPY exim.conf /etc/exim/exim.conf
COPY entrypoint.sh /entrypoint.sh

USER exim
EXPOSE 25

VOLUME  ["/var/spool/exim"]

ENTRYPOINT  ["/entrypoint.sh"]
CMD ["exim", "-bdf", "-q15m"]
