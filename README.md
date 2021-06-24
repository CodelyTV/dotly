<p align="center">
  <a href="https://github.com/gtrabanco/sloth">
    <img src="sloth.svg" alt="Sloth Logo" width="256px" height="256px" />
  </a>
</p>

<h1 align="center">
  Dotfiles for laziness
</h1>

<p align="right">
  Original idea is <a href="https://github.com/codelytv/dotly" alt="Dotly repository">Dotly Framework</a> by <a href="https://github.com/rgomezcasas" alt="Dotly orginal developer">Rafa Gomez</a>
</p>

## INSTALLATION

### Linux, macOS, FreeBSD

Using wget
```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

Using curl
```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/installer)
```

### [WIP] Installation for Windows

Using elevated PowerShell (WIP: It will be available soon):
```powershell
Invoke-Command ...
```

## Restoring dotfiles

In your repository you see a way to restore your dotfiles, anyway you can restory by using the restoration script

### Linux, macOS, FreeBSD

Using wget
```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/restorer)
```

Using curl
```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/HEAD/restorer)
```
### Windows

WIP: It will be available soon

<hr>

## Roadmap

If you want to contribute you can, here I have some ideas. Some are a WIP and I am developing some of them. The cross for a task done, mean that it is merged in master.

- [ ] Documentation for core libraries as API reference.
- [ ] Documentation how to do a script
- [ ] **Script creation from template (this is done and I will merge it soon).**
- [ ] *Install on WSL from a Powershell Script (I am Working on this, right now).*
- [ ] **Automatic Updates (it is done and I will merge it soon through PR).**
- [ ] **Separate .bashrc and .zshrc and dotly loading (it is done and I will merge it soon). This makes easier to update any core features.**
- [ ] Scripts Marketplace (Almost done in feature/marketplace)
- [ ] **Create your dotfiles in iCloud and restore from it (this is done and I will merge it soon).**
- [ ] **Improve receipes to add receipes for custom dotfiles (not in core) and installation check for packages with no the same name as a binary.**
- [ ] Posix compatibility for all scripts and libraries (maybe not necessary but needs at least, a review).
- [ ] Improve error handling in all scripts and libraries (maybe not necessary but needs at least, a review).
- [ ] **Move files to inside your dotfiles from shell and add it to `symlinks/conf.yaml` file automatically (almost done).**
- [ ] **Managing secrets (almost done). Needs a refactor and some fixes.**

It is important to keep compatibility with dotly scripts.
