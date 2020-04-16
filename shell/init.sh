ulimit -n 200000
ulimit -u 2048

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Register all aliases
for aliasToSource in "$DOTFILES_PATH/shell/_aliases/"*; do source "$aliasToSource"; done
# Register all exports
for exportToSource in "$DOTFILES_PATH/shell/_exports/"*; do source "$exportToSource"; done
# Register all functions
for functionToSource in "$DOTFILES_PATH/shell/_functions/"*; do source "$functionToSource"; done
