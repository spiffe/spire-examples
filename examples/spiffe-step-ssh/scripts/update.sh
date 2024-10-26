#!/bin/bash

SPIFFE_STEP_SSH_INSTANCE="${SPIFFE_STEP_SSH_INSTANCE:=main}"

RUNDIR="/var/run/spiffe/step-ssh/${SPIFFE_STEP_SSH_INSTANCE}"

if [[ "${SPIFFE_TRUST_DOMAIN}" == "" ]]; then
	ENTRIES="$(openssl x509 -in $RUNDIR/spiffe-ca.pem -noout -ext subjectAltName | grep '[ ]*URI:spiffe://' | wc -l)"
	if [[ $ENTRIES -eq 1 ]]; then
		SPIFFE_TRUST_DOMAIN="$(openssl x509 -in $RUNDIR/spiffe-ca.pem -noout -ext subjectAltName | grep '[ ]*URI:spiffe://' | sed 's^[ ]*URI:spiffe://^^')"
	fi
fi

[[ "${SPIFFE_TRUST_DOMAIN}" == "" ]] && echo You must configure SPIFFE_TRUST_DOMAIN && exit

echo "TrustDomain: $SPIFFE_TRUST_DOMAIN"

# Setup Defaults
INSTANCE_SUFFIX="-${SPIFFE_STEP_SSH_INSTANCE}"
if [[ "${SPIFFE_STEP_SSH_INSTANCE}" == "main" ]]; then
	INSTANCE_SUFFIX=""
fi
SPIFFE_STEP_SSH_URL="${SPIFFE_STEP_SSH_URL:=https://spiffe-step-ssh${INSTANCE_SUFFIX}.${SPIFFE_TRUST_DOMAIN}}"
SPIFFE_STEP_SSH_FETCHCA_URL="${SPIFFE_STEP_SSH_FETCHCA_URL:=https://spiffe-step-ssh-fetchca${INSTANCE_SUFFIX}.${SPIFFE_TRUST_DOMAIN}}"

# FIXME If *_URL doesn't start with HTTPS://, add it to make things easier to use.

update-certs() {(
        # Get CA
        echo Fetching CA from "${SPIFFE_STEP_SSH_FETCHCA_URL}"
        curl -f -s "${SPIFFE_STEP_SSH_FETCHCA_URL}" --cacert "${RUNDIR}/spiffe-ca.pem" -o "${RUNDIR}/step-ca.pem" || exit 1
        s=$(wc -c "${RUNDIR}/step-ca.pem"  | awk '{print $1}')
        if [[ $s -eq 0 ]]; then
                echo Failed to get step-ca.
                exit 1
        fi

        # Generate keys if they dont exist
        [ ! -f "${RUNDIR}/ssh_host_rsa_key" ] && ssh-keygen -q -N "" -t rsa -b 4096 -f "${RUNDIR}/ssh_host_rsa_key"
        [ ! -f "${RUNDIR}/ssh_host_ecdsa_key" ] && ssh-keygen -q -N "" -t ecdsa -f "${RUNDIR}/ssh_host_ecdsa_key"
        [ ! -f "${RUNDIR}/ssh_host_ed25519_key" ] && ssh-keygen -q -N "" -t ed25519 -f "${RUNDIR}/ssh_host_ed25519_key"

        openssl ec -in "${RUNDIR}/tls.key" -outform PEM -out "${RUNDIR}/tls.pem" || exit 1

        CERTNAME="$(openssl x509 -in "${RUNDIR}/tls.crt" -noout -subject | sed 's/^.*CN = //' | sed 's/,.*//')"
        echo "CN: $CERTNAME"

        # Build signed certs
        step ssh certificate -root="${RUNDIR}/step-ca.pem" --ca-url="${SPIFFE_STEP_SSH_URL}" "$CERTNAME" "${RUNDIR}/ssh_host_rsa_key.pub" --host --sign --x5c-cert="${RUNDIR}/tls.crt" --x5c-key="${RUNDIR}/tls.pem" --force || exit 1
        step ssh certificate -root="${RUNDIR}/step-ca.pem" --ca-url="${SPIFFE_STEP_SSH_URL}" "$CERTNAME" "${RUNDIR}/ssh_host_ecdsa_key.pub" --host --sign --x5c-cert="${RUNDIR}/tls.crt" --x5c-key="${RUNDIR}/tls.pem" --force || exit 1
        step ssh certificate -root="${RUNDIR}/step-ca.pem" --ca-url="${SPIFFE_STEP_SSH_URL}" "$CERTNAME" "${RUNDIR}/ssh_host_ed25519_key.pub" --host --sign --x5c-cert="${RUNDIR}/tls.crt" --x5c-key="${RUNDIR}/tls.pem" --force || exit 1

        # Configure ssh if it isn't already
        mkdir -p /etc/ssh/sshd_config.d
	tmpfile=$(mktemp /etc/ssh/sshd_config.d/.spiffe-step-ssh.XXXXXX)
        cat > "$tmpfile" <<FEOF
HostKey ${RUNDIR}/ssh_host_rsa_key
HostKey ${RUNDIR}/ssh_host_ecdsa_key
HostKey ${RUNDIR}/ssh_host_ed25519_key
HostCertificate ${RUNDIR}/ssh_host_rsa_key-cert.pub
HostCertificate ${RUNDIR}/ssh_host_ecdsa_key-cert.pub
HostCertificate ${RUNDIR}/ssh_host_ed25519_key-cert.pub
FEOF
	mv "$tmpfile" /etc/ssh/sshd_config.d/50-spiffe-step-ssh.conf || exit 1
        grep 'Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config > /dev/null || echo 'Include /etc/ssh/sshd_config.d/*.conf' >> /etc/ssh/sshd_config

        chcon system_u:object_r:sshd_key_t:s0 "${RUNDIR}"/ssh_host* || true

        # Apply
        systemctl reload sshd
	)
	return $?
	}

while true; do
        update-certs && break
        sleep 1
done
