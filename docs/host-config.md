# Host Config Module

When running Home Manager inside a nix-toolbox container on Fedora Atomic Desktops, config files managed by Home Manager are symlinks pointing to `/nix/store/...` paths.
The Nix store data lives on the host at `$XDG_DATA_HOME/nix/root/nix/` (or `$XDG_DATA_HOME/nix` for legacy installs), but the `/nix` bind mount only exists inside the container.
Host-side programs like sway, waybar, foot, or firefox cannot resolve these symlinks — the config files are effectively invisible to the host.

The `hostConfig` Home Manager module solves this by materializing symlinks as real files after each `home-manager switch`.

## How it works

The module generates two Home Manager activation scripts:

1. **`restoreNixLinks`** (runs before `checkLinkTargets`) — restores symlink backups (`.lnk` files) so Home Manager can replace them, and cleans up leftover `.new` temp files from any previous partial run.
2. **`createHostConfig`** (runs after `linkGeneration`) — copies each symlink to a real file using an atomic copy-before-move pattern, so a failed copy never leaves you without a config file.

## Installation

The module is available as a flake output from [thrix/nix-config](https://github.com/thrix/nix-config).

Add it to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-config = {
      url = "github:thrix/nix-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, nix-config, ... }: {
    homeConfigurations."alice" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        nix-config.homeManagerModules.hostConfig
        ./home.nix
      ];
    };
  };
}
```

## Usage

In your `home.nix`:

```nix
hostConfig = {
  enable = true;

  # Automatically materialize all xdg.desktopEntries as real files
  xdgDesktopEntries = true;

  # Any other Home Manager-managed files the host needs to read
  files = [
    ".config/sway/config"
    ".config/waybar/config"
    ".config/waybar/style.css"
    ".config/foot/foot.ini"
  ];
};
```

## Options

### `hostConfig.enable`

Whether to enable host config file materialization.

**Type:** `boolean`
**Default:** `false`

### `hostConfig.files`

Home-relative paths to materialize as real files for host access.
Home Manager normally creates symlinks into the Nix store, which the host cannot follow from outside the toolbox container.
Files listed here are copied to real files after each switch.

**Type:** `list of string`
**Default:** `[]`

### `hostConfig.xdgDesktopEntries`

When `true`, automatically materialize all desktop entries declared via `xdg.desktopEntries`.
Paths are derived directly from that option — adding a new entry in `xdg.desktopEntries` is sufficient, no need to list it in `files` too.

This is useful for sharing Nix-installed desktop applications (such as 1Password, Discord, or Dropbox) with the host's application launcher.

**Type:** `boolean`
**Default:** `false`
