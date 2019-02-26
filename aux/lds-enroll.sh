#!/bin/bash
sys_TYTLE=$(hostname -f)

#apt-get update && apt-get install landscape-client

#sudo cat <<EOF >>/etc/hosts
#10.0.0.12 lds.corp.braincraft.io lds
#EOF

#cat <<EOF >~/lds.pem
#-----BEGIN CERTIFICATE-----
#MIIBuTCCASKgAwIBAgIJAPOvIv6j1HWGMA0GCSqGSIb3DQEBCwUAMA4xDDAKBgNV
#BAMMA2xkczAeFw0xODEyMTcxNzM5MDNaFw0yODEyMTQxNzM5MDNaMA4xDDAKBgNV
#BAMMA2xkczCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAyNqdmrlECzbDxwfx
#UZDMWdQxHPTVCTefYM7A/WP13R6bgdMhEs5YfTz6HXq/oe72HjN9AknJFkTkDuBK
#Qn4qQr22R5fHDXtlDuzsZVPtfYOEC65JmAb9ouTdWHAyl8SNEwiAnU02kRBI9J+N
#v3rlHiGdcR4GzWKxUM1UVqq05tsCAwEAAaMfMB0wGwYDVR0RBBQwEoIDbGRzggsx
#OTIuMTY4LjIuNDANBgkqhkiG9w0BAQsFAAOBgQCPMmUyu4kdW+IRoXbyk+SxaJVu
#mUUSt5G3IDir8b3suFoQBDyvjWotA8K9IsXpApkL6iVP/Tq6WNxlVnjrZ1fPZGdQ
#Qq8REgsVcdntvzM2UoKoVezqABzD8D3mF0ScVoNNSnlJIHk1+OhYoGYaQ7fsKZYy
#yDGkCtqoNK+ylIAvPg==
#-----END CERTIFICATE-----
#EOF
echo "" >/etc/landscape/client.conf

sudo landscape-config \
        --quiet --silent \
        --script-users=ALL \
	--account-name standalone \
	--computer-title ${sys_TYTLE} \
 	--ssl-public-key /etc/landscape/lds.pem \
	--registration-key="ldsautoregister" \
	--ping-url https://lds.braincraft.io/ping \
	--url https://lds.braincraft.io/message-system

#  --log-level=LOG_LEVEL # debug info warning error critical
#  -a NAME, --account-name=NAME
#  -p KEY, --registration-key=KEY
#  --tags=TAGS           Comma separated list of tag names to be sent to the server.
#  --import=FILENAME_OR_URL
#  --script-users=USERS  A comma-separated list of users to allow scripts to
