#!/bin/bash
if [ ! -d /var/run/spiffe-step-ssh ]; then
	rm -f /etc/ssh/sshd_config.d/50-spiffe-step-ssh.conf
fi
