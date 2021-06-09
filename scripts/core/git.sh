git::is_in_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

# shellcheck disable=SC2120
git::current_branch() {
  git branch --show-current "$@"
}

git::get_local_HEAD_hash() {
  local branch
  branch="${1:-HEAD}"
  git::is_in_repo && git rev-parse "$branch"
}

git::get_remote_branch_HEAD_hash() {
  local remote branch
  remote="${1:-origin}"
  branch="${2:-master}"
  git::is_in_repo && git ls-remote --heads "$remote" "$branch"
}

git::local_current_branch_commit_exists_remote() {
  local remote branch local_commit
  remote="${1:-origin}"
  branch="${2:-master}"
  local_commit="$(git::get_local_HEAD_hash "$branch")"

  [ -n "$local_commit" ] &&\
    git::is_in_repo &&
    git ls-remote --symref "$remote" | tail -n +2 | grep -q "$local_commit"
}

git::remote_branch_by_hash() {
  [[ -n "${1:-}" ]] && git ls-remote --symref origin | tail -n +2 | grep "${1:-}" | awk '{print $2}' | grep "refs/heads" | sed 's#refs/heads/##'
}

# shellcheck disable=SC2120
git::current_commit_hash() {
  git rev-parse HEAD "$@"
}

# shellcheck disable=SC2120
git::get_commit_tag() {
  local commit
  if git::is_in_repo; then
    commit="${1:-}"
    { [[ -n "$commit" ]] && shift; } || commit="$(git::current_commit_hash)"

    git show-ref --tags "$@" | grep "$commit" | awk '{print $2}' | sed 's#refs/tags/##'
  fi
}

git::get_current_latest_tag() {
  git::get_all_local_tags | head -n1
}

# shellcheck disable=SC2120
git::get_all_local_tags() {
  #git tag -l --sort="-version:refname" "$@"
  git show-ref --tags | sort --reverse | awk '{print $2}' | sed 's#refs/tags/##'
}

git::get_all_remote_tags() {
  local repository
  repository="${1:-origin}"
  git ls-remote --tags --sort "-version:refname" "$repository" "$@"
}

git::get_all_remote_tags_version_only() {
  local repository
  repository="${1:-}"
  { [[ -n "$repository" ]] && shift; } || repository="origin"
  git::get_all_remote_tags "$repository" "${@:-*.*.*}" 2>/dev/null | sed 's/.*\///; s/\^{}//' | uniq
}

git::check_local_tag_exists() {
  local repository tag_version
  repository="${1:-}"
  tag_version="${2:-}"

  { [[ -z "$repository" ]] || [[ -z "$tag_version" ]]; } && return 1

  git::get_all_local_tags | grep -q "$tag_version"
}

git::check_remote_tag_exists() {
  local repository tag_version
  repository="${1:-}"
  tag_version="${2:-}"

  { [[ -z "$repository" ]] || [[ -z "$tag_version" ]]; } && return 1

  [[ -n "$(git::get_all_remote_tags_version_only "$repository" "$tag_version")" ]]
}

git::get_submodule_property() {
  local gitmodules_path submodule_directory property

  if [ $# -gt 2 ]; then
    gitmodules_path="$1"; shift
    submodule_directory="$1"
  fi

  gitmodules_path="${gitmodules_path:-$DOTFILES_PATH/.gitmodules}"
  submodule_directory="${submodule_directory:-modules/${1:-}}"
  property="${2:-}"

  [[ -f "$gitmodules_path" ]] && [[ -n "$submodule_directory" ]] && [[ -n "$property" ]] && git config -f "$gitmodules_path" submodule."$submodule_directory"."$property"
}

git::check_file_exists_in_previous_commit() {
  [[ -n "${1:-}" ]] && ! git rev-parse @~:"${1:-}" > /dev/null 2>&1
}

git::get_file_last_commit_timestamp() {
  [[ -n "${1:-}" ]] && git rev-list --all --date-order --timestamp -1 "${1:-}" 2>/dev/null | awk '{print $1}'
}

git::get_commit_timestamp() {
  [[ -n "${1:-}" ]] && git rev-list --all --date-order --timestamp | grep "${1:-}" | awk '{print $1}'
}

git::check_file_is_modified_after_commit() {
  local file_path file_commit_date commit_to_check commit_to_check_date
  file_path="${1:-}"
  commit_to_check="${2:-}"
  { [[ -z "$file_path" ]] || [[ -z "${commit_to_check:-}" ]] || [[ ! -e "$file_path" ]]; } && return 1

  file_commit_date="$(git::get_file_last_commit_timestamp "${file_path:-}" 2>/dev/null)"

  [[ -z "$file_commit_date" ]] && return 0 # File path did not exists previously then
  # it is more recent than any commit 😅

  commit_to_check_date="$(git::get_commit_timestamp "$commit_to_check")"
  [[ "$file_commit_date" -gt "$commit_to_check_date" ]]
}

# PR Note to reviewer: This function could be replaced by the next one, the
# function name that use update is this one
# git::check_local_repo_is_updated() {
#   local repo_path remote return_code current_dir remote_head_hash remote_head_branch local_head_remote_branch_hash
#   remote="${1:-origin}"
#   repo_path="${2:-.}"

#   current_dir="$(pwd)"
#   return_code=1

#   cd "$repo_path" || return 1

#   if git::is_in_repo; then
#     remote_head_hash="$(git ls-remote --symref "$remote" | tail -n +2 | head -n 1 | awk '{print $1}')" # remote: HEAD
#     remote_head_branch="$(git::remote_branch_by_hash "$remote_head_hash")"
#     local_head_remote_branch_hash="$(git rev-parse "$remote_head_branch")"

#     git::local_current_branch_commit_exists_remote "$remote" "$local_head_remote_branch_hash" && [ "$remote_head_hash" == "$local_head_remote_branch_hash" ]
#     return_code=$?
#   fi

#   cd "$current_dir" || return $return_code

#   return $return_code
# }

git::check_local_repo_is_updated() {
  git::is_in_repo && ! git status -sb 2>/dev/null | grep -q 'behind'
}

git::dotly_repository_exec() {
  local return_code
  return_code=0
  cd "$DOTLY_PATH" || return 1

  if git::is_in_repo; then
    eval "$@"
  else
    return_code=1
  fi

  return "$return_code"
}
