#shellcheck disable=SC2148
function cdd() {
  #shellcheck disable=SC2012
  cd "$(ls -d -- */ | fzf)" || echo "Invalid directory"
}

function j() {
  fname=$(declare -f -F _z)

  #shellcheck source=/dev/null
  [ -n "$fname" ] || . "$DOTLY_PATH/modules/z/z.sh"

  _z "$1"
}

function recent_dirs() {
  # This script depends on pushd. It works better with autopush enabled in ZSH
  escaped_home=$(echo "$HOME" | sed 's/\//\\\//g')
  selected=$(dirs -p | sort -u | fzf)

  # shellcheck disable=SC2001
  cd "$(echo "$selected" | sed "s/\~/$escaped_home/")" || echo "Invalid directory"
}

# Envs
# shellcheck source=/dev/null
[[ -f "$DOTFILES_PATH/shell/exports.sh" ]] && . "$DOTFILES_PATH/shell/exports.sh"

# Paths
# shellcheck source=/dev/null
[[ -f "$DOTFILES_PATH/shell/paths.sh" ]] && . "$DOTFILES_PATH/shell/paths.sh"

# Conditional path
[[ -d "${JAVA_HOME:-}" ]] && path+=("$JAVA_HOME")
[[ -d "${GEM_HOME:-}" ]] && path+=("$GEM_HOME")
[[ -d "${GOHOME:-}" ]] && path+=("$GOHOME")

# Load dotly core for your current BASH
if [[ -f "$DOTLY_PATH/shell/${SHELL##*/}/init.sh" ]]; then
  #shellcheck source=/dev/null
  . "$DOTLY_PATH/shell/${SHELL##*/}/init.sh"
else
  echo -e "\033[0;31m\033[1mDOTLY Could not be loaded\033[0m"
fi

# Aliases
#shellcheck source=/dev/null
{ [[ -f "$DOTFILES_PATH/shell/aliases.sh" ]] && . "$DOTFILES_PATH/shell/aliases.sh"; } || true

# Functions
#shellcheck source=/dev/null
{ [[ -f "$DOTFILES_PATH/shell/functions.sh" ]] && . "$DOTFILES_PATH/shell/functions.sh"; } || true

# Brew add gnutools in macos only
if ! which brew | grep -q 'not found' && [[ "$(uname)" == "Darwin" ]]; then
  PATH="$PATH:$(brew --prefix)/opt/coreutils/libexec/gnubin"
  PATH="$PATH:$(brew --prefix)/opt/findutils/libexec/gnubin"
fi

# Add openssl if it exists
[[ -d "/usr/local/opt/openssl/bin" ]] && PATH="$PATH:/usr/local/opt/openssl/bin"
export PATH

#shellcheck source=/dev/null
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Auto Init scripts at the end
if ${DOTLY_NO_INIT_SCRIPTS:-}; then
  init_scripts_path="$DOTFILES_PATH/shell/init-scripts.enabled"
  mkdir -p "$init_scripts_path"
  find "$DOTFILES_PATH/shell/init-scripts.enabled" -mindepth 1 -maxdepth 1 -type f,l -print0 -exec echo {} \; 2>/dev/null | xargs -I _ echo _ | while read -r init_script; do
    #shellcheck source=/dev/null
    init_script="$(realpath --logical "$init_script")"
    [[ -f "$init_script" ]] && . "$init_script" || echo -e "\033[0;31mInit Script: '$init_script' could not be loaded\033[0m"
  done
  unset init_script init_scripts_path
fi
