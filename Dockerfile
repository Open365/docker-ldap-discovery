FROM docker-registry.eyeosbcn.com/eyeos-fedora21-node-base:latest
MAINTAINER eyeos

ENV WHATAMI ldap
ENV LDAP_LOG_LEVEL 0

COPY files/monitor /tmp/
COPY files/hdb /tmp/
COPY files/base.ldif /tmp/
COPY files/ldap_rootpwd /tmp/
COPY start.sh /tmp/
COPY ldap.sh /tmp/
COPY files/bind_v2.ldif /tmp/

RUN yum install -y openldap-servers openldap-clients hostname unzip
RUN mkdir -p /var/run/slapd && touch /var/run/slapd/slapd.pid && \
    npm install -g eyeos-run-server eyeos-tags-to-dns eyeos-service-ready-notify-cli && \
    curl -L https://releases.hashicorp.com/serf/0.6.4/serf_0.6.4_linux_amd64.zip -o serf.zip && unzip serf.zip && mv serf /usr/bin/ && \
    chmod +x /tmp/start.sh && \
    chmod +x /tmp/ldap.sh && \
    chmod 600 /tmp/ldap_rootpwd && \
    /bin/cp /tmp/monitor /etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif && \
    /bin/cp /tmp/hdb /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif && \
    /bin/cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG;chown -Rf ldap:ldap /var/lib/ldap/ && \
    /usr/libexec/openldap/check-config.sh 

CMD /tmp/start.sh

VOLUME /var/lib/ldap

EXPOSE 389
