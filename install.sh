#!/bin/sh
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/brichards/dotfiles/HEAD/install.sh)"
# Forked from https://github.com/afragen/mac-clean-install

# First, grab the script's working directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Then start things off from the home directory, for good measure
cd ~

# Add TouchID support for sudo (if not already added)
if ! grep -Fq "pam_tid.so" /etc/pam.d/sudo; then
    echo "\nAdding TouchID support to sudo.\n"
    (echo "auth       sufficient     pam_tid.so" && cat /etc/pam.d/sudo) > /tmp/sudo_pam_tid.so
    sudo mv /tmp/sudo_pam_tid.so /etc/pam.d/sudo
fi

# Ask for the administrator password upfront
sudo -v;

###############################################################################

# Ask in advance about which sections to execute

read -p "Install CLI utilities like XCode and homebrew (including cask, mas, coreutils, etc.) ([y]/n)? " cli_utils
cli_utils=${cli_utils:-y}

read -p "Install essential utilities (1Pass, Obsidian, Raycast, etc) ([y]/n)? " essential_apps
essential_apps=${essential_apps:-y}

read -p "Install work apps (Adobe CC, Slack, Things, Zoom, etc) ([y]/n)? " work_apps
work_apps=${work_apps:-y}

read -p "Install AV tooling (Audio Hijack, Ecamm Live, Elgato apps, etc) ([y]/n)? " av_tools
av_tools=${av_tools:-y}

read -p "Install video production tools ([y]/n)? " video_tools
video_tools=${video_tools:-y}

read -p "Install general develompent tools like git, gh, npm, yarn, etc. ([y]/n)? " dev_tools
dev_tools=${dev_tools:-y}

read -p "Install web development tools ([y]/n)? " web_tools
web_tools=${web_tools:-y}

if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
    read -p "Generate ed25519 SSH key (for GitHub, mainly) ([y]/n)? " ssh_ed25519
    ssh_ed25519=${ssh_ed25519:-y}
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    read -p "Generate RSA SSH key ([y]/n)? " ssh_rsa
    ssh_rsa=${ssh_rsa:-y}
fi

read -p "Add SSH key to GitHub ([y]/n)? " setup_github
setup_github=${setup_github:-y}

if [ ! -d "$HOME/.oh-my-zsh/" ]; then
    read -p "Install Oh My ZSH! ([y]/n)? " ohmyzsh
    ohmyzsh=${ohmyzsh:-y}
fi

read -p "Install personal dotfiles ([y]/n)? " dotfiles
dotfiles=${dotfiles:-y}

read -p "Update macOS and app preferences ([y]/n)? " macos_prefs
macos_prefs=${macos_prefs:-y}

###############################################################################

# Get computer name
default_computer_name=$(sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName)
read -p "Set new computer name [$default_computer_name]" computer_name
computer_name=${computer_name:-$default_computer_name}
computer_name_safe=$( echo $computer_name | sed 's/[\ \.]/-/g' )

# Set computer name (as done via System Preferences → Sharing)
if [ $computer_name != $default_computer_name ]; then
    sudo scutil --set ComputerName $computer_name
    sudo scutil --set LocalHostName $computer_name_safe
    sudo scutil --set HostName $computer_name_safe
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $computer_name_safe
fi

###############################################################################

# Track if we've run any brew commands for cleanup later
ran_brew=false

###############################################################################

# Install basic CLI utilities via Homebrew
if [ "$cli_utils" != "${cli_utils#[Yy]}" ]; then

    # Install XCode (hard dependency for homebrew and other CLI utilities)
    if ! command -v git >/dev/null || ! command -v gcc >/dev/null; then
        echo "\nInstalling XCode.\n"
        xcode-select --install
    fi

    # Install Homebrew
    if ! command -v brew >/dev/null; then
        echo "\nInstalling Homebrew.\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew command to ~/.zprofile (default machine bash profile) for future use (without ohmyzsh)
        # eval the script for immediate use
        echo >> /Users/brian/.zprofile
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/brian/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"

        ran_brew=true
    fi

    echo "\nInstalling brew bundles and core utilities.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Tap additional repos for homebrew to track for installations
tap "homebrew/bundle"
tap "homebrew/services"

# Install homebrew-managed libraries
brew "cask"
brew "mas" # mac appstore installer

# Install essential CLI utilities
brew "coreutils"
brew "findutils"
brew "jq"
brew "libtool"
brew "tree"
brew "wget"
EOF

ran_brew=true
fi

###############################################################################

# Install essential apps via homebrew
if [ "$essential_apps" != "${essential_apps#[Yy]}" ]; then
    echo "\nInstalling essential macOS utilities.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install macOS apps for utility
cask "1password"
cask "backblaze"
cask "bartender"
cask "dropbox"
cask "obsidian"
cask "raycast"
mas "1Password for Safari", id: 1569813296
mas "Hush Nag Blocker", id: 1544743900
mas "Obsidian Web Clipper", id: 6720708363
mas "Raycast Companion", id: 6738274497
mas "Wayback Machine", id: 1472432422
EOF

ran_brew=true

# cask "karabiner-elements"
# Set Karabiner preferences to load from Dropbox
# rm -rf ~/.config/karabiner
# ln -s ~/Dropbox/App\ Settings/karabiner ~/.config
fi

###############################################################################

# Install work and comms apps via homebrew
if [ "$work_apps" != "${work_apps#[Yy]}" ]; then
    echo "\nInstalling work and communication apps.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install macOS apps for work
mas "Things", id: 904280696
cask "adobe-creative-cloud"
cask "discord"
cask "notion"
cask "sf-symbols"
cask "slack"
cask "zoom"
EOF

ran_brew=true
fi

###############################################################################

# Install A/V apps
if [ "$av_tools" != "${av_tools#[Yy]}" ]; then
    echo "\nInstalling A/V Tooling.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install Elgato apps
cask "audio-hijack"
cask "ecamm-live"
cask "elgato-camera-hub"
cask "elgato-control-center"
cask "elgato-stream-deck"
cask "loopback"
EOF

ran_brew=true
fi

###############################################################################

# Install video production tools via homebrew
if [ "$video_tools" != "${video_tools#[Yy]}" ]; then
    echo "\nInstalling CLI utilities and apps for video editing.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install video manipulation utilities
brew "ffmpeg"
brew "mkvtoolnix"
brew "mp4v2"
brew "mpv"
brew "yt-dlp"

# Install video ripping utilities
cask "makemkv"
cask "vlc"

# Install macOS apps for video production
cask "descript"
cask "losslesscut"
cask "obs"
cask "obs-ndi"
cask "libndi"
cask "distroav"
cask "recut"
cask "screenflow"
EOF

ran_brew=true

# Include video transcoding tools
# https://github.com/lisamelton/video_transcoding
echo "\nInstalling video transcoding tools.\n"
sudo gem install video_transcoding
fi

###############################################################################

# Install general dev tools via homebrew
if [ "$dev_tools" != "${dev_tools#[Yy]}" ]; then
    echo "\nInstalling general development tooling.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install general dev tools
brew "git"
brew "gh"
brew "node"
brew "yarn"
brew "composer"
brew "ruby"
# brew "python"

# Install macOS apps for development
cask "iterm2"
cask "font-menlo-for-powerline"
cask "visual-studio-code"

# Install VS Code extensions
vscode "adamcaviness.theme-monokai-dark-soda"
vscode "bmewburn.vscode-intelephense-client"
vscode "bradlc.vscode-tailwindcss"
vscode "chouzz.vscode-better-align"
vscode "dbaeumer.vscode-eslint"
vscode "eamodio.gitlens"
vscode "editorconfig.editorconfig"
vscode "equinusocio.vsc-material-theme"
vscode "equinusocio.vsc-material-theme-icons"
vscode "ericadamski.carbon-now-sh"
vscode "esbenp.prettier-vscode"
vscode "formulahendry.auto-rename-tag"
vscode "igorsbitnev.error-gutters"
vscode "ikappas.phpcs"
vscode "jock.svg"
vscode "johnbillion.vscode-wordpress-hooks"
vscode "kenhowardpdx.vscode-gist"
vscode "mechatroner.rainbow-csv"
vscode "ms-python.isort"
vscode "ms-python.python"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode.sublime-keybindings"
vscode "neilbrayfield.php-docblocker"
vscode "persoderlind.vscode-phpcbf"
vscode "pkief.material-icon-theme"
vscode "rafamel.subtle-brackets"
vscode "spaceribs.webvtt-language"
vscode "wordpresstoolbox.wordpress-toolbox"
vscode "yummygum.city-lights-icon-vsc"
EOF

ran_brew=true
fi

###############################################################################

# Install web dev tools
if [ "$web_tools" != "${web_tools#[Yy]}" ]; then

    # Install web dev utilities via homebrew
    echo "\nInstalling web development tooling.\n"
    brew bundle install --file=- <<EOF

# Tap additional homebrew repos
tap "pantheon-systems/external"
tap "sass/sass"

# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install web dev tools
brew "dnsmasq"
brew "nginx"
brew "nghttp2"
brew "openssl"
brew "mysql", restart_service: :changed
brew "redis", restart_service: :changed
brew "php", restart_service: :changed
brew "phpunit", link: false
brew "wp-cli"
brew "sass/sass/sass"
brew "pantheon-systems/external/terminus"
brew "rclone"
brew "rsync"

# Install macOS dev apps
cask "postman"
cask "tableplus"
EOF

ran_brew=true

    # Install Terminus rsync plugin
    terminus self:plugin:install terminus-rsync-plugin

    # Create local Site's directory for web development
    if [ ! -d "$HOME/Sites/www/" ]; then
        echo "\nCreating ~/Sites/www/ for local site development.\n"
        mkdir -p ~/Sites/www
    fi

    # Add composer binaries to path
    PATH=$PATH:~/.composer/vendor/bin

    # Install Laravel Valet (https://laravel.com/docs/9.x/valet#installation)
    if ! command -v valet 2>&1 >/dev/null; then
        echo "\nInstalling and configuring Laravel Valet.\n"
        composer global require laravel/valet
        valet install
        cd ~/Sites/www
        valet park
    fi

    #  Add additional JS packages
    npm install eslint -g
    npm install prettier -g
    npm install vercel -g

    # Add additional packages for WP-CLI
    echo "\nInstalling additional WP-CLI packages.\n"
    wp package install aaemnnosttv/wp-cli-login-command
    wp package install aaemnnosttv/wp-cli-valet-command
    wp package install brichards/wp-cli-random-content
    wp package install boxuk/dictator
    wp package install runcommand/hook
    wp package install runcommand/query-debug
    wp package install wp-cli/dist-archive-command
    wp package install wp-cli/profile-command
    wp package install wp-cli/restful
    wp package install wp-cli/scaffold-package-command

    # Install WordPress Coding Standards and tests
    echo "\n\nInstalling PHPCS with WP Coding Standards.\n"
    composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
    composer global require --dev wp-coding-standards/wpcs
    composer global require --dev friendsofphp/php-cs-fixer
    composer global require --dev yoast/phpunit-polyfills
    
    # Get existing PHPCS isntall paths (if they already exist)
    phpcs_install_config=$(phpcs --config-show installed_paths);
    phpcs_install_paths=${phpcs_install_config##*:};
    
    # Append our new install paths for WPCS and PHPCompatibility to the existing install path(s)
    phpcs --config-set installed_paths ${phpcs_install_paths},"$HOME/Sites/wpcs","$HOME/.composer/vendor/phpcompatibility/php-compatibility","$HOME/.composer/vendor/phpcompatibility/phpcompatibility-paragonie","$HOME/.composer/vendor/phpcompatibility/phpcompatibility-wp"

    # Import base `ruleset.xml` for PHPCS
    # curl --create-dirs -o ~/Sites/wpcs/ruleset.xml https://gist.githubusercontent.com/afragen/341bc1c7f7438cf963d4f6e08f403f40/raw/ruleset.xml
fi

###############################################################################

# Generate SSH keys
if [ "$ssh_ed25519" != "${ssh_ed25519#[Yy]}" ]; then
    echo "\nGenerating ed25519 SSH key and adding to keychain.\n"
    ssh-keygen -t ed25519 -C "brian@rzen.net"
    ssh-add ~/.ssh/id_ed25519
fi
if [ "$ssh_rsa" != "${ssh_rsa#[Yy]}" ]; then
    echo "\nGenerating RSA SSH key and adding to keychain.\n"
    ssh-keygen -t rsa -b 4096 -C "brian@rzen.net"
    ssh-add ~/.ssh/id_rsa
fi

###############################################################################

# Add SSH key to GitHub
if [ "$setup_github" != "${setup_github#[Yy]}" ]; then
    gh auth login
fi

###############################################################################

# Install Oh My ZSH! and plugins
if [ "$ohmyzsh" != "${ohmyzsh#[Yy]}" ]; then
    echo "\nInstalling Oh My ZSH!\n"

    if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
        # run via Zsh
        zsh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
        # run via Bash
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    gh repo clone zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    gh repo clone zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    gh repo clone joel-porquet/zsh-dircolors-solarized $ZSH_CUSTOM/plugins/zsh-dircolors-solarized
fi

###############################################################################

# Add personal dotfiles via github
if [ "$dotfiles" != "${dotfiles#[Yy]}" ]; then
    echo "\nInstalling personal dotfiles.\n"
    if [ ! $SCRIPT_DIR -ef ~/.dotfiles ]; then
        gh repo clone brichards/dotfiles ~/.dotfiles
    fi
    ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
    ln -sf ~/.dotfiles/.zshrc ~/.zshrc
    ln -sf ~/.dotfiles/eslintrc.json ~/Sites/www/eslintrc.json
    ln -sf ~/.dotfiles/wp-cli.yml ~/Sites/www/wp-cli.yml
    source ~/.zshrc
fi

###############################################################################

# Cleanup any lost vestigials after all homebrew installations
if [ "$ran_brew" = true ]; then
    brew update && brew upgrade && brew cleanup && brew doctor
fi

###############################################################################

# Update macOS System Prefs
if [ "$macos_prefs" != "${macos_prefs#[Yy]}" ]; then
    echo "\nTriggering install-macos-prefs.\n"
    if [ $SCRIPT_DIR -ef ~/.dotfiles ]; then
        sh ~/.dotfiles/install-macos-prefs.sh
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/brichards/dotfiles/HEAD/install-macos-prefs.sh)"
    fi
fi
