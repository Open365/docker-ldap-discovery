#!/usr/bin/env bash
slapd -d $LDAP_LOG_LEVEL -h 'ldap:/// ldapi:///'
