#!/bin/bash

[ "x${SPIFFE_TRUST_DOMAIN}" == "x" ] && echo You must configure SPIFFE_TRUST_DOMAIN && exit

# Setup Defaults
SPIFFE_STEP_SSH_URL="${SPIFFE_SSH_URL:=https://spiffe-step-ssh.${SPIFFE_TRUST_DOMAIN}}"
SPIFFE_STEP_SSH_FETCHCA_URL="${SPIFFE_SSH_FETCHCA_URL:=https://spiffe-step-ssh-fetchca.${SPIFFE_TRUST_DOMAIN}}"

# Get CA
echo Fetching CA from "${SPIFFE_STEP_SSH_FETCHCA_URL}"
curl -s "${SPIFFE_STEP_SSH_FETCHCA_URL}" --cacert /var/run/spiffe-step-ssh/spiffe-ca.pem > /var/run/spiffe-step-ssh/step-ca.pem

# Generate keys if they dont exist
[ ! -f /var/run/spiffe-step-ssh/ssh_host_rsa_key ] && ssh-keygen -q -N "" -t rsa -b 4096 -f /var/run/spiffe-step-ssh/ssh_host_rsa_key
[ ! -f /var/run/spiffe-step-ssh/ssh_host_ecdsa_key ] && ssh-keygen -q -N "" -t ecdsa -f /var/run/spiffe-step-ssh/ssh_host_ecdsa_key
[ ! -f /var/run/spiffe-step-ssh/ssh_host_ed25519_key ] && ssh-keygen -q -N "" -t ed25519 -f /var/run/spiffe-step-ssh/ssh_host_ed25519_key

openssl ec -in /var/run/spiffe-step-ssh/tls.key -outform PEM -out /var/run/spiffe-step-ssh/tls.pem

CERTNAME="$(openssl x509 -in /var/run/spiffe-step-ssh/tls.crt -noout -subject | sed 's/^.*CN = //' | sed 's/,.*//')"
echo "CN: $CERTNAME"

# Build signed certs
step ssh certificate -root=/var/run/spiffe-step-ssh/step-ca.pem --ca-url="${SPIFFE_SSH_URL}" "$CERTNAME" /var/run/spiffe-step-ssh/ssh_host_rsa_key.pub --host --sign --x5c-cert=/var/run/spiffe-step-ssh/tls.crt --x5c-key=/var/run/spiffe-step-ssh/tls.pem --force
step ssh certificate -root=/var/run/spiffe-step-ssh/step-ca.pem --ca-url="${SPIFFE_SSH_URL}" "$CERTNAME" /var/run/spiffe-step-ssh/ssh_host_ecdsa_key.pub --host --sign --x5c-cert=/var/run/spiffe-step-ssh/tls.crt --x5c-key=/var/run/spiffe-step-ssh/tls.pem --force
step ssh certificate -root=/var/run/spiffe-step-ssh/step-ca.pem --ca-url="${SPIFFE_SSH_URL}" "$CERTNAME" /var/run/spiffe-step-ssh/ssh_host_ed25519_key.pub --host --sign --x5c-cert=/var/run/spiffe-step-ssh/tls.crt --x5c-key=/var/run/spiffe-step-ssh/tls.pem --force

# Configure ssh if it isn't already
mkdir -p /etc/ssh/sshd_config.d
[ ! -f /etc/ssh/sshd_config.d/50-spiffe-step-ssh.conf ] && cat > /etc/ssh/sshd_config.d/50-spiffe-step-ssh.conf <<FEOF
HostKey /var/run/spiffe-step-ssh/ssh_host_rsa_key
HostKey /var/run/spiffe-step-ssh/ssh_host_ecdsa_key
HostKey /var/run/spiffe-step-ssh/ssh_host_ed25519_key
HostCertificate /var/run/spiffe-step-ssh/ssh_host_rsa_key-cert.pub
HostCertificate /var/run/spiffe-step-ssh/ssh_host_ecdsa_key-cert.pub
HostCertificate /var/run/spiffe-step-ssh/ssh_host_ed25519_key-cert.pub
FEOF
grep 'Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config > /dev/null || echo 'Include /etc/ssh/sshd_config.d/*.conf' >> /etc/ssh/sshd_config

# Apply
systemctl reload sshd

