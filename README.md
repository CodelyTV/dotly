<div align="center">
  <a href="https://codely.tv">
    <img src="https://user-images.githubusercontent.com/1331435/141520189-90349bbd-3e0f-4200-8b76-f4297be11898.png" />
  </a>
</div>
<div align="center">
  <h1>⚡️ Simple and fast dotfiles framework ⚡️</h1>
  <strong>The path to increasing your productivity on macOS, Linux and WLS</strong>
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

```
├── 📁 bin                 -> External binaries/symlinks. This folder has preference in your $PATH
├── 📁 doc                 -> Documentation of your dotfiles
├── 📁 editors             -> Settings of your editors (vscode, IDEA, …)
├── 📁 git                 -> git config
├── 📁 langs               -> Config for programming languages/libraries
├── 📁 os                  -> Specific config of your Operative System or apps
├── 📁 restoration_scripts -> This will be execute when you restore your dotfiles in another computer/installation
├── 📁 scripts             -> Your custom scripts
├── 📁 shell               -> Bash/Zsh/Fish?… configuration files
└── 📁 symlinks            -> The config of your symlinks
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

## ⁉️ Troubleshooting

## 🤝 Contributing

### 🔦 Lint & Static analysis

## ⚖️ LICENSE

MIT © [CodelyTV](https://codely.tv)

