#!/bin/bash

packages=(
    "git",
    "gcc",
)

exists() {
    type "$1" &> /dev/null;
}

install_missing_packages() {
    for p in "${packages[@]}"; do
        if hash "$p" 2> /dev/null; then
            echo "$p is installed"
        else
            echo "$p is not installed"
            # Detect the platform (similar to $OSTYPE)
            OS="`uname`"
            case $OS in
                'Linux')
                    apt install "$1" || echo "$p failed to install"
                    ;;
                'Darwin')
                    brew install "$1" || echo "$p failed to install"
                    ;;
                *) ;;
            esac
            echo "---------------------------------------------------------"
            echo "Done "
            echo "---------------------------------------------------------"
        fi
    done
}

sudo -v

while true; do
    sudo -n true; 
    sleep 60; 
    kill -0 "$$" || exit; 
done 2> /dev/null &

add-apt-repository ppa:neovim-ppa/unstable

apt update

install_missing_packages || echo "failed to install missing packages"

echo "---------------------------------------------------------"
echo "dotfiles"
echo "---------------------------------------------------------"

export DOTFILES="$HOME/.dotfiles"

if [ -f "$DOTFILES" ]; then
    echo "Dotfiles have already been cloned into the home dir"
else
    echo "Cloning dotfiles"
fi

cd "$DOTFILES" || "Didn't cd into dotfiles"
git submodule update --init --recursive

cd "$HOME" || exit

echo "---------------------------------------------------------"
echo "You'll need to log out for this to take effect"
echo "---------------------------------------------------------"

# Install rust
if ! exists rustc; then
    curl https://sh.rustup.rs -sSf | sh
fi

# Install Starship
#if ! exists starship; then
#    curl -sS https://starship.rs/install.sh | sh
#    echo eval "$(starship init bash)" >> ~/.bashrc
#fi

crates=(
    "sccache",
    "coreutils",
    "starship",
    "exa",
    "du-dust",
    "bat",
    "zellij",
    "mprocs",
    "gitui",
    "irust",
    "bacon",
    "porsmo",
    "rtx",
    "ripgrep",
)

for p in "${crates[@]}"; do
        if hash "$p" 2> /dev/null; then
            echo "$p is installed"
        else
            echo "$p is not installed"
            # Detect the platform (similar to $OSTYPE)
            OS="`uname`"
            case $OS in
                'Linux')
                    cargo install "$1" || echo "$p failed to install"
                    ;;
                *) ;;
            esac
            echo "---------------------------------------------------------"
            echo "Done "
            echo "---------------------------------------------------------"
        fi
    done

if hash "exa" 2> /dev/null; then
    echo alias ls=exa >> "$HOME/.bashrc"
fi

if hash "bat" 2> /dev/null; then
    echo alias ls=cat >> "$HOME/.bashrc"
fi

if hash "ripgrep" 2> /dev/null; then
    echo alias ls=grep >> "$HOME/.bashrc"
fi

install_helix_editor() {
    git clone https://github.com/helix-editor/helix
    cd helix
    cargo install --locked --path helix-term
    cd ..
}

$DOTFILES/install

echo "done"

exit 0

