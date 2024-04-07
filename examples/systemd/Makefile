default:
	@echo Targets:
	@echo "  install"

install:
	sudo cp system/* /usr/lib/systemd/system/
	sudo systemctl daemon-reload
	#cp -a /etc/spire/agent/main.conf agent/
