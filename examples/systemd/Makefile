default:
	@echo Targets:
	@echo "  install"

install:
	sudo cp system/* /usr/lib/systemd/system/
	sudo systemctl daemon-reload
	([ ! -f /etc/spire/agent/main.conf ] && sudo mkdir -p /etc/spire/agent && sudo cp -a conf/agent/main.conf /etc/spire/agent/main.conf) || true
	([ ! -f /etc/spire/agent/main.conf ] && sudo mkdir -p /etc/spire/server && sudo cp -a conf/server/main.conf /etc/spire/server/main.conf) || true
