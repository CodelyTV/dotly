#!/usr/bin/env bash

dump::file_path() {
  local package_manager dump_file_name
  package_manager="${1:-}"
  dump_file_name="${2:-}"

  [[ -z "$package_manager" || -z "$dump_file_name" ]] && return

  case "$package_manager" in
    cargo)
      if ${SLOTH_PACKAGES_DUMP_ARCH:-false}; then
        echo "${DOTFILES_PATH}/langs/rust/cargo/$(platform::get_arch)/${dump_file_name}.txt"
      else
        echo "${DOTFILES_PATH}/langs/rust/cargo/${dump_file_name}.txt"
      fi
      ;;
    npm)
      if [[ -r "${DOTFILES_PATH}/langs/js/global_packages.txt" ]]; then
        echo "${DOTFILES_PATH}/langs/js/${dump_file_name}.txt"
      else
        echo "${DOTFILES_PATH}/langs/js/npm/${dump_file_name}.txt"
      fi
      ;;
    skills)
      if ${SLOTH_PACKAGES_DUMP_ARCH:-false}; then
        echo "${DOTFILES_PATH}/agents/$(platform::get_arch)/skill-lock.yaml"
      else
        echo "${DOTFILES_PATH}/agents/skill-lock.yaml"
      fi
      ;;
    volta)
      if [[ -r "${DOTFILES_PATH}/langs/js/volta_dependencies.txt" ]]; then
        echo "${DOTFILES_PATH}/langs/js/volta_dependencies.txt"
      else
        echo "${DOTFILES_PATH}/langs/js/volta/${dump_file_name}.txt"
      fi

      ;;
    pip | pip3)
      echo "${DOTFILES_PATH}/langs/python/${dump_file_name}.txt"
      ;;
    # Please if you are adding a new package manager keep this last name the others
    # are just to keep compatibility with Dotly and previous dumps
    *)
      if ${SLOTH_PACKAGES_DUMP_ARCH:-false}; then
        echo "${DOTFILES_PATH}/os/$(platform::os)/$(platform::get_arch)/${package_manager}/${dump_file_name}.txt"
      else
        echo "${DOTFILES_PATH}/os/$(platform::os)/${package_manager}/${dump_file_name}.txt"
      fi
      ;;
  esac
}
