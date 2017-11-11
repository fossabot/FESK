.PHONY: install
install: all

all:
	@echo "Creating folder in /etc: "
	@mkdir /etc/fesk
	@mkdir /etc/fesk/custom
	@echo "Adding program to init.d: "
	@install -m 755 firewall /etc/init.d/firewall
	@echo "Copying configuration files"
	@cp etc/fesk/*.conf /etc/fesk
	@update-rc.d firewall defaults
	@echo "The program is successfully installed"

.PHONY: uninstall
uninstall:
	@rm -rf /etc/fesk
	@echo "Removed /etc/fesk"
	@rm -rf /etc/init.d/firewall
	@echo "Removed /etc/init.d/firewall"
	@update-rc.d firewall remove
	@echo "The program is successfully uninstalled"