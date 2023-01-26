str::split() {
	local -r text=$1
	local -r splitter=$2

	echo "$text" | tr "$splitter" "\n"
}

str::contains() {
	[[ $2 == *$1* ]]
}
