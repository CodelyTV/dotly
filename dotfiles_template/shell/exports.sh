# ------------------------------------------------------------------------------
# Dotly config
# ------------------------------------------------------------------------------
export DOTLY_AUTO_UPDATE_PERIOD_IN_DAYS=7
export DOTLY_AUTO_UPDATE_MODE="auto" # silent, auto, info, prompt
export DOTLY_UPDATE_VERSION="stable" # latest, stable, minor

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
export FZF_DEFAULT_OPTS='
  --color=pointer:#ebdbb2,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#8ec07c,info:#928374,header:#fb4934
  --reverse
'
