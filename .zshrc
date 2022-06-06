# Customize the PATH
export PATH=$PATH:~/bin:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/opt/coreutils/libexec/gnubin

# Include Git binaries
export PATH=$PATH:/usr/local/git/bin

# Include Composer binares
export PATH=$PATH:~/.composer/vendor/bin

# Include WP-CLI binaries
export PATH=$PATH:/Users/brian/.wp-cli/bin

# Include VS Code binaries
export PATH=$PATH:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin

# Load oh-my-zsh plugins
# Core plugins are found in ~/.oh-my-zsh/plugins/
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(brew colorize common-aliases composer git git-extras git-flow git-hubflow github gitignore npm macos wp-cli zsh-syntax-highlighting)

# Path to oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load (stored in ~/.oh-my-zsh/themes/)
ZSH_THEME="agnoster"

# Set default user (removes from prompt if matches current user)
DEFAULT_USER="brian"

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set custom ls colors
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ZSH Syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Misc Shortcuts
alias reload="source ~/.zshrc"
alias o="open"
alias oo="open ."
alias makemkv="/Applications/MakeMKV.app/Contents/MacOS/makemkvcon"

# Git shortcuts
alias g="git"
alias gitorphan="git checkout master && git fetch origin && git rebase origin/master && git checkout --orphan wpe && git submodule init && git submodule sync && git submodule update --init --recursive && git flatten-submodules"
alias gitorphanreset="git checkout master && git submodule sync && git submodule update --init --recursive && git branch -D wpe"
alias pr="hub pull-request"
alias dev="cd ~/Sites/www"

# ls shortcuts
alias l="ls -lFh --color" # List files colorized in long format
alias la="ls -laFh" # List all files colorized in long format, including dot files
alias lsd='ls -lFh --color | grep "^d"' # List only directories

# Networking shortcuts
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"
alias whois="whois -h whois-servers.net"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias flush="dscacheutil -flushcache"

# Edit local hosts file
alias hosts="sudo code /etc/hosts"

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# Cleanup shortcuts
# Recursively delete `.DS_Store` files
alias dscleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Empty the Trash on all mounted volumes and clear system logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide hidden files or desktop files
alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Add support for https://gitignore.io
# Example usage: gi macos,wordpress >> .gitignore
function gi() { curl https://www.toptal.com/developers/gitignore/api/$@; }

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

# Import the production database from Pantheon
function dbsync() {
	SITE=${PWD##*/};
	terminus backup:create --element=db $SITE.live;
	terminus backup:get --element=db --to=$SITE.sql.gz $SITE.live;
	gunzip $SITE.sql.gz;
	wp db import $SITE.sql;
	rm $SITE.sql;
}

# Import the production uploads from Pantheon
# Requires the terminus rsync plugin (https://github.com/pantheon-systems/terminus-rsync-plugin)
function filesync() {
	SITE=${PWD##*/};
	terminus rsync $SITE.live:files/ ./wp-content/uploads
}
