#!/usr/bin/env bash
set -e
ulimit -n 1024

ERR_ENTRY_ALREADY_EXISTS=68
add_ldif() {
	local file="$1"
	local errcode
	echo "adding contents of $file"
	if /bin/ldapadd -c -y /tmp/ldap_rootpwd -D "cn=Manager,dc=eyeos,dc=com" -Y EXTERNAL -H ldapi:// -f "$file"
	then
		# we only need to do something when ldapadd fails, but using 'if ! ldapadd ...' would set
		# $? to 0, which is useless to us. So we leave the ldapadd normally, do nothing if it
		# succeeds and if it fails we check if the error code is the expected one in case of
		# duplicated entries or it is another unexpected one, we fail
		echo "$file: Added successfully"
	else
		errcode="$?"
		if [ "$errcode" = "$ERR_ENTRY_ALREADY_EXISTS" ]
		then
			echo "$file: got duplicated entries, but continuing anyway..."
		else
			echo "$file: Failed with errcode $errcode"
			exit "$errcode"
		fi
	fi
}

slapd -h "ldap:/// ldapi:///" &

echo "Waiting for ldap to start"
while ldapsearch &> /dev/null || [ "$?" = "255" ]
do
	echo "Still waiting..."
	sleep 1
done

echo "LDAP is up and running"

SLAPD_PID="$(pgrep slapd)"

# the schema ldif files cannot be added twice, so check if they are already
# added chekcing in the slapd.d folder
for file in \
	/etc/openldap/schema/cosine.ldif \
	/etc/openldap/schema/nis.ldif \
	/etc/openldap/schema/inetorgperson.ldif
do
	filename="$(basename "$file")"
	if [ -e '/etc/openldap/slapd.d/cn=config/cn=schema/'*"$filename" ]
	then
		echo "$file already introduced to the database. Skipping"
	else
		add_ldif "$file"
	fi
done

add_ldif /tmp/base.ldif
ps axuf
kill -9 "$SLAPD_PID"
eyeos-service-ready-notify-cli &
eyeos-run-server --serf /tmp/ldap.sh
