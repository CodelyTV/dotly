#!/usr/bin/env bash

yum::install() {
   yes | sudo yum install "$@"
}
