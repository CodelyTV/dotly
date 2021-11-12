<div align="center">
  <a href="https://codely.tv">
    <img src="https://user-images.githubusercontent.com/1331435/141520189-90349bbd-3e0f-4200-8b76-f4297be11898.png" />
  </a>
</div>
<div align="center">
  <h1>⚡️ Simple and fast dotfiles framework ⚡️</h1>
  <strong>The path to increasing your productivity</strong>
</div>
<br>
<p align="center">
    <a href="https://github.com/CodelyTV"><img src="https://img.shields.io/badge/CodelyTV-OS-green.svg?style=flat-square" alt="codely.tv"/></a>
    <a href="https://pro.codely.tv"><img src="https://img.shields.io/badge/CodelyTV-PRO-black.svg?style=flat-square" alt="CodelyTV Courses"/></a>
    <a href="https://github.com/CodelyTV/dotly/actions"><img src="https://github.com/CodelyTV/dotly/workflows/CI/badge.svg" alt="CI pipeline status"/></a>
</p>

dotly is a dotfiles framework built on top of [zim](https://github.com/zimfw/zimfw), one of the fastest zsh existing
frameworks. It creates an opinionated dotfiles structure to handle all your configs and scripts.

In works on macOS, Linux and WLS.

## 🚀 Installation

Using wget:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

Or using curl:

```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

## 🚶 First steps

Once dotly is installed, the next step is to commit your dotfiles. Create your dotfiles repository in
github ([example](https://github.com/rgomezcasas/dotfiles)) and copy the url. Then go to your
dotfiles (`cd $DOTFILES_PATH`) and execute:

```bash
git remote add origin YOUR_DOTFILES_REPO_URL && git add -A && git commit -m "Initial commit" && git push origin main
```

you'll have your dotfiles in the `~/.dotfiles` directory (unless you have chosen another location).

## 💻 Usage

### 🌚 The `dot` command

### 🌴 Understanding the folders structure

### 🎨 Customization

### 💾 Default scripts

## 🧪 Test

## ⁉️ Troubleshooting

## 🤝 Contributing

### 🔦 Lint & Static analysis

## ⚖️ LICENSE

MIT © [CodelyTV](https://codely.tv)

