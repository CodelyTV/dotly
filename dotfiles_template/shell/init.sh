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
    "$DOTFILES_PATH/shell/aliases.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/aliases.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/aliases.sh"
    "$DOTFILES_PATH/shell/machines/$(hostname)/aliases.sh"

    "$DOTFILES_PATH/shell/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/exports.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/exports.sh"
    "$DOTFILES_PATH/shell/machines/$(hostname)/exports.sh"

    "$DOTFILES_PATH/shell/functions.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/functions.sh"
    "$DOTFILES_PATH/shell/$MYSHELL/$OSNAME/functions.sh"
    "$DOTFILES_PATH/shell/machines/$(hostname)/functions.sh"
)


for source_file in ${source_files[@]}; do
    [ -f "$source_file" ] && source "$source_file"
done