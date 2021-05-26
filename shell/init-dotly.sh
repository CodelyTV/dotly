function cdd() {
  cd "$(ls -d -- */ | fzf)" || echo "Invalid directory"
}

function j() {
  fname=$(declare -f -F _z)

  [ -n "$fname" ] || . "$DOTLY_PATH/modules/z/z.sh"

  _z "$1"
}

function recent_dirs() {
  # This script depends on pushd. It works better with autopush enabled in ZSH
  escaped_home=$(echo "$HOME" | sed 's/\//\\\//g')
  selected=$(dirs -p | sort -u | fzf)

  cd "$(echo "$selected" | sed "s/\~/$escaped_home/")" || echo "Invalid directory"
}

# Envs
[[ -f "$DOTFILES_PATH/shell/exports.sh" ]] && . "$DOTFILES_PATH/shell/exports.sh"

# Paths
[[ -f "$DOTFILES_PATH/shell/paths.sh" ]] && . "$DOTFILES_PATH/shell/paths.sh"

# Conditional path
[[ -d "${JAVA_HOME:-}" ]] && path+=("$JAVA_HOME")
[[ -d "${GEM_HOME:-}" ]] && path+=("$GEM_HOME")
[[ -d "${GOHOME:-}" ]] && path+=("$GOHOME")

# Load dotly core for your current BASH
if [[ -f "$DOTLY_PATH/shell/${SHELL##*/}/init.sh" ]]; then
  . "$DOTLY_PATH/shell/${SHELL##*/}/init.sh"
else
  echo "\033[0;31m\033[1mDOTLY Could not be loaded\033[0m"
fi

# Brew add gnutools in macos only
if ! which brew | grep -q 'not found' && [[ "$(uname)" == "Darwin" ]]; then
  PATH="$PATH:$(brew --prefix)/opt/coreutils/libexec/gnubin"
  PATH="$PATH:$(brew --prefix)/opt/findutils/libexec/gnubin"
fi

# Add openssl if it exists
[[ -d "/usr/local/opt/openssl/bin" ]] && PATH="$PATH:/usr/local/opt/openssl/bin"
export PATH

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Auto Init scripts at the end
if [ -z "${DOTLY_NO_INIT_SCRIPTS:-false}" ]; then
  init_scripts_path="$DOTFILES_PATH/shell/init-scripts.enabled"
  mkdir -p "$init_scripts_path"
  find "$init_scripts_path" -mindepth 1 -maxdepth 1 -type l,f -name '*' | while read init_script; do
      [[ -e "$init_script" ]] && . "$init_script"
    done
fi
