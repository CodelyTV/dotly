#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  for file in $DOTLY_PATH/scripts/core/{args,collections,documentation,dot,git,log,platform,output,str}.sh; do
	  source "$file";
  done;
  unset file;

  readonly DOT_MAIN_SOURCED=true
fi
