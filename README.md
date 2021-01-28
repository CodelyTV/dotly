<p align="center">
  <a href="http://codely.tv">
    <img src="http://codely.tv/wp-content/uploads/2016/05/cropped-logo-codelyTV.png" width="192px" height="192px"/>
  </a>
</p>

<h1 align="center">
  🌚<br>Simple, fast, productivity-increaser dotfiles framework
</h1>

<p align="center">
    <a href="https://github.com/CodelyTV"><img src="https://img.shields.io/badge/CodelyTV-OS-green.svg?style=flat-square" alt="codely.tv"/></a>
    <a href="http://pro.codely.tv"><img src="https://img.shields.io/badge/CodelyTV-PRO-black.svg?style=flat-square" alt="CodelyTV Courses"/></a>
</p>

## Installation

Using curl
```bash
bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/master/installer)
```

Using wget
```bash
bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/master/installer)
```

## Considerations using Apple M1
* You should run your terminal/iTerm using Rosetta emulation

Using curl
```bash
arch -x86_64 bash <(curl -s https://raw.githubusercontent.com/CodelyTV/dotly/master/installer)
```

Using wget
```bash
arch -x86_64 bash <(wget -qO- https://raw.githubusercontent.com/CodelyTV/dotly/master/installer)
```

## First steps

After you have installed your dotfiles, you must create a repository where you place your dotfiles. Then in your terminal, after you have created your dotfiles repository (replace variables for your values):

```bash
export GITHUB_USERNAME=dotly
export GITHUB_DOTFILES_REPOSITORY=dotfiles
cd $DOTFILES_PATH
git remote add origin git@github.com:${GITHUB_USERNAME}/${GITHUB_DOTFILES}.git
git add *
git commit -m "First commit"
git push -u origin master
```

After this maybe you want to save your current npm, python and package manager packages (brew in osx, apt in debian...) so type:

```bash
dot packages dump
```
This will save your packages in `$DOTFILES_PATH/os/<os_name>/<package_manager>`, so later you will be available to install a new system as it is yours now.


## Restoring your dotfiles

After you have done the git push you will have a README.md file where you have the steps to do.
