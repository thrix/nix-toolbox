#!/bin/bash

#
# Setup script for nix inside the container.
#
# Runs only once, on first entry of the toolbox container.
#

# Helpers
info() { echo -e "\033[0;32m[+] $*\033[0m"; }
error() { echo -e "\033[0;31m$*\033[0m"; }

# Nix does not like home being a symlink, use the real path instead
HOME=$(readlink -f "$HOME")
export HOME

# Install nix with flakes
if [ ! -e "/nix" ]; then

    # Refuse to start if existing home-manager generations found
    if [ -n "$(ls "$HOME/.local/state/nix/profiles/home-manager*" 2>/dev/null)" ] || [ -e "$HOME/.local/state/home-manager/gcroots/current-home" ]; then
        error "Error: Previous generations of home-manager found for your user. Cannot continue."
        echo
        error "This can be caused by:"
        echo
        error "* creating another 'nix-toolbox' with 'home-manager' container (only a single container is supported)"
        error "* recreating 'nix-toolbox' container"
        error "* you have an existing 'home-manager' installation"
        echo
        error "Remove the following files to continue (you will loose existing home-manager generations):"
        echo
        error "  rm /var/home/thrix/.local/state/nix/profiles/home-manager*"
        error "  rm /var/home/thrix/.local/state/home-manager/gcroots/current-home"
        echo
        exit 1
    fi

    info "Enabling flakes"
    sudo bash -c "mkdir -p /etc/nix; echo 'experimental-features = nix-command flakes' > /etc/nix/nix.conf"

    info "Installing nix in single-user mode"
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Source nix environment
# shellcheck source=/dev/null
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Install home-manager
if ! command -v home-manager >/dev/null; then
    if [ -e "$HOME/.config/home-manager/flake.nix" ]; then
        info "Installing home-manager from flake, using existing configuration, this might take a while"
        nix run home-manager/master -- switch -b backup
    else
        info "Installing home-manager from flake, initializing new configuration, this might take a while"
        nix run home-manager/master -- init --switch -b backup
    fi
fi

# Cleanup history
history -c
