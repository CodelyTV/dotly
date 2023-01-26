coll::is_empty() {
	local var=${1}
	[[ -z ${var} ]]
}

coll::map() {
	local -r fn="$1"

	for x in $(cat); do
		"$fn" "$x"
	done
}

coll::filter() {
	local -r fn="$1"

	for x in "${@:2}"; do
		if "$fn" "$x"; then
			echo "$x"
		fi
	done
}

# @todo Move to another place
utils::not() {
	local -r fn="$1"

	if "$fn" "${@:2}"; then
		return 1
	fi
}

# @todo Move to another place
utils::curry() {
	exportfun=$1
	shift
	fun=$1
	shift
	params=$*
	cmd=$"function $exportfun() {
        more_params=\$*;
        $fun $params \$more_params;
    }"
	eval $cmd
}
