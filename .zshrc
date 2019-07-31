# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Local dev folder
LOCAL_DEV_FOLDER=$HOME/Sites/www/

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="agnoster"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(bower brew colorize common-aliases composer git git-extras git-flow git-hubflow gitignore grunt npm osx sublime svn vagrant wp-cli zsh-syntax-highlighting)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set default user.
# Will remove from prompt if matches current user
DEFAULT_USER="brian"

# Customize the PATH
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/opt/coreutils/libexec/gnubin:/opt/subversion/bin:/usr/local/git/bin:/Users/brian/.wp-cli/bin:~/Source/cf/bin:~/Source/cf/git-bin:$PATH

# colors
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ZSH Syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')

# Imagesnap
alias isight="imagesnap ~/Dropbox/$(date +%Y-%m-%d--%I.%M.%S.%p).png"

# Shortcuts
alias g="git"
alias o="open"
alias oo="open ."
alias reload="source ~/.zshrc"
alias hosts="sudo sub /etc/hosts"
alias gitorphan="git checkout master && git fetch origin && git rebase origin/master && git checkout --orphan wpe && git submodule init && git submodule sync && git submodule update --init --recursive && git flatten-submodules"
alias gitorphanreset="git checkout master && git submodule sync && git submodule update --init --recursive && git branch -D wpe"
alias dev="cd ~/Sites/www"
alias pr="hub pull-request"

# List all files colorized in long format
alias l="ls -lFh --color"

# List all files colorized in long format, including dot files
alias la="ls -laFh"

# List only directories
alias lsd='ls -lFh --color | grep "^d"'

# Always use color output for `ls`
# alias ls="command ls --color"

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
alias serverstart="mysql.server start && sudo apachectl -k start"

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

# Open a project in chrome and sublime
function proj() {
	open -a "Google Chrome" http://$@.dev;
	sub ~/Sites/projects/$@.sublime-project;
}

# Install a new WP site
function wpinstall() {
	mkdir ~/Sites/www/$@;
	cd ~/Sites/www/$@;
	wp core download;
	wp core config --dbname=$@;
	wp db create;
	wp core install --url=https://$@.test --title=$( tr '[A-Z]' '[a-z]' <<< $@ );
	valet secure $@;
	open -a "Google Chrome" https://$@.test/wp-admin;
}

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

. /usr/local/etc/profile.d/z.sh
