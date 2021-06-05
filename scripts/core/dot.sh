dot::list_contexts() {
  dotly_contexts=$(ls "$DOTLY_PATH/scripts")
  dotfiles_contexts=$(ls "$DOTFILES_PATH/scripts")

  echo "$dotly_contexts" "$dotfiles_contexts" | grep -v core | sort -u
}

dot::list_context_scripts() {
  context="$1"

  dotly_scripts=$(ls -p "$DOTLY_PATH/scripts/$context" 2>/dev/null | grep -v '/')
  dotfiles_scripts=$(ls -p "$DOTFILES_PATH/scripts/$context" 2>/dev/null | grep -v '/')

  echo "$dotly_scripts" "$dotfiles_scripts" | sort -u
}

dot::list_scripts() {
  _list_scripts() {
    scripts=$(dot::list_context_scripts "$1" | xargs -I_ echo "dot $1 _")

    echo "$scripts"
  }

  dot::list_contexts | coll::map _list_scripts
}

dot::list_scripts_path() {
  dotly_contexts=$(find "$DOTLY_PATH/scripts" -maxdepth 2 -perm /+111 -type f | grep -v "$DOTLY_PATH/scripts/core")
  dotfiles_contexts=$(find "$DOTFILES_PATH/scripts" -maxdepth 2 -perm /+111 -type f)

  printf "%s\n%s" "$dotly_contexts" "$dotfiles_contexts" | sort -u
}
