git::is_in_repo() {
	git rev-parse HEAD >/dev/null 2>&1
}

git::current_branch() {
	git branch
}

git::branch_exists() {
	branch_name="${1}"
	exists_branch=$(git branch --list $branch_name)
	[[ -z $exists_branch ]]
}
