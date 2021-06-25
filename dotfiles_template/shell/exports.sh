# ------------------------------------------------------------------------------
# GENERAL INFORMATION ABOUT THIS FILE
# The variables here are loaded previously PATH is defined. Use full path if you
# need to do something like JAVA_HOME here or consider to add a init-script
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Sloth config
# ------------------------------------------------------------------------------
export SLOTH_AUTO_UPDATE_PERIOD_IN_DAYS=7
export SLOTH_AUTO_UPDATE_MODE="auto" # silent, auto, info, prompt
export SLOTH_UPDATE_VERSION="stable" # latest, stable, minor
export SLOTH_INIT_SCRIPTS=true # Init scripts enabled

# ------------------------------------------------------------------------------
# Codely theme config
# ------------------------------------------------------------------------------
export CODELY_THEME_MINIMAL=false
export CODELY_THEME_MODE="dark"
export CODELY_THEME_PROMPT_IN_NEW_LINE=false

# ------------------------------------------------------------------------------
# Languages
# ------------------------------------------------------------------------------
JAVA_HOME="$(/usr/libexec/java_home 2>&1 /dev/null)"
GEM_HOME="$HOME/.gem"
GOPATH="$HOME/.go"
export JAVA_HOME GEM_HOME GOPATH

# ------------------------------------------------------------------------------
# Apps
# ------------------------------------------------------------------------------
if [ "$CODELY_THEME_MODE" = "dark" ]; then
  fzf_colors="pointer:#ebdbb2,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#8ec07c,info:#928374,header:#fb4934"
else
  fzf_colors="pointer:#db0f35,bg+:#d6d6d6,fg:#808080,fg+:#363636,hl:#8ec07c,info:#928374,header:#fffee3"
fi

export FZF_DEFAULT_OPTS="--color=$fzf_colors --reverse"
