# This is a useful file to have the same aliases/functions in bash and zsh
# Order to init:
#       1 Common
#       2 SHELL
#       3 OS
#       5 Machine
# Firstly will be loaded the aliases in that order, later exports and finally
#   the functions.

MYSHELL=${SHELL##*/}
OSNAME="other"

case "$OSTYPE" in
    linux*)
        OSNAME="linux"
        ;;
    darwin*)
        OSNAME="macos"
        ;;
esac

source_files=(
    "$DOTFILES_PATH/shell/common/aliases.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/aliases.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/aliases.sh"
    "$DOTFILES_PATH/shell/machines/$(hostname)/aliases.sh"

    "$DOTFILES_PATH/shell/common/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/exports.sh"
    "$DOTFILES_PATH/shell/machines/$(hostname)/exports.sh"

    "$DOTFILES_PATH/shell/common/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/exports.sh"
    "$DOTFILES_PATH/dotfiles_template/shell/machines/$(hostname)/exports.sh"
)


for source_file in ${source_files[@]}; do
    [ -f "$source_file" ] && source "$source_file"
done