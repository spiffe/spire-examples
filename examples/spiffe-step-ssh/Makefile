default:
	@echo Targets:
	@echo "  install"

install:
	mkdir -p $(DESTDIR)/etc/systemd/system
	mkdir -p $(DESTDIR)/usr/libexec/spiffe-step-ssh
	install conf/spiffe-step-ssh.conf $(DESTDIR)/etc
	install conf/helper.conf $(DESTDIR)/usr/libexec/spiffe-step-ssh
	install scripts/update.sh  $(DESTDIR)/usr/libexec/spiffe-step-ssh
	install systemd/spiffe-step-ssh.service $(DESTDIR)/etc/systemd/system
