#!/usr/bin/env bash
set -e
ulimit -n 1024

cp /tmp/slapd.conf /etc/openldap/slapd.conf

slapd -h "ldap:/// ldapi:///" &

echo "Waiting for ldap to start"
while ldapsearch &> /dev/null || [ "$?" = "255" ]
do
	echo "Still waiting..."
	sleep 1
done

echo "LDAP is up and running"

SLAPD_PID="$(pgrep slapd)"

ldapadd -c -y /tmp/ldap_rootpwd -D "cn=Manager,dc=eyeos,dc=com" -H ldapi:// -f "/tmp/base.ldif"

kill -9 "$SLAPD_PID"

eyeos-service-ready-notify-cli &
eyeos-run-server --serf /tmp/ldap.sh
