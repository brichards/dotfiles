# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Can be set to "random"
ZSH_THEME="agnoster"

# Set default user.
# Will remove from prompt if matches current user
DEFAULT_USER="brian"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew cap composer git osx sublime svn vagrant)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Update $PATH
# @TODO wrap this in file exists check
source $HOME/.path

# WP-CLI autocomplete
autoload bashcompinit
bashcompinit
source $HOME/.composer/vendor/wp-cli/wp-cli/utils/wp-completion.bash

# WP-CLI PHP
export WP_CLI_PHP=/Applications/MAMP/bin/php/php5.4.10/bin/php

# Aliases
# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias g="git"
alias o="open"
alias oo="open ."

# List all files colorized in long format
alias l="ls -lFh --color"

# List all files colorized in long format, including dot files
alias la="ls -laFh --color"

# List only directories
alias lsd='ls -lFh --color | grep "^d"'

# Always use color output for `ls`
alias ls="command ls --color"

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get OS X Software Updates, and update Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade;'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# colors
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Jump to local dev project with autocomplete
LOCAL_DEV_FOLDER=$HOME/Sites/wds
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
