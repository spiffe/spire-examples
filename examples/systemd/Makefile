default:
	@echo Targets:
	@echo "  install"

install:
	sudo cp system/* $(DESTDIR)/usr/lib/systemd/system/
	sudo systemctl daemon-reload
	([ ! -f $(DESTDIR)/etc/spire/agent/main.conf ] && sudo mkdir -p $(DESTDIR)etc/spire/agent && sudo cp -a conf/agent/main.conf $(DESTDIR)/etc/spire/agent/main.conf) || true
	([ ! -f $(DESTDIR)/etc/spire/agent/main.conf ] && sudo mkdir -p $(DESTDIR)etc/spire/server && sudo cp -a conf/server/main.conf $(DESTDIR)/etc/spire/server/main.conf) || true
