#!/usr/bin/env bash

_ssh_config()
{
	[ "${#COMP_WORDS[@]}" != 2 ] && return

	local ssh_hosts=$(cat "${HOME}/.ssh/config" $(ls -d -1 "$HOME/.ssh/config.d/"*) | grep "^Host " | grep -v "*" | awk '{$1="";print $0;}' | tr "\n" " ")
	suggestions=($(compgen -W "$ssh_hosts" "${COMP_WORDS[$COMP_CWORD]}"))

	[ "${#suggestions[@]}" == "1" ] && COMPREPLY=($(echo ${suggestions[0]})) || COMPREPLY=("${suggestions[@]}")
}

complete -F _ssh_config ssh
