# Clean Install Script

This is based on [Andy Fragen's mac-clean-install repo](https://github.com/afragen/mac-clean-install).

I've written my install script to be fairily deterministic: I want it to only install/create things that don't already exist.

I've also written it to only install the components I actually _want_ on a given computer – not everything I do needs to be on every computer I own (e.g. video production vs web development) – and so the script prompts for input before installing anything.

This script supports remote execution, e.g.:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/brichards/dotfiles/master/install.sh)"
```

Or it can be run locally after cloning this repo, e.g.:

```bash
git clone git@github.com:brichards/dotfiles.git ~/.dotfiles
sh ~/.dotfiles/install.sh
```

# MacOS Prefs Script

This script is based on [Mathias Bynens macos prefs script](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and sets application and system preferences to my preferred defaults.

It is called automatically from the `install.sh` script (if the option to install prefs is selected). Alternatively, it can also be called manually via remote execution, e.g.:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/brichards/dotfiles/master/install-macos-prefs.sh)"
```

Or it can be run locally after cloning this repo, e.g.:

```bash
git clone git@github.com:brichards/dotfiles.git ~/.dotfiles
sh ~/.dotfiles/install-macos-prefs.sh
```

# Dotfiles

These are my personal dotfiles. You probably don't want to copy these.

But you probably _do_ want to copy some of the other [dotfile bootstraps hosted on GitHub](https://dotfiles.github.io/)

## Helpful tip

When configuring a new machine, clone this repo to `~/.dotfiles` and then symlink each file to the user directory, e.g.:

```bash
git clone git@github.com:brichards/dotfiles.git ~/.dotfiles
ln -s ~/.dotfiles/.dir_colors ~/.dir_colors
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/eslintrc.json ~/Sites/www/eslintrc.json
ln -s ~/.dotfiles/wp-cli.yml ~/Sites/www/wp-cli.yml
source ~/.zshrc
```
