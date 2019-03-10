#!/bin/sh

set -e

dockerize \
	-wait file:///kopano/ssl/meet-kwmserver.pem \
	-timeout 360s
cd /kopano/ssl/
konnectd utils jwk-from-pem --use sig /kopano/ssl/meet-kwmserver.pem > /tmp/meet.ywk
CONFIG_JSON=/etc/kopano/konnectd-identifier-registration.yaml
yq -y '.clients += [{"id": "meet", "name": "Kopano Meet", "application_type": "web", "trusted": true, "redirect_uris": ["https://\"$FQDN\"/meet/"], "trusted_scopes": ["konnect/guestok", "kopano/kwm"], "jwks": {"keys": []},"request_object_signing_alg": "ES256"}]' \
$CONFIG_JSON > $CONFIG_JSON.tmp
mv $CONFIG_JSON.tmp $CONFIG_JSON
cat $CONFIG_JSON
# TODO replace above with sponge once base image is updated to alpine 3.9
# TODO add actual keys from /tmp/meet.ywk

dockerize \
	-wait file:///kopano/ssl/konnectd-tokens-signing-key.pem \
	-wait file:///kopano/ssl/konnectd-encryption.key \
	-timeout 360s \
	konnectd serve \
	--signing-private-key=/kopano/ssl/konnectd-tokens-signing-key.pem \
	--encryption-secret=/kopano/ssl/konnectd-encryption.key \
	--iss=https://"$FQDN" \
	--identifier-registration-conf /etc/kopano/konnectd-identifier-registration.yaml \
	--identifier-scopes-conf /etc/kopano/konnectd-identifier-scopes.yaml \
	kc
