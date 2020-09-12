ifeq ($(PREFIX),)
PREFIX := /usr/local
endif

.PHONY: deps
deps:
	@which -s envsubst || brew install gettext

.PHONY: install
install: export ROOTDIR = $(DESTDIR)$(PREFIX)/opt/homelab
install: deps homelab
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@envsubst '$$ROOTDIR' < homelab > $(DESTDIR)$(PREFIX)/bin/homelab
	@chmod +x $(DESTDIR)$(PREFIX)/bin/homelab
	@mkdir -p $(ROOTDIR)
	@cp .env $(ROOTDIR)
	@cp -R cmd cfg $(ROOTDIR)

.PHONY: uninstall
uninstall: export ROOTDIR = $(DESTDIR)$(PREFIX)/opt/homelab
uninstall:
	@rm -rf $(ROOTDIR)
	@rm -f $(DESTDIR)$(PREFIX)/bin/homelab