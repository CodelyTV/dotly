#!/usr/bin/env bash

# Usage: array::* "${arr1[@]}" "${arr2[@]}"
array::union() { echo "${@}" | tr ' ' '\n' | sort | uniq; }
array::disjunction() { echo "${@}" | tr ' ' '\n' | sort | uniq -u; }
array::difference() { echo "${@}" | tr ' ' '\n' | sort | uniq -d; }