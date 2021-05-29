dot::get_script_src_path "yq.sh" "package"

yq::install() {
  local binary_name yq_path

  binary_name="yq_$(installer::get_os)_$(installer::get_arch)"
  yq_path="$HOME/bin/yq"
  output::error "yq not installed, installing"

  "$DOTLY_PATH/bin/dot" package add yq --skip-recipe | log::file "Installing yq"
  if package::is_installed yq; then
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
