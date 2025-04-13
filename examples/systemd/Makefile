default:
	@echo Targets:
	@echo "  install"

install:
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	mkdir -p $(DESTDIR)/usr/libexec/spire/server/
	install scripts/server/start.sh $(DESTDIR)/usr/libexec/spire/server/
	install system/* $(DESTDIR)/usr/lib/systemd/system/
	([ ! -f $(DESTDIR)/etc/spire/agent/default.conf ] && mkdir -p $(DESTDIR)/etc/spire/agent && install conf/agent/default.conf $(DESTDIR)/etc/spire/agent/default.conf) || true
	([ ! -f $(DESTDIR)/etc/spire/server/default.conf ] && mkdir -p $(DESTDIR)/etc/spire/server && install conf/server/default.conf $(DESTDIR)/etc/spire/server/default.conf) || true
	([ ! -f $(DESTDIR)/etc/spire/server/default.env ] && mkdir -p $(DESTDIR)/etc/spire/server && install conf/server/default.env $(DESTDIR)/etc/spire/server/default.env) || true
	([ ! -f $(DESTDIR)/etc/spiffe/default-trust-domain.env ] && mkdir -p $(DESTDIR)/etc/spiffe && install conf/spiffe/default-trust-domain.env $(DESTDIR)/etc/spiffe/default-trust-domain.env) || true
