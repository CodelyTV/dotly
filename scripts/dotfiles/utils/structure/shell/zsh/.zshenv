#
# User configuration sourced by all invocations of the shell
#

# Define Zim location
: ${ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim}

for exportToSource in "$DOTFILES_PATH/shell/_exports/"*; do source "$exportToSource"; done

