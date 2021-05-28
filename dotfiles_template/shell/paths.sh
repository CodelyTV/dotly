# ------------------------------------------------------------------------------
# Path - The higher it is, the more priority it has
# ------------------------------------------------------------------------------
# JAVA_HOME, GEM_HOME and GOHOME now are loaded in init-dotly.sh
export path=(
  "$HOME/bin"
  "$DOTLY_PATH/bin"
  "$DOTFILES_PATH/bin"
  "$HOME/.cargo/bin"
  "/usr/local/opt/ruby/bin"
  "/usr/local/opt/python/libexec/bin"
  "/opt/homebrew/bin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/bin"
  "/usr/bin"
  "/usr/sbin"
  "/sbin"
)
