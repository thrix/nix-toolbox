#!/bin/bash -e

#
# Bash profile script for for nix-toolbox.
#
# For technical details see https://thrix.github.io/nix-toolbox/architecture
#

# Sanity
if ! command -v "gum" >/dev/null; then
    echo "ERROR: gum command not found, cannot continue"
    exit 1
fi

# Nix does not like home being a symlink, use the real path instead
HOME=$(readlink -f "$HOME")
export HOME

# Make sure XDG_DATA_HOME and XDG_CONFIG_HOME set, needed for CI
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"

# Create nix-toolbox config dir
NIX_TOOLBOX_CONFIG_DIR="$XDG_CONFIG_HOME/nix-toolbox"
[ ! -e "$NIX_TOOLBOX_CONFIG_DIR" ] && mkdir -p "$NIX_TOOLBOX_CONFIG_DIR"

# Settings
NIX_TOOLBOX_HM_SKIPPED="$NIX_TOOLBOX_CONFIG_DIR/home-manager.skipped"
NIX_TOOLBOX_HM_SETUP="$NIX_TOOLBOX_CONFIG_DIR/home-manager.setup"
NIX_TOOLBOX_HM_TEMPLATE="$NIX_TOOLBOX_CONFIG_DIR/home-manager.template"

# Gum default settings
export GUM_SPIN_SPINNER="points"
export GUM_SPIN_SHOW_ERROR="yes"
export GUM_SPIN_TITLE="Please wait, this might take a while"

# Install nix with flakes if no Nix store found
if [ ! -e "/nix" ]; then
    gum format <<EOF

# Welcome to **nix-toolbox**!

Running first-time setup.

See [getting started documentation](https://thrix.github.io/nix-toolbox/#getting-started)
for more information.
EOF

    echo

    gum log -l info "Enabling nix-command and flakes in /etc/nix/nix.conf"
    sudo mkdir -p /etc/nix
    sudo bash -c "echo 'experimental-features = nix-command flakes' > /etc/nix/nix.conf"

    gum log -l info "Creating /nix bind-mounted to $XDG_DATA_HOME/nix"
    mkdir -p "$XDG_DATA_HOME/nix"
    sudo mkdir /nix
    sudo mount --bind "$XDG_DATA_HOME/nix" /nix

    gum log -l info "Installing nix in single-user mode"
    gum spin -- bash -c "sh <(curl -sL https://nixos.org/nix/install) --no-daemon 2>&1"
fi

# Mount /nix if not mounted, required after restart
if ! mount | grep -q /nix; then
    sudo mount --bind "$XDG_DATA_HOME/nix" /nix
fi

# Source nix environment
# shellcheck source=/dev/null
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Install Home Manager
if ! command -v home-manager >/dev/null && [ ! -e "$NIX_TOOLBOX_HM_SKIPPED" ]; then
    CONFIG_HM="$XDG_CONFIG_HOME/home-manager"

    if [ -e "$CONFIG_HM" ]; then
        gum log -l info "Installing Home Manager and initializing from existing config $CONFIG_HM"
        gum spin -- nix run home-manager/master -- switch -b backup
    else
        if [ -e "$NIX_TOOLBOX_HM_SETUP" ] || gum confirm "Setup Home Manager?"; then
            # TODO: remove once templates available
            echo "none" > "$NIX_TOOLBOX_HM_TEMPLATE"
            if [ ! -e "$NIX_TOOLBOX_HM_TEMPLATE" ]; then
                choice=$(gum choose --header "Choose Home Manager configuration template" --limit 1 \
                    "nix-toolbox; see https://thrix.github.io/nix-toolbox/home-manager-template" \
                    "none; empty configuration will be initialized by Home Manager"
                )
            else
                choice=$(cat "$NIX_TOOLBOX_HM_TEMPLATE")
            fi

            case "$choice" in
                nix-toolbox*)
                    gum log -l info "Cloning nix-toolbox Home Manager template to $CONFIG_HM"
                    echo "TODO"
                    ;;
                none*)
                    gum log -l info "Installing Home Manager and initializing an empty configuration to $CONFIG_HM"
                    gum spin --show-stdout -- nix run home-manager/master -- init --switch -b backup
                    ;;
            esac
        else
            gum log -l info "Skipped Home Manager installation"
            touch "$NIX_TOOLBOX_HM_SKIPPED"
        fi
    fi
fi

# Cleanup history
history -c
