#!/bin/sh
# Forked from https://github.com/afragen/mac-clean-install

# First, grab the script's working directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Then start things off from the home directory, for good measure
cd ~

# Add TouchID support for sudo (if not already added)
if ! grep -Fq "pam_tid.so" /etc/pam.d/sudo; then
    echo "Adding TouchID support to sudo."
    (echo "auth       sufficient     pam_tid.so" && cat /etc/pam.d/sudo) > /tmp/sudo_pam_tid.so
    sudo mv /tmp/sudo_pam_tid.so /etc/pam.d/sudo
fi

# Ask for the administrator password upfront
sudo -v;

###############################################################################

# Ask in advance about which sections to execute
default_computer_name=$(sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName)
read -p "Set new computer name [$default_computer_name]" computer_name
computer_name=${computer_name:-$default_computer_name}
computer_name_safe=$( echo $computer_name | sed 's/[\ \.]/-/g' )

read -p "Install basic utilities for homebrew (including cask, mas, coreutils, etc.) ([y]/n)? " homebrew_utils
homebrew_utils=${homebrew_utils:-y}

read -p "Install essential apps for utility, communication, and PM ([y]/n)? " homebrew_apps
homebrew_apps=${homebrew_apps:-y}

read -p "Install general develompent tools like git, gh, npm, yarn, etc. ([y]/n)? " homebrew_dev
homebrew_dev=${homebrew_dev:-y}

if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
    read -p "Generate ed25519 SSH key (for GitHub, mainly) ([y]/n)? " ssh_ed25519
    ssh_ed25519=${ssh_ed25519:-y}
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    read -p "Generate RSA SSH key (for virtually everywhere else) ([y]/n)? " ssh_rsa
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

read -p "Install web development tools ([y]/n)? " homebrew_webdev
homebrew_webdev=${homebrew_webdev:-y}

read -p "Install video production tools ([y]/n)? " homebrew_video
homebrew_video=${homebrew_video:-y}

read -p "Update macOS and app preferences ([y]/n)? " macos_prefs
macos_prefs=${macos_prefs:-y}

###############################################################################

# Set computer name (as done via System Preferences → Sharing)
if [ $computer_name != $default_computer_name ]; then
    sudo scutil --set ComputerName $computer_name
    sudo scutil --set LocalHostName $computer_name_safe
    sudo scutil --set HostName $computer_name_safe
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $computer_name_safe
fi

###############################################################################

# Install XCode (hard dependency for homebrew and other CLI utilities)
if ! command -v git >/dev/null || ! command -v gcc >/dev/null; then
    echo "Installing XCode.\n"
    xcode-select --install
fi

###############################################################################

# Create local Site's directory for web development
if [ ! -d "$HOME/Sites/www/" ]; then
    echo "Creating ~/Sites/www/ for local site development.\n"
    mkdir -p ~/Sites/www
fi

###############################################################################

# Track if we've run any brew commands for cleanup later
ran_brew=false

# Install Homebrew
if ! command -v brew >/dev/null; then
    echo "Installing Homebrew.\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew command to ~/.zprofile (default machine bash profile) for future use (without ohmyzsh)
    # eval the script for immediate use
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    ran_brew=true
fi

###############################################################################

# Install basic CLI utilities via Homebrew
if [ "$homebrew_utils" != "${homebrew_utils#[Yy]}" ]; then
    echo "Running brewfile to handle baseline homebrew config.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Tap additional repos for homebrew to track for installations
tap "homebrew/bundle"
tap "homebrew/core"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/cask-versions"
tap "homebrew/services"
tap "pantheon-systems/external"
tap "sass/sass"

# Install homebrew-managed libraries
brew "cask"
brew "mas"

# Install essential CLI utilities
brew "coreutils"
brew "findutils"
brew "libtool"
brew "tree"
brew "wget"
EOF

ran_brew=true
fi

###############################################################################

# Install essential apps via homebrew
if [ "$homebrew_apps" != "${homebrew_apps#[Yy]}" ]; then
    echo "Running brewfile to install apps for utility, communication, and PM.\n"
    brew bundle install --file=- <<EOF
# Install macOS apps for utility
cask "1password"
mas "1Password for Safari", id: 1569813296
cask "alfred"
cask "bartender"
cask "bettertouchtool"
cask "droplr"
cask "karabiner-elements"
cask "rocket" # system-wide slack-like emoji support

# Install macOS apps for communication
cask "slack"
cask "zoom"
mas "Shush", id: 496437906

# Install macOS apps for project/business management
mas "Things", id: 904280696
cask "dropbox"
cask "obsidian"
cask "adobe-creative-cloud"
EOF

ran_brew=true

# Set Karabiner preferences to load from Dropbox
rm -rf ~/.config/karabiner
ln -s ~/Dropbox/App\ Settings/karabiner ~/.config
fi

###############################################################################

# Install general dev tools via homebrew
if [ "$homebrew_dev" != "${homebrew_dev#[Yy]}" ]; then
    echo "Running brewfile to install general dev formulae.\n"
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

# Install macOS apps for development
cask "iterm2"
cask "font-menlo-for-powerline"
cask "visual-studio-code"
EOF

ran_brew=true
fi

###############################################################################

# Generate SSH keys
if [ "$ssh_ed25519" != "${ssh_ed25519#[Yy]}" ]; then
    echo "Generating ed25519 SSH key and adding to keychain.\n"
    ssh-keygen -t ed25519 -C "brian@rzen.net"
    ssh-add ~/.ssh/id_ed25519
fi
if [ "$ssh_rsa" != "${ssh_rsa#[Yy]}" ]; then
    echo "Generating RSA SSH key and adding to keychain.\n"
    ssh-keygen
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
    echo "Installing Oh My ZSH!\n"

    if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
        # run via Zsh
        zsh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
        # run via Bash
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    git clone git@github.com:zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone git@github.com:zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

# Add personal dotfiles via github
if [ "$dotfiles" != "${dotfiles#[Yy]}" ]; then
    echo "Installing personal dotfiles.\n"
    if [ ! $SCRIPT_DIR -ef ~/.dotfiles ]; then
        git clone git@github.com:brichards/dotfiles.git ~/.dotfiles
    fi
    ln -s ~/.dotfiles/.dir_colors ~/.dir_colors
    ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
    ln -s ~/.dotfiles/.zshrc ~/.zshrc
    ln -s ~/.dotfiles/eslintrc.json ~/Sites/www/eslintrc.json
    ln -s ~/.dotfiles/wp-cli.yml ~/Sites/www/wp-cli.yml
    source ~/.zshrc
fi

###############################################################################

# Install web dev tools
if [ "$homebrew_webdev" != "${homebrew_webdev#[Yy]}" ]; then

    # Install web dev utilities via homebrew
    echo "Running brewfile to install web dev formulae.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install web dev tools
brew "dnsmasq"
brew "nginx"
brew "nghttp2"
brew "openssl"
brew "mysql", restart_service: true
brew "redis", restart_service: :changed
brew "php", link: false
brew "php@7.4", link: true
brew "phpunit", link: false
brew "wp-cli"
brew "sass/sass/sass"
brew "pantheon-systems/external/terminus"
brew "rclone"
brew "rsync"

# Install macOS browsers
cask "firefox"
cask "google-chrome"
cask "hush" # silences cookie/privacy notices in Safari

# Install macOS dev apps
cask "postman"
cask "tableplus"
EOF

ran_brew=true

    # Install Terminus rsync plugin
    terminus self:plugin:install terminus-rsync-plugin

    # Install Laravel Valet (https://laravel.com/docs/9.x/valet#installation)
    if [ ! command -v valet >/dev/null ]; then
        echo "Installing and configuring Laravel Valet.\n"
        composer global require laravel/valet
        valet install
        valet use php@7.4
        cd ~/Sites/www
        valet park
    fi

    #  Add additional JS packages
    npm install eslint -g
    npm install prettier -g

    # Add additional packages for WP-CLI
    echo "Installing additional WP-CLI packages.\n"
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

    # Install WordPress Coding Standards
    echo "Installing PHPCS with WP Coding Standards.\n"
    composer global require squizlabs/php_codesniffer 
    composer global require friendsofphp/php-cs-fixer
    composer global require yoast/phpunit-polyfills
    composer global require phpcompatibility/phpcompatibility-wp:"*"
    git clone -b master git@github.com:WordPress/WordPress-Coding-Standards.git ~/Sites/wpcs

    # Get existing PHPCS isntall paths (just in case they already exist)
    phpcs_install_config=$(phpcs --config-show installed_paths);
    phpcs_install_paths=${phpcs_install_config##*:};

    # Append our new install paths for WPCS and PHPCompatibility to the existing install path(s)
    phpcs --config-set installed_paths ${phpcs_install_paths},"$HOME/Sites/wpcs","$HOME/.composer/vendor/phpcompatibility/php-compatibility","$HOME/.composer/vendor/phpcompatibility/phpcompatibility-paragonie","$HOME/.composer/vendor/phpcompatibility/phpcompatibility-wp"

    # Import base `ruleset.xml` for PHPCS
    # curl --create-dirs -o ~/Sites/wpcs/ruleset.xml https://gist.githubusercontent.com/afragen/341bc1c7f7438cf963d4f6e08f403f40/raw/ruleset.xml
fi

###############################################################################

# Install video production tools via homebrew
if [ "$homebrew_video" != "${homebrew_video#[Yy]}" ]; then
    echo "Running brewfile to install video formulae.\n"
    brew bundle install --file=- <<EOF
# Set root Applications directory as default location for app installations
cask_args appdir: "/Applications"

# Install video manipulation utilities
brew "ffmpeg"
brew "mkvtoolnix"
brew "mp4v2"
brew "mpv"
brew "youtube-dl"
brew "yt-dlp"

# Install macOS apps for video production
cask "obs"
cask "obs-ndi"
cask "screenflow"
EOF

ran_brew=true
fi

###############################################################################

# Cleanup any lost vestigials after all homebrew installations
if [ "$ran_brew" = true ]; then
    brew update && brew upgrade && brew cleanup && brew doctor
fi

###############################################################################

# Update macOS System Prefs
if [ "$macos_prefs" != "${macos_prefs#[Yy]}" ]; then
    if [ $SCRIPT_DIR -ef ~/.dotfiles ]; then
        sh ~/.dotfiles/install-macos-prefs.sh
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/brichards/dotfiles/master/install-macos-prefs.sh)"
    fi
fi
