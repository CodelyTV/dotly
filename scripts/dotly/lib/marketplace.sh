#!/usr/bin/env bash

. "$DOTLY_PATH/scripts/core/github.sh"

# Constants
readonly DOTFILES_SCRIPTS_PATH="$DOTFILES_PATH/scripts"

# Variables
MARKETPLACE_REPOSITORY="${MARKETPLACE_REPOSITORY:-rgomezcasas/dotfiles}"
MARKETPLACE_MAX_CACHE_PERIOD_IN_DAYS="${MARKETPLACE_MAX_CACHE_DAYS:-7}"
MARKETPLACE_CACHE_PATH="${MARKETPLACE_CACHE_PATH:-$DOTFILES_PATH/.marketplace-cache}"

# Clean cache to search
marketplace::clean_cache() {
  github::clean_cache
  rm -rf "$MARKETPLACE_CACHE_PATH"
}

# Get rigth cache path to scripts
marketplace::get_scripts_cache_path() {
  local sha
  sha="$(github::curl "$(marketplace::get_url tree)" | jq -r '.tree[] | select(.type == "tree") | select(.path == "scripts") | .sha')"
  [[ -z "$sha" ]] && sha="$(marketplace::get_url tree master sha)" || sha="$sha/scripts"
  echo "$MARKETPLACE_CACHE_PATH/$sha"
}

# Get url to request api urls or raw files
marketplace::get_url() {
  case "$1" in
    raw)
      shift
      github::branch_raw_url -b "master" "$MARKETPLACE_REPOSITORY" "$*"
      ;;
    tree)
      branch="${2:-master}"
      param="${3:-url}"
      github::get_api_url -b "$branch" "$MARKETPLACE_REPOSITORY" | github::curl | jq -r ".commit.commit.tree.$param"
    ;;
    branch|branches)
      branch="${2:master}"
      github::get_api_url -b "$branch" "$MARKETPLACE_REPOSITORY"
      ;;
    *)
      branch="${1:master}"
      github::get_api_url -b "$branch" "$MARKETPLACE_REPOSITORY"
    ;;
  esac
}

# The date of last commit on specific branch (master as default one)
marketplace::get_commit_date() {
  local branch
  branch="${1:-master}"

  date -d "$(marketplace::get_url branch "$branch" | github::curl | jq -r '.commit.commit.committer.date')" +%s
}

# Compare numbers as semver style
marketplace::compare_numbers() {
  if [[ $1 < $2 ]]; then
    echo -1
  elif [[ $1 > $2 ]]; then
    echo 1
  else
    echo 0
  fi
}

# Check if there is a newer commit of the configured GITHUB repository
marketplace::check_newer_version() {
  local cache_folder github_date cache_folder_date branch
  cache_folder="${1:-$(marketplace::get_scripts_cache_path)}"
  branch="$2"
  github_date="$(marketplace::get_commit_date "$branch")" # Maybe you want to check a different branch
  cache_folder_date="$(date -r "$cache_folder" +%s)"

  [[ "$(marketplace::compare_numbers "$github_date" "$cache_folder_date")" -gt -1 ]]
}

# Check if cache folder should be recreated
marketplace::check_cache_folder_should_be_created() {
  local cache_path
  cache_path="${1:-$(marketplace::get_scripts_cache_path)}"
  [[ -d "$cache_path" ]] &&\
    { files::check_if_path_is_older "$cache_path" "$MARKETPLACE_MAX_CACHE_DAYS" &&\
    marketplace::check_newer_version "$cache_path"; } ||\
    [[ ! -d "$cache_path" ]]
}

# Create recursively the cache tree
marketplace::recursive_tree() {
  local url cache_folder
  url="$1"
  cache_folder="$2"

  output::answer "Downloading $(basename "$2")"

  # Check if current cache folder shouldn't be recreated
  # if it should not just exit the function
  ! marketplace::check_cache_folder_should_be_created "$cache_folder"&& return
  
  # Recreating cache folder
  rm -rf "$cache_folder" && mkdir -p "$cache_folder"

  github::curl $url | \
    jq -c '.tree | map({ path: .path, type: .type, url:.url }) | .[]' |\
    while read item; do
      item_path="$(echo "$item" | jq -r '.path')"
      item_is_folder="$(echo "$item" | jq '. | select(.type == "tree")')"
      item_url="$(echo "$item" | jq -r '.url')"

      [[ -z "$item_path" ]] || [[ -z "$item_url" ]] && continue

      if [[ -n "$item_is_folder" ]]; then
        marketplace::recursive_tree "$item_url" "$cache_folder/$item_path"
      else
        echo "#!/usr/bin/env bash" > "$cache_folder/$item_path"
        echo "script_download_url='$item_url'" >> "$cache_folder/$item_path"
        echo "relative_script_folder_path='${cache_folder#$(marketplace::get_scripts_cache_path)/}'" >> "$cache_folder/$item_path"
      fi
    done
}

# Helper to list all scripts that will be installed when installing a context
marketplace::print_tab_find() {
  local find_path
  find_path="$1"

  find "$find_path" -mindepth 1 -maxdepth 1 -type f -name '*' | while read item; do
    item="$(echo "${item#$find_path/}" | xargs)"
    printf "\t* %s\n" "$item"
  done
}

# Create the cache tree (only if neccessary no previous checks needed)
marketplace::create_cache_tree() {
  local url cache_folder
  url="${1:-$(marketplace::get_url tree)}"
  cache_folder="${2:-$(marketplace::get_scripts_cache_path)}"

  # Inform user that we are getting the scripts cache
  output::header "Downloading a scripts database to create a cache"

  # Check if we have url and cache directory
  { [[ -z "$url" ]] || [[ -z "$cache_folder" ]]; } && output::error "No url or cache" && return 1

  # Inform the uset about possible long time
  output::answer "This might take some time"
  
  # Check if we got the API calls rate limit
  github::curl "$url" | jq -r '.message' | grep -qv 'null' &&\
    output::error "You have reached the GITHUB API calls limit. Consider to get a auth token and" &&\
    output::error "set it through ENV var GITHUB_TOKEN." &&\
    return 1
  
  # We need url and cache folder if not just exit the function
  { [[ -z "$url" ]] || [[ -z "$cache_folder" ]]; } &&\
    output::error "No url or cache folder provided" &&\
    return 1

  # Create cache recursively if cache_folder does not exists
  # because it would be deleted if it is needed to recreate it
  has_scripts="$(github::curl "$(marketplace::get_url tree)" | jq -r '.tree[] | select(.type == "tree") | select(.path == "scripts") | .url')"
  [ -n "$has_scripts" ] && url="$has_scripts"
  marketplace::recursive_tree "$url" "$cache_folder"

  output::answer "End of search cache creation"

  return 0
}

# Check if it is script
# print a 0 if it is, 1 if it is not (then is a context) and
#  -1 is an abort (no script, no context)
marketplace::is_script() {
  case "$(str::to_lower "$1")" in
    abort)
      echo -1
      ;;
    */*)
      echo 0
      ;;

    *)
      echo 1
      ;;
  esac
}

# Preview the cache search
marketplace::preview_search() {
  local IFS
  green='\033[0;32m'
  bold='\033[1m'
  normal='\033[0m'
  red='\e[31m'

  output::empty_line

  case "$(marketplace::is_script "$1")" in
    -1)
      output::write "$red${bold}Exit without install anything$normal"
      output::empty_line
      return
      ;;
    0)
      output::write "Select to install $bold$green$1$normal script"
      ;;

    *)
      output::write "Select to install $bold$green$1$normal context"
      output::empty_line
      output::write "This will install all these scripts"
      marketplace::print_tab_find "$2/$1"
      ;;
  esac

  output::empty_line
  output::empty_line
  output::write "To install simply push enter or write in the shell:"
  output::write "\t\tdotly install $bold$green$(echo "$1" | tr '/' ' ')$normal"
  output::empty_line
  output::write "THIS IS PREVISUALIZATION INSTALL IS NOT AVAILBLE YET"
  output::empty_line
}

# Helper for find
marketplace::find() {
  local find_path
  find_path="${1:-$(marketplace::get_scripts_cache_path)}"; shift
  find "$find_path" -mindepth 1 $@ -name '*' | while read item; do
    item="$(echo -n "${item#$find_path/}")"
    echo "$item" | xargs
  done
}

# Find in a path with default query and add an abort option
marketplace::find_fzf() {
  local find_path query output
  find_path="${1:-$(marketplace::get_scripts_cache_path)}"
  query="${2:- }"
  output=($(marketplace::find "$find_path" -maxdepth 2))
  output+=("Abort")

  printf "%s\n" "${output[@]}" | fzf -m --extended --query "$query"\
    --header "Choose a script or full context to install"\
    --preview "source $(platform::get_script_path)/tools/github.sh >/dev/null 2>&1; marketplace::preview_search {} '$find_path'"
}

# Search for context or script in repository (really in the cache folder)
marketplace::search_in_cache() {
  local answer sha query cache_folder
  query="$1"
  cache_folder="$(marketplace::get_scripts_cache_path)"
  
  answer=($(marketplace::find_fzf "$cache_folder" "$query"))
  printf "%s\n" ${answer[@]}
}


# Get all files for specific context by default
# you can add params after to apply to marketplace::find
marketplace::get_context() {
  local context context_folder
  context="$1"; shift
  context_folder="$(marketplace::get_scripts_cache_path)/$context"
  [[ ! -d "$context_folder" ]] && return

  marketplace::find "$context_folder" $@
}

# Check if context or script exits
marketplace::check_remote_exists() {
  local cache_scripts_folder
  cache_scripts_folder="$(marketplace::get_scripts_cache_path)"
  if [[ -z "$2" ]]; then
    [[ -d "$cache_scripts_folder/$1" ]] || [[ -f "$cache_scripts_folder/$1" ]]
  else
    [[ -f "$cache_scripts_folder/$1/$2" ]]
  fi
}

# Helper: Get directories of context if it has any
marketplace::get_context_dirs() {
  printf "%s\n" "$(marketplace::get_context "$1" -type d)"
}

# Helper: Get script files of context
marketplace::get_context_scripts() {
  printf "%s\n" "$(marketplace::get_context "$1" -maxdepth 1 -type f)"
}

# Download files from a given path
# WARNING! It will overwrites existing file
marketplace::install_file_from_cache() {
  local script_full_path cache_file_path script_name
  cache_file_path="$1"
  script_name="$2"

  source "$cache_file_path" # Load vars to install
  script_full_path="$DOTFILES_SCRIPTS_PATH/$relative_script_folder_path/$script_name"
  mkdir -p "$(dirname $script_full_path)"
  touch "$script_full_path"
  github::curl "$script_download_url" | jq -r '.content' | base64 --decode > "$script_full_path"
  chmod u+x "$script_full_path"
  unset relative_script_folder_path script_download_url
}

marketplace::install_from_cache_folder() {
  local item script_name cache_path
  cache_path="$1"; shift

  # If there is more than one folder to install
  # do it recursively
  #[[ $# -gt 0 ]] && marketplace::install_from_cache_folder "$@"

  # If the context does not exist on cache, just end
  [[ ! -d $cache_path ]] && echo 1 && return 1

  find "$cache_path" -name "*" | while read item; do
    if [[ -f "$item" ]]; then
      script_name="${item#$cache_path}"
      marketplace::install_file_from_cache "$item" "$(basename $script_name)"
    fi
  done
}

# Install script or context
marketplace::install_from_search() {
  local context context_subfolder dep_path search scripts_cache_path full_cache_path
  search="$1"; shift
  scripts_cache_path="$(marketplace::get_scripts_cache_path)"
  full_cache_path="$(marketplace::get_scripts_cache_path)/$search"

  ! marketplace::check_remote_exists $search && output::error "Script or context \"$search\" does not exists" && return
  
  output::answer "Installing $(echo $search | tr '/' ' ')"

  # If it is a file is a script, then grab the context
  if [[ -f "$full_cache_path" ]]; then
    context="$(echo $search | awk -F '/' '{print $1}')"
  else
    context="$search"
  fi

  # Check if it has dependecies inside it context, then install dependencies
  for context_subfolder in $(marketplace::get_context_dirs $context); do
    dep_path="$scripts_cache_path/$context/$context_subfolder"
    [[ -d "$dep_path" ]] && marketplace::install_from_cache_folder "$dep_path"
  done

  # If it is a directory the search result is a context then install all folder
  if [[ -d "$full_cache_path" ]]; then
    marketplace::install_from_cache_folder "$full_cache_path"
  else
    marketplace::install_file_from_cache "$full_cache_path" "$(basename $full_cache_path)"
  fi

  # Recursive resolve search results. Because we want to resolve all in given order
  # just do it at the end
  [[ $# -gt 0 ]] && marketplace::install_from_search "$@"

  return 0
}