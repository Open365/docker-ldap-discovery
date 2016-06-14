FROM docker-registry.eyeosbcn.com/alpine6-node-base
MAINTAINER eyeos

ENV WHATAMI ldap
ENV LDAP_LOG_LEVEL 0

COPY alpine-*.list /var/service/
COPY files/base.ldif files/ldap_rootpwd start.sh ldap.sh files/slapd.conf /tmp/

RUN /scripts-base/buildDependencies.sh --production --install && \
    npm install -g --verbose eyeos-run-server eyeos-tags-to-dns eyeos-service-ready-notify-cli && \
    curl -L https://releases.hashicorp.com/serf/0.6.4/serf_0.6.4_linux_amd64.zip -o serf.zip && unzip serf.zip && mv serf /usr/bin/ && \
    chmod +x /tmp/start.sh && \
    chmod +x /tmp/ldap.sh && \
    chmod 600 /tmp/ldap_rootpwd && \
    /scripts-base/buildDependencies.sh --production --purgue

CMD /tmp/start.sh

VOLUME /var/lib/ldap

EXPOSE 389
