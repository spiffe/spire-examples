default:
	@echo Targets:
	@echo "  install"

install:
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	cp system/* $(DESTDIR)/usr/lib/systemd/system/
	([ ! -f $(DESTDIR)/etc/spire/agent/main.conf ] && mkdir -p $(DESTDIR)/etc/spire/agent && cp -a conf/agent/main.conf $(DESTDIR)/etc/spire/agent/main.conf) || true
	([ ! -f $(DESTDIR)/etc/spire/server/main.conf ] && mkdir -p $(DESTDIR)/etc/spire/server && cp -a conf/server/main.conf $(DESTDIR)/etc/spire/server/main.conf) || true
