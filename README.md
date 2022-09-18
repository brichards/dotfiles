These are my personal dotfiles. You probably don't want to copy these.

But you probably _do_ want to copy some of the other [dotfile bootstraps hosted on GitHub](https://dotfiles.github.io/)

## Helpful tip

When configuring a new machine, clone this repo to `~/.dotfiles` and then symlink each file to the user directory:

```
ln -s ~/.dotfiles/.dir_colors ~/.dir_colors
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/eslintrc.json ~/Sites/www/eslintrc.json
ln -s ~/.dotfiles/wp-cli.yml ~/Sites/www/wp-cli.yml
source ~/.zshrc
```
