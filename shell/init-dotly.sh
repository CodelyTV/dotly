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

# Brew add gnutools in macos only
if ! which brew | grep -q 'not found' && [[ "$(uname)" == "Darwin" ]]; then
  export paths=(
    "$(brew --prefix)/opt/coreutils/libexec/gnubin"
    "$(brew --prefix)/opt/findutils/libexec/gnubin"
    "${paths[@]}"
  )
fi

# Add openssl if it exists
[[ -d "/usr/local/opt/openssl/bin" ]] && path+=("/usr/local/opt/openssl/bin")

# Conditional paths
[[ -d "${JAVA_HOME:-}" ]] && path+=("$JAVA_HOME/bin")
[[ -d "${GEM_HOME:-}" ]] && path+=("$GEM_HOME/bin")
[[ -d "${GOHOME:-}" ]] && path+=("$GOHOME/bin")
[[ -d "$HOME/.deno/bin" ]] && path+=("$HOME/.deno/bin")
[[ -d "/usr/local/opt/ruby/bin" ]] && path+=("/usr/local/opt/ruby/bin")
[[ -d "/usr/local/opt/python/libexec/bin" ]] && path+=("/usr/local/opt/python/libexec/bin")
[[ -d "/usr/local/bin" ]] && path+=("/usr/local/sbin")
[[ -d "/usr/local/sbin" ]] && path+=("/usr/local/sbin")
[[ -d "/bin" ]] && path+=("/bin")
[[ -d "/usr/bin" ]] && path+=("/usr/bin")
[[ -d "/usr/sbin" ]] && path+=("/usr/sbin")
[[ -d "/sbin" ]] && path+=("/sbin")

# Load dotly core for your current BASH
# PR Note about this: $SHELL sometimes see zsh under certain circumstances in macOS
CURRENT_SHELL="unknown"
if [[ -n "${BASH_VERSION:-}" ]]; then
  CURRENT_SHELL="bash"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  CURRENT_SHELL="zsh"
fi

if [[ "$CURRENT_SHELL" != "unknown" && -f "$DOTLY_PATH/shell/${CURRENT_SHELL}/init.sh" ]]; then
  #shellcheck source=/dev/null
  . "$DOTLY_PATH/shell/${CURRENT_SHELL}/init.sh"
else
  echo -e "\033[0;31m\033[1mDOTLY Could not be loaded: Initializer not found for \`${CURRENT_SHELL}\`\033[0m"
fi

# Aliases
#shellcheck source=/dev/null
{ [[ -f "$DOTFILES_PATH/shell/aliases.sh" ]] && . "$DOTFILES_PATH/shell/aliases.sh"; } || true

# Functions
#shellcheck source=/dev/null
{ [[ -f "$DOTFILES_PATH/shell/functions.sh" ]] && . "$DOTFILES_PATH/shell/functions.sh"; } || true

#shellcheck source=/dev/null
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"


# Auto Init scripts at the end
init_scripts_path="$DOTFILES_PATH/shell/init-scripts.enabled"
if [[ ${DOTLY_INIT_SCRIPTS:-true} == true ]] && [[ -d "$init_scripts_path" ]]; then
  find "$DOTFILES_PATH/shell/init-scripts.enabled" -mindepth 1 -maxdepth 1 -type f,l -print0 2>/dev/null | xargs -0 -I _ realpath --quiet --logical _ | while read -r init_script; do
    [[ -z "$init_script" ]] && continue
    #shellcheck source=/dev/null
    { [[ -f "$init_script" ]] && . "$init_script"; } || echo -e "\033[0;31m$init_script could not be loaded\033[0m"
  done
fi
unset init_script init_scripts_path
