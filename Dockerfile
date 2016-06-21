FROM docker-registry.eyeosbcn.com/alpine6-node-base
MAINTAINER eyeos

ENV WHATAMI ldap
ENV LDAP_LOG_LEVEL 0

COPY alpine-*.list files/base.ldif files/ldap_rootpwd start.sh ldap.sh /var/service/
COPY files/slapd.conf /etc/openldap/slapd.conf

RUN /scripts-base/buildDependencies.sh --production --install && \
    npm install -g --verbose eyeos-service-ready-notify-cli && \
    npm cache clean && \
    curl -L https://releases.hashicorp.com/serf/0.6.4/serf_0.6.4_linux_amd64.zip -o serf.zip && unzip serf.zip && mv serf /usr/bin/ && \
    /scripts-base/buildDependencies.sh --production --purgue

CMD /var/service/start.sh

VOLUME /var/lib/ldap

EXPOSE 389

