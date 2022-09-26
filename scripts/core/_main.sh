if ! ${DOT_MAIN_SOURCED:-false}; then
	for file in $DOTLY_PATH/scripts/core/{args,collections,documentation,dot,git,log,platform,output,script,str}.sh; do
		source "$file"
	done
	unset file

	readonly DOT_MAIN_SOURCED=true
fi
