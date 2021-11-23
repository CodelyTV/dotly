<div align="center">
  <a href="https://codely.tv">
    <img src="https://user-images.githubusercontent.com/1331435/141520189-90349bbd-3e0f-4200-8b76-f4297be11898.png" />
  </a>
</div>
<div align="center">
  <h1>⚡️ Simple and fast dotfiles framework ⚡️</h1>
  <strong>The path to increasing your productivity on macOS, Linux and WSL</strong>
</div>
<br>
<p align="center">
    <a href="https://github.com/CodelyTV"><img src="https://img.shields.io/badge/CodelyTV-OS-green.svg?style=flat-square" alt="codely.tv"/></a>
    <a href="https://pro.codely.tv"><img src="https://img.shields.io/badge/CodelyTV-PRO-black.svg?style=flat-square" alt="CodelyTV Courses"/></a>
    <a href="https://github.com/CodelyTV/dotly/actions"><img src="https://github.com/CodelyTV/dotly/workflows/CI/badge.svg" alt="CI pipeline status"/></a>
</p>

dotly is a dotfiles framework built on top of [zim](https://github.com/zimfw/zimfw), one of the fastest zsh existing
frameworks. It creates an opinionated dotfiles structure to handle all your configs and scripts.

## 🚀 Installation

Using wget:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

Or using curl:

```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

## 💻 Usage

### 🚶 First steps

Once dotly is installed, the next step is to commit and push your dotfiles. Create a new repository in your GitHub
named `dotfiles` and then copy the url. Then go to your dotfiles (`cd "$DOTFILES_PATH"`) and execute:

```bash
git remote add origin YOUR_DOTFILES_REPO_URL &&
git add -A &&
git commit -m "Initial commit" &&
git push origin main
```

It's recommended to commit every time you add/modify a config or script.

### 🌚 The `dot` command

`dot` is the core command of dotly. If you execute it, you'll see all your scripts.

```bash
{▸} ~ dot -h
Usage:
   dot
   dot <context>
   dot <context> <script> [<args>...]
   dot -h | --help
 ```

### 🌴 Understanding your dotfiles folder structure

```bash
├── 📁 bin                 # External binaries/symlinks. This folder has preference in your $PATH
├── 📁 doc                 # Documentation of your dotfiles
├── 📁 editors             # Settings of your editors (vscode, IDEA, …)
├── 📁 git                 # git config
├── 📁 langs               # Config for programming languages/libraries
├── 📁 os                  # Specific config of your Operative System or apps
├── 📁 restoration_scripts # This will be execute when you restore your dotfiles in another computer/installation
├── 📁 scripts             # Your custom scripts
├── 📁 shell               # Bash/Zsh/Fish?… configuration files
└── 📁 symlinks            # The config of your symlinks
```

### ⚙️ Versioning configs

dotly facilites you to version your apps config files. Once you've found the config to version you should:

1. Copy your config file inside your dotfiles so this will be the source of truth.
   E.g. `cp ~/Library/Application Support/Code/User/settings.json $DOTFILES_PATH/editors/code/settings.json`
2. Symlink this file. To do this you should edit your `$DOTFILES_PATH/symlinks/conf.YOUR-OS.yaml` and add it.
   E.g. `~/Library/Application Support/Code/User/settings.json: editors/code/settings.json`

### 🎨 Customization

dotly includes am opinionated, minimal, very fast and powerful theme by default. You can configure it using the
following parameters in your `shell/exports.sh`:

```bash
CODELY_THEME_MINIMAL=false|true  # If true the theme will only show the prompt status
CODELY_THEME_MODE="dark"|"light" # Use dark if you use dark colors, light if light
CODELY_THEME_PROMPT_IN_NEW_LINE=false|true           # If true the prompt will be in a newline
CODELY_THEME_PWD_MODE="short"|"full"|"home_relative" # short will show the first letter of each directory, full the full path and home_relative the full path relative to the $HOME dir
CODELY_THEME_STATUS_ICON_KO="▪" # The icon to show if the previous command failed. Useful if you're color blind
```

### 💾 Default scripts

```bash
├── 📁 dotfiles
│  ├── create # Creates the dotfiles scructure
│  └── import # Import an existing dotfiles
├── 📁 git
│  ├── amend           # Amend a commit
│  ├── apply-gitignore # Exlude all commited files that are inside the project .gitignore
│  ├── changed-files   # Show all changed files to main
│  ├── commit          # Add all files and then commit
│  ├── contributors    # List contributors with number of commits
│  ├── find            # Find commits by commit message
│  ├── pretty-diff     # Show a pretty git diff using fzf (and copy selected path to the clipboard)
│  ├── pretty-log      # Git log filtering
│  └── rm-file-history # Remove completely a file from the repo with its history
├── 📁 mac
│  ├── brew     # Some brew utils
│  └── defaults # Some defaults utils to view your changes, import and export
├── 📁 package
│  ├── add        # Install a package
│  ├── dump       # Dump all installed packages
│  ├── import     # Import previously dumped packages
│  └── update_all # Update all packages
├── 📁 self # Instead of `dot self` you can use direclty `dotly` in your terminal
│  ├── debug           # Debug dotly
│  ├── install         # Install dotly and setup dotfiles
│  ├── lint            # Lint all dotly related bash files
│  ├── static_analysis # Static analysis of all dotly related bash files
│  └── update          # Update dotly to the latest stable release
├── 📁 shell
│  └── zsh # ZSH helpers
└── 📁 symlinks
    └── apply # Apply all symlinks
```

### 💽 Alias

You can see the default aliases [here](dotfiles_template/shell/aliases.sh). The most commonly used are:

* `..`: cd one directory up
* `la`: ls all files/dirs with colors
* `up`: Update all your package managers packages

## ⁉️ Troubleshooting

You can execute `dot self debug` in parallel with another command to see the errors output.

## 🤝 Contributing

* If you want to implement a new feature/script, please, open an issue first

## 😊 Thanks

A lot of dotly concepts has been inspired by [denisidoro/dotfiles](https://github.com/denisidoro/dotfiles)

## ⚖️ LICENSE

MIT © [CodelyTV](https://codely.tv)
