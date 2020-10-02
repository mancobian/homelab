ifeq ($(PREFIX),)
PREFIX := /usr/local
endif

ifeq ($(CONFIG_DIR),)
CONFIG_DIR := ~/.config/homelab
endif

.PHONY: deps
deps:
	@which -s envsubst || brew install gettext

.PHONY: install
install: export ROOTDIR = $(DESTDIR)$(PREFIX)/opt/homelab
install: deps homelab
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@envsubst '$$ROOTDIR,$$CI_PUBLIC_KEY,$$CI_PRIVATE_KEY' < homelab > $(DESTDIR)$(PREFIX)/bin/homelab
	@chmod +x $(DESTDIR)$(PREFIX)/bin/homelab
	@mkdir -p $(ROOTDIR)
	@cp .env $(ROOTDIR)
	@cp -R cmd lib $(ROOTDIR)
	@rm -rf ${CONFIG_DIR}
	@ln -s ${PWD}/cfg ${CONFIG_DIR}

.PHONY: uninstall
uninstall: export ROOTDIR = $(DESTDIR)$(PREFIX)/opt/homelab
uninstall:
	@rm -f $(DESTDIR)$(PREFIX)/bin/homelab
	@rm -rf $(ROOTDIR)
	@unlink ${CONFIG_DIR}