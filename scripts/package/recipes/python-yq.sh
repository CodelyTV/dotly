dot::get_script_src_path "yq.sh" "package"

yq::install() {
  local binary_name yq_path

  binary_name="yq_$(installer::get_os)_$(installer::get_arch)"
  yq_path="$HOME/bin/yq"
  output::error "yq not installed, installing"

  "$DOTLY_PATH/bin/dot" package add python-yq --skip-recipe | log::file "Installing yq"
  if package::is_installed python-yq; then
    return 0
  fi

  if platform::command_exists pip3 &&\
     pip3 install yq | log::file "Installing yq from pip3" &&\
     platform::command_exists yq
  then
    output::solution "yq installed!"
    return 0
  fi

  output::error "yq could not be installed"
  return 1
}
