#!/bin/user/env bash

installer::get_arch() {
  local architecture=""
  case $(uname -m) in
    i386|i686)
      architecture="386"
      ;;
    x86_64)
      architecture="amd64"
      ;;
    arm)
      architecture="arm"
      ;;
  esac

  echo "$architecture"
}

installer::get_os() {
  uname | tr '[:upper:]' '[:lower:]'
}

installer::install_yq() {
  local binary_name yq_path
  binary_name="yq_$(installer::get_os)_$(installer::get_arch)"
  yq_path="$HOME/bin/yq"
  output::error "yq not installed, installing"

  if "$DOTLY_PATH/bin/dot" package add yq | log::file "Installing yq"; then
    return 0
  fi

  if platform::command_exists curl; then
    {
      curl "https://github.com/mikefarah/yq/releases/latest/download/$binary_name" -o "$yq_path" >/dev/null 2>&1 &&\
      chmod +x "$yq_path"
    } || {
      output::error "Could not install yq!"
      exit 5
    }
  fi

  if platform::command_exists wget; then
    {
      wget "https://github.com/mikefarah/yq/releases/latest/download/$binary_name" -O "$yq_path" >/dev/null 2>&1 &&\
      chmod +x "$yq_path"
    } || {
      output::error "Could not install yq!"
      exit 5
    }
  fi

  if platform::command_exists go; then
    GO111MODULE=on go get github.com/mikefarah/yq/v4 >/dev/null 2>&1 || {
      output::error "Could not install yq!"
      exit 5
    }
  fi

  output::solution "yq successfully installed!"
}

installer::update_in_home() {
  local binary_name yq_path
  binary_name="yq_$(installer::get_os)_$(installer::get_arch)"
  yq_path="$HOME/bin/yq"
  output::error "yq not installed, installing"

  if platform::command_exists curl; then
    {
      curl --silent "https://github.com/mikefarah/yq/releases/latest/download/$binary_name" >| "$yq_path" 2>/dev/null &&\
      chmod +x "$yq_path"
    } || {
      output::error "Could not install yq!"
      exit 5
    }
  fi

  if platform::command_exists wget; then
    {
      wget "https://github.com/mikefarah/yq/releases/latest/download/$binary_name" -O "$yq_path" >/dev/null 2>&1 &&\
      chmod +x "$yq_path"
    } || {
      output::error "Could not install yq!"
      exit 5
    }
  fi
}
