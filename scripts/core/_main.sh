#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  for file in $DOTLY_PATH/scripts/core/{args,collections,documentation,dot,files,git,json,log,platform,output,str,yaml}.sh; do
    . "$file";
  done;
  unset file;

  readonly DOT_MAIN_SOURCED=true
fi
