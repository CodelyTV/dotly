<h1 align="center">
  .dotfiles created using <a href="https://github.com/CodelyTV/dotly">🌚 dotly</a>
</h1>

## Restore your Dotfiles

```bash
export GITHUB_USER=""
export DOTFILES_REPOSITORY="dotfiles"
export DOTFILES_PATH="${HOME}/.dotfiles"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
#ssh-keygen # Uncoment to generate your ssh key
#cat ~/.ssh/id_rsa.pub | pbcopy # Uncoment if you have generated a new key
#      In Linux use 'xclip -selection clipboard'
# Add to Github > Settings > SSH and GPG Keys > Add new SSH key
xcode-select --install
#rm -rf "$DOTFILES_PATH" "~/.dotly" # Optional step
git clone git@github.com:$GITHUB_USER/$DOTFILES_REPOSITORY.git "$DOTFILES_PATH"
cd "$DOTFILES_PATH"
git submodule update --init --recursive
"$DOTLY_PATH/bin/dot" self install
"$DOTLY_PATH/bin/dot" package import # Import your packages
echo "Press a key to exit the terminal and later reopen it..."
exit
```
