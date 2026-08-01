# Default target
default: install

# Set SLOTH Path as the directory of the Makefile
export INSTALL_PREFIX ?= "/usr/local"
export SLOTH_PATH ?=  $(CURDIR)
export DOTLY_PATH ?=  $(CURDIR)
export DOTFILES_PATH ?=  $(SLOTH_PATH)/dotfiles_template
export DOTLY_INSTALLER ?= true

all: init install loader link

.PHONY: init
init:
	@echo "Initilise .Sloth installation as repository..."
	@chmod u+x "./scripts/core/install"
	"./scripts/core/install" --only-git-init-sloth

.PHONY: standalone-install
standalone-install:
	@echo "Appling symlinks"
	@chmod u+x "$(SLOTH_PATH)/bin/dot"
	"$(SLOTH_PATH)/bin/dot" symlinks apply --backup --continue-on-error

	@echo "Appling loader"
	"$(SLOTH_PATH)/bin/dot" core loader bashrc --modify
	"$(SLOTH_PATH)/bin/dot" core loader zshrc --modify

.PHONY: install
install:
	@chmod u+x "$(SLOTH_PATH)/bin/dot"
	"$(SLOTH_PATH)/scripts/core/install" --backup --ignore-restoration --ignore-loader --link-prefix "$(INSTALL_PREFIX)"

.PHONY: create
create: install
	@echo "Install dotfiles in: \`${DOTFILES_PATH}\`"
	@chmod u+x "./scripts/dotfiles/create"
	"$(SLOTH_PATH)/scripts/dotfiles/create"

.PHONY: link
link: init
	@echo "Added link in /usr/local/bin for dot command"
	ln -s "$(SLOTH_PATH)/bin/dot" "$(INSTALL_PREFIX)/bin/dot"

.PHONY: unlink
unlink:
	@echo "Removed link in $(INSTALL_PREFIX)/bin for dot command"
	rm -f "$(INSTALL_PREFIX)/bin/dot"

.PHONY: loader
loader:
	@echo "Installing loader for .Sloth..."
	@chmod u+x "$(SLOTH_PATH)/bin/dot"
	"$(SLOTH_PATH)/bin/dot" core loader bashrc --modify
	"$(SLOTH_PATH)/bin/dot" core loader zshrc --modify

.PHONY: uninstall
uninstall:
	@echo "Uninstalling .Sloth"
	@echo "The following files will be deleted:"
	@for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv ~/.zimrc ~/.zlogin ~/.inputrc; do \
		[ -e "$$f" ] && echo "  - $$f" || true; \
	done
	@printf 'Type "yes" to confirm: '; \
	read -r answer; \
	if [ "$$answer" != "yes" ]; then echo "Aborted."; exit 1; fi
	@for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv ~/.zimrc ~/.zlogin ~/.inputrc; do \
		[ -e "$$f" ] && rm -r "$$f"; \
	done
	@echo "Uninstall complete."

.PHONY: format
format:
	@shfmt -w -ln bash -sr -ci -i 2 ./scripts ./bin ./shell ./dotfiles_template _raycast 2>/dev/null || \
		(echo "ERROR: shfmt not found. Install with:" >&2 && \
		 echo "  macOS: brew install shfmt" >&2 && \
		 echo "  Ubuntu: sudo apt-get install shfmt" >&2 && exit 1)

.PHONY: lint
lint:
	@bash scripts/self/lint

.PHONY: pre-commit-install
pre-commit-install:
	@command -v pre-commit &>/dev/null || (echo "ERROR: pre-commit not found. Install with:" >&2 && \
		echo "  pip install pre-commit" >&2 && exit 1)
	@pre-commit install
	@echo "pre-commit hooks installed"

.PHONY: pre-commit-pre-push
pre-commit-pre-push:
	@command -v pre-commit &>/dev/null || (echo "ERROR: pre-commit not found. Install with:" >&2 && \
		echo "  pip install pre-commit" >&2 && exit 1)
	@pre-commit run --all-files

.PHONY: test
test:
	@command -v bats &>/dev/null || (echo "ERROR: bats-core not found. Install with:" >&2 && echo "  macOS: brew install bats-core" >&2 && echo "  Ubuntu: sudo apt-get install bats" >&2 && exit 1)
	bats --recursive tests/
