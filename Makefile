include .env

ifeq ($(PREFIX),)
PREFIX := /usr/local/
endif

.PHONY: deps
deps:
	@which -s envsubst || brew install gettext

.PHONY: install
install: deps .env bin/homelab
	@mkdir -p ${INSTALL_DIR}
	@cp -R .env bin cmd lib $(INSTALL_DIR)
	@chmod +x $(INSTALL_DIR)/bin/homelab

.PHONY: uninstall
uninstall:
	@rm -rf $(INSTALL_DIR)
