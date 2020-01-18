SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: test
test: shellcheck ## Runs all the tests


.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	@bash ./tests/test-shell-scripts.sh

.PHONY: install
install: ## Installs default profile (bash, git, configs)
	@bash ./install.sh -i -x

.PHONY: test-install
test-install: ## Installs default profile (bash, git, configs)
	@bash ./install.sh -i -x -T

.PHONY: verify
verify: ## Verifies checksums and its signature
	@bash checksum.sh -v

.PHONY: verify-integrity
verify-integrity: ## Verifies checksums
	@bash checksum.sh -v -G

.PHONY: signature
signature: ## sing
	@bash checksum.sh -c -s -v

.PHONY: help
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
    printf "%-30s %s\n" "--------" "------------" ; \
	printf "%-30s %s\n" " Target " "    Help " ; \
    printf "%-30s %s\n" "--------" "------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[92m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

.PHONY: install-tools
install-tools: ## Installs extra tools used by dotfiles (starship-rs and direnv)
	@echo -e "\033[1;92m➜ $@ \033[0m"
	@echo -e "\033[34m‣ downloading starship-prompt\033[0m"
	@mkdir -p vendor
	@chmod 700 vendor
	@echo -e "\033[33m  - download binary\033[0m"
	@curl -sL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz --output vendor/starship.tar.gz
	@echo -e "\033[33m  - download checksum\033[0m"
	@curl -sL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz.sha256 --output vendor/starship.tar.gz.sha256
	@echo -e "\033[33m  - verify checksum\033[0m"
	@echo "$$(cat vendor/starship.tar.gz.sha256) vendor/starship.tar.gz" | sha256sum --quiet -c -
	@echo -e "\033[33m  - install\033[0m"
	@mkdir -p $(INSTALL_PREFIX)/bin
	@tar xzf vendor/starship.tar.gz -C $(INSTALL_PREFIX)/bin

	@echo -e "\033[34m‣ downloading direnv\033[0m"
	@echo -e "\033[33m  - download & install binary\033[0m"
	@mkdir -p $(INSTALL_PREFIX)/bin
	@curl -sL https://github.com/direnv/direnv/releases/download/v2.20.0/direnv.linux-amd64 -o $(INSTALL_PREFIX)/bin/direnv

	@echo -e "\033[34m‣ set permissions\033[0m"
	@echo -e "\033[33m  - on bin\033[0m"
	@chmod 700 $(INSTALL_PREFIX)/bin
	@echo -e "\033[33m  - on direnv\033[0m"
	@chmod 700 $(INSTALL_PREFIX)/bin/direnv
	@echo -e "\033[33m  - on starship\033[0m"
	@chmod 700 $(INSTALL_PREFIX)/bin/starship

.PHONY: clean-downloads
clean-downloads: ## cleanup old downloads
	@rm -f vendor/*.*
