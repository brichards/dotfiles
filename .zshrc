# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Local dev folder
LOCAL_DEV_FOLDER=$HOME/Dropbox/Projects/Local\ Dev

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew cap composer git osx sublime svn vagrant)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
DEFAULT_USER="ryan"

# Update $PATH
# @TODO wrap this in file exists check
source $HOME/.path

#WP-CLI autocomplete
autoload bashcompinit
bashcompinit
source $HOME/.composer/vendor/wp-cli/wp-cli/utils/wp-completion.bash

#WP-CLI PHP
# export WP_CLI_PHP=/usr/local/bin/php
export WP_CLI_PHP=/Applications/MAMP/bin/php/php5.4.10/bin/php

alias lsa='ls -alFh --color'
alias localdev='cd /Users/ryan/Dropbox/Projects/Local\ Dev'
alias flushcache='dscacheutil -flushcache'

#colors
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

#Local Dev alias
ldev() {
	cd $LOCAL_DEV_FOLDER/$1;
}

_ldev() {
    local cur

    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ '' = $cur ]]; then
    	COMPREPLY=( $( compgen -W "$(ls "$LOCAL_DEV_FOLDER")" ) )
    else
    	COMPREPLY=( $( compgen -W "$(ls "$LOCAL_DEV_FOLDER")" | grep $cur ) )
    fi

}

complete -o nospace -F _ldev ldev