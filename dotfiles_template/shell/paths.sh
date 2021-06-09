# ------------------------------------------------------------------------------
# Path - The higher it is, the more priority it has
# ------------------------------------------------------------------------------
# JAVA_HOME, GEM_HOME, GOHOME, deno($HOME/.deno/bin), cargo are now loaded
# in init-dotly.sh
# Mandatory paths: /usr/local/{bin,sbin}, /bin, /usr/{bin,sbin} /sbin
# are also loaded in init-dotly
# paths defined here are loaded first
#
export path=(
  "$HOME/bin"
  "$DOTLY_PATH/bin"
  "$DOTFILES_PATH/bin"
)
