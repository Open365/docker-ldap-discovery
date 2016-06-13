FROM docker-registry.eyeosbcn.com/alpine6-node-base
MAINTAINER eyeos

ENV WHATAMI ldap
ENV LDAP_LOG_LEVEL 0

COPY files/base.ldif /tmp/
COPY files/ldap_rootpwd /tmp/
COPY start.sh /tmp/
COPY ldap.sh /tmp/
COPY files/slapd.conf /tmp/

RUN apk update && \
    /scripts-base/installExtraBuild.sh && \
    apk add --no-cache openldap openldap-clients openldap-back-monitor && \
    npm install -g --verbose eyeos-run-server eyeos-tags-to-dns eyeos-service-ready-notify-cli && \
    curl -L https://releases.hashicorp.com/serf/0.6.4/serf_0.6.4_linux_amd64.zip -o serf.zip && unzip serf.zip && mv serf /usr/bin/ && \
    chmod +x /tmp/start.sh && \
    chmod +x /tmp/ldap.sh && \
    chmod 600 /tmp/ldap_rootpwd

CMD /tmp/start.sh

VOLUME /var/lib/ldap

EXPOSE 389
