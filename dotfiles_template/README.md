<h1 align="center">
  .dotfiles created using <a href="https://github.com/CodelyTV/dotly">🌚 dotly</a>
</h1>

## Restore your Dotfiles manually

* Install git
* Clone your dotfiles repository `git clone [your repository of dotfiles] $HOME/.dotfiles`
* Go to your dotfiles folder `cd $HOME/.dotfiles`
* Install git submodules `git submodule update --init --recursive modules/dotly`
* Install your dotfiles `DOTFILES_PATH="$HOME/.dotfiles" DOTLY_PATH="$DOTFILES_PATH/modules/dotly" "$DOTLY_PATH/bin/dot" self install`
* Restart your terminal
* Import your packages `dot package import`

## Restore your Dotfiles with script

1. Execute with curl:
```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/restore)
```

Or wget:
Using wget
```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/restore)
```

2. Follow the steps.
3. You need to know your github username, repository and install ssh key if your repository is private.

It also support other git repos but you need to know your git repository url.
