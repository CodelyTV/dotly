<div align="center">
  <h1>
    .dotfiles created using <a href="https://github.com/gtrabanco/sloth">SLOTH</a>
    <div style="display:block">
      <a href="https://github.com/gtrabanco/sloth">
        <img src="sloth.svg" alt="Sloth Logo" width="256px" height="256px" />
      </a>
    </div>
  </h1>
</div>

## Restore your Dotfiles manually

* Install git
* Clone your dotfiles repository `git clone [your repository of dotfiles] $HOME/.dotfiles`
* Go to your dotfiles folder `cd $HOME/.dotfiles`
* Install git submodules `git submodule update --init --recursive modules/sloth`
* Install your dotfiles `DOTFILES_PATH="$HOME/.dotfiles" SLOTH_PATH="$DOTFILES_PATH/modules/sloth" "$SLOTH_PATH/bin/dot" self install`
* Restart your terminal
* Import your packages `lazy package import`

## Restore your Dotfiles with script

Using wget
```bash
bash <(wget -qO- https://raw.githubusercontent.com/gtrabanco/sloth/HEAD/restorer)
```

Using curl
```bash
bash <(curl -s https://raw.githubusercontent.com/gtrabanco/sloth/HEAD/restorer)
```

You need to know your GitHub username, repository and install ssh key if your repository is private.

It also supports other git repos, but you need to know your git repository url.
