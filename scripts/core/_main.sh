#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  for file in $DOTLY_PATH/scripts/core/{args,collections,log,platform,output,str,paths}.sh; do
	  [ -r "$file" ] && [ -f "$file" ] && source "$file";
  done;
  unset file;

  readonly DOT_MAIN_SOURCED=true
fi
