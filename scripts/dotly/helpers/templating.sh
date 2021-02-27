# This is a renamed copy of dotfiles::apply_templating
# from Rafa Gomez original dotly creator
dotly::apply_templating() {
  local script_filepath="$1"
  local script_context="$2"
  local script_author="$3"
  local script_email="$4"
  local script_description="${@:5}"
  
  sed -i -e "s|XXX_SCRIPT_DESCRIPTION_XXX|$script_description|g" "$script_filepath"
  sed -i -e "s|XXX_SCRIPT_AUTHOR_EMAIL_XXX|$script_email|g" "$script_filepath"
  sed -i -e "s|XXX_SCRIPT_AUTHOR_XXX|$script_author|g" "$script_filepath"
  sed -i -e "s|XXX_SCRIPT_NAME_XXX|$(basename $script_filepath)|g" "$script_filepath"
  sed -i -e "s|XXX_SCRIPT_CONTEXT_XXX|$script_context|g" "$script_filepath"
}