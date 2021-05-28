#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  for file in $DOTLY_PATH/scripts/core/{args,array,async,collections,documentation,dot,files,git,json,log,output,platform,str,yaml}.sh; do
    . "$file";
  done;
  unset file;

  readonly DOT_MAIN_SOURCED=true
fi
