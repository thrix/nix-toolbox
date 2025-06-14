# Architecture

This page describes the technical architecture of nix-toolbox and how it integrates Nix and Home Manager into a Fedora Toolbox container.

## Overview

Nix-toolbox is built on top of [Fedora Toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/), extending it with the Nix package manager and optional Home Manager support.
The architecture follows a layered approach:

1. **Base Layer**: Fedora Toolbox container image
2. **Enhancement Layer**: Nix package manager installation and configuration
3. **Management Layer**: Home Manager for declarative environment management
4. **Integration Layer**: Profile script for seamless user experience

## Container Image Structure

The nix-toolbox container is built using a simple `Containerfile` that:

- Extends the official `registry.fedoraproject.org/fedora-toolbox` image
- Installs [gum](https://github.com/charmbracelet/gum) for enhanced CLI user experience
- Copies the `nix.sh` profile script to `/etc/profile.d/`

```dockerfile
FROM registry.fedoraproject.org/fedora-toolbox:$FEDORA_VERSION
RUN dnf -y install gum
COPY nix.sh /etc/profile.d/nix.sh
```

## The nix.sh Profile Script

The core of nix-toolbox's functionality is the `nix.sh` profile script located at `/etc/profile.d/nix.sh`.
This script is automatically executed when users start a shell session in the container and handles:

### Environment Setup

- **XDG Compliance**: Ensures `XDG_DATA_HOME` and `XDG_CONFIG_HOME` are properly set
- **Home Directory**: Resolves symlinks in `$HOME` since Nix requires a real path
- **Configuration Directory**: Creates `~/.config/nix-toolbox/` for storing nix-toolbox specific settings

### Nix Installation and Management

The script implements a sophisticated Nix installation strategy:

1. **Detection**: Checks if `/nix` directory exists
2. **First-time Setup**: If no Nix store is found:
   - Enables `nix-command` and `flakes` in `/etc/nix/nix.conf`
   - Creates a bind mount from `$XDG_DATA_HOME/nix` to `/nix`
   - Installs Nix in single-user mode via the official installer
3. **Runtime Mount**: Ensures `/nix` is properly mounted on each container start
4. **Environment Sourcing**: Sources the Nix environment from `~/.nix-profile/etc/profile.d/nix.sh`

### Storage Strategy

Nix-toolbox uses a bind mount approach for persistent storage:

- **Host Storage**: Nix store is persisted in `$XDG_DATA_HOME/nix` on the host
- **Container Mount**: Bind-mounted to `/nix` inside the container
- **Benefits**:
  - Survives container recreation
  - Shares storage between multiple nix-toolbox containers
  - Keeps the Nix store outside the container filesystem

### Home Manager Integration

The script provides optional Home Manager installation with user choice:

1. **Detection**: Checks if Home Manager is already installed
2. **Existing Configuration**: If `~/.config/home-manager` exists, uses it directly
3. **Template Selection**: Offers users a choice between:
   - nix-toolbox template (future feature)
   - Empty configuration initialized by Home Manager
4. **Installation**: Uses `nix run home-manager/master` for installation
5. **Skip Option**: Allows users to skip Home Manager entirely

### User Experience Features

- **Interactive Prompts**: Uses `gum` for enhanced CLI interactions
- **Progress Indication**: Shows spinners during long-running operations
- **Logging**: Provides clear status messages using `gum log`
- **Error Handling**: Validates dependencies and provides meaningful error messages
- **History Cleanup**: Clears shell history to avoid polluting user sessions

## Configuration Management

Nix-toolbox maintains several configuration files in `~/.config/nix-toolbox/`:

- `home-manager.skipped`: Marker file when user skips Home Manager
- `home-manager.setup`: Marker file for automated Home Manager setup
- `home-manager.template`: Stores user's template choice

## Integration with Fedora Atomic

The architecture is specifically designed for Fedora Atomic Desktops:

- **Immutable Host**: Respects the immutable nature of the host filesystem
- **User Space**: All modifications happen in user space or containers
- **XDG Standards**: Follows XDG Base Directory specifications
- **Toolbox Compatibility**: Maintains full compatibility with existing toolbox workflows

## Security Considerations

- **Single-user Mode**: Nix is installed in single-user mode, avoiding multi-user daemon complexity
- **Sudo Requirements**: Minimal sudo usage inside the container only for:
  - Creating `/etc/nix/nix.conf`
  - Setting up the `/nix` bind mount
- **User Permissions**: All package installations and Home Manager operations run as the user

This architecture provides a seamless integration of Nix ecosystem tools while maintaining the simplicity and isolation benefits of Fedora Toolbox.
