# Customize the PATH
export PATH=$PATH:~/bin:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/opt/coreutils/libexec/gnubin
export PATH=$PATH:~/.local/bin

# Include Git binaries
export PATH=$PATH:/usr/local/git/bin

# Include Composer binaries
export PATH=$PATH:~/.composer/vendor/bin

# Include Go binaries
export PATH=$PATH:~/go/bin

# Include WP-CLI binaries
export PATH=$PATH:~/.wp-cli/bin

# Include VS Code binaries
export PATH=$PATH:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin

# Include PHP 7.4
export PATH=/usr/local/opt/php@7.4/bin:$PATH
export PATH=/usr/local/opt/php@7.4/sbin:$PATH

# Set default editor to VS Code
export EDITOR=code

# Load oh-my-zsh plugins
# Core plugins are found in ~/.oh-my-zsh/plugins/
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(1password brew colorize common-aliases composer git git-extras github gitignore macos node npm sudo urltools vscode wp-cli zsh-autosuggestions zsh-syntax-highlighting zsh-dircolors-solarized)

# Path to oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load (stored in ~/.oh-my-zsh/themes/)
ZSH_THEME="agnoster"

# Set default user (removes from prompt if matches current user)
DEFAULT_USER="brian"

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

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
alias code="code -n"
alias yt="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"

# Git shortcuts
alias pr="gh pr create"
alias dev="cd ~/Sites/www"

# Networking shortcuts
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"
alias whois="whois -h whois-servers.net"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias flush="dscacheutil -flushcache"

# Edit local hosts file
alias hosts="sudo ${=EDITOR} /etc/hosts"

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# Cleanup shortcuts
# Recursively delete `.DS_Store` files
alias dscleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Empty the Trash on all mounted volumes and clear system logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide desktop files (useful for presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Install a new WP site
function wpinstall() {
	mkdir -p ~/Sites/www/$@ && cd $_;
	wp core download;
	wp core config --dbname=$@;
	wp config set WP_DEBUG true --raw;
	wp db create;
	wp core install --url=https://$@.test --title=$( tr '[A-Z]' '[a-z]' <<< $@ );
	wp login install --activate;
	valet secure $@;
	wp login as brian --launch;
}

# Individually update and commit plugins on a WP site
function pluginupdate() {
	for plugin in $(wp plugin list --update=available --fields=name,version,update_version --format=csv);
	do
		IFS="," read -r name old new <<< "$plugin"
		if [ $name = "name" ]; then
			continue
		fi
		wp plugin update $name &&
		git add -A ./wp-content/plugins/$name &&
		git commit -m "Update plugin $name from $old to $new"
	done;
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

# Deploy to pantheon
# Usage: deploy both OR deploy test OR deploy live
function deploy() {
	SITE=${PWD##*/};
	if [[ $1 == "both" ]]; then
		terminus env:deploy $SITE.test && terminus env:deploy $SITE.live;
	else
		terminus env:deploy $SITE.$1;
	fi
}

function webm2mp4() {
	echo "\nConverting $@ to ${@%.*}.mp4\n"
	ffmpeg -i $@ -c:v copy ${@%.*}.mp4
}

function splitepisodes() {
	# Confirm mkvmerge is installed
	command -v mkvmerge >/dev/null 2>&1 || { print -u2 "splitepisodes: mkvmerge not found — install with: brew install mkvtoolnix"; return 1 }

	# Print full help on -h, --help, or when no args provided
	if (( $# == 0 )) || [[ -n "${@[(r)-h]}${@[(r)--help]}" ]]; then
		cat <<'EOF'
splitepisodes — split a multi-episode MKV into one file per episode

USAGE
  splitepisodes <filename> [options]
  splitepisodes -h | --help

DESCRIPTION
  Cuts a single MKV that holds several back-to-back TV episodes (e.g. a
  full-disc rip) into individual episode files at chapter boundaries, using
  mkvmerge, then renames each piece to a Plex/Jellyfin/Infuse-friendly
  "Output - SxxEyy.mkv". The filename is positional; everything else is an
  order-independent flag.

OPTIONS
  -i, --input <file>      Give the source file as a flag instead of
                          positionally (positional is default).
  -o, --output <name>     Base name for results (no extension needed).
                          Default: the source filename without its extension,
                          written alongside the source.
  -s, --season <n>        Season number used in the SxxEyy tag.   Default: 1
  -e, --episode <n>       Episode number for the FIRST piece; the
                          rest increment from there.              Default: 1
  -c, --chapters <list>   Comma-separated chapter numbers at which a NEW
                          episode BEGINS (passed to mkvmerge --split
                          chapters:). Default: 5,9,13,17,21,25,29,33
                          (i.e. 4 chapters per episode)
  -h, --help              Show this help.

OUTPUT
  Zero-padded, e.g.:  "Output - S01E01.mkv", "Output - S01E02.mkv", ...

EXAMPLES
  # Defaults: season 1, from episode 1, 4 chapters per episode
  splitepisodes Disc1.mkv

  # Custom name, season 2, numbering continues at episode 5
  splitepisodes Disc2.mkv -o "Awesome Show" -s 2 -e 5

  # Change ONLY the split points — no need to restate the other options
  splitepisodes Disc3.mkv -c 6,11

NOTES
  • Requires mkvmerge:  brew install mkvtoolnix
  • The chapter list marks where each episode STARTS, not its length.
  • Inspect chapters first with:  mkvinfo <file> | grep -i chapter
EOF
		(( $# > 0 ))   # rc 0 when --help was passed, rc 1 when called with no args
		return
	fi

	# Set default values
	local input="" output="" chapter_list="5,9,13,17,21,25,29,33"
	local season=1 start_episode=1

	# Set flag-based inputs
	while (( $# )); do
		case "$1" in
			-o|--output|-s|--season|-e|--episode|-c|--chapters|-i|--input)
				(( $# >= 2 )) || { print -u2 "splitepisodes: $1 requires a value"; return 1 }
				case "$1" in
					-o|--output)   output="$2" ;;
					-s|--season)   season="$2" ;;
					-e|--episode)  start_episode="$2" ;;
					-c|--chapters) chapter_list="$2" ;;
					-i|--input)    input="$2" ;;
				esac
				shift 2 ;;
			--) shift; [[ -n "${1:-}" ]] && { input="$1"; shift } ;;
			-*) print -u2 "splitepisodes: unknown option: $1 (try --help)"; return 1 ;;
			*)  input="$1"; shift ;;
		esac
	done

	# Validate inputs
	[[ -n "$input" ]] || { print -u2 "splitepisodes: no input file given (try --help)"; return 1 }
	[[ "$season" == <-> ]]        || { print -u2 "splitepisodes: --season must be a number (got: $season)"; return 1 }
	[[ "$start_episode" == <-> ]] || { print -u2 "splitepisodes: --episode must be a number (got: $start_episode)"; return 1 }
	[[ -f "$input" ]] || { print -u2 "splitepisodes: input file not found: $input"; return 1 }

	# Build the output filename
	output="${output:-${input:r}}"   # default: source name minus extension
	output="${output%.mkv}"          # tolerate an explicit ".mkv" on --output
	season=$(( 10#$season ))         # 10# strips leading zeros (avoids octal)
	start_episode=$(( 10#$start_episode ))
	local tmp="${output}.split"

	print -u2 "splitepisodes: cutting '$input' at chapters ${chapter_list} ..."
	mkvmerge -o "${tmp}.mkv" --split "chapters:${chapter_list}" "$input" || return 1

	# Rename each split piece to "<output> - SxxEyy.mkv".
	local -i index=0
	local file tag
	for file in "${tmp}"-*.mkv(N); do
		tag="$(printf 'S%02dE%02d' "$season" "$(( start_episode + index ))")"
		mv -- "$file" "${output} - ${tag}.mkv"
		print -u2 "  -> ${output} - ${tag}.mkv"
		(( index++ ))
	done

	if (( index == 0 )); then
		print -u2 "splitepisodes: no episodes produced — check the chapter list and that '$input' actually has chapters."
		return 1
	fi
	print -u2 "splitepisodes: done — created ${index} episode files."
}
