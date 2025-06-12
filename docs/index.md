# Nix Toolbox - Fedora Toolbox 🌶️ with Nix and Home Manager

This project builds on top of [Fedora Toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/) container image and adds Nix package manager and optionally Home Manager for the following benefits:

* The easiest way to get Nix and Home Manager working on Fedora Silverblue and it's flavors
* Simple access to 100k+ packages in the [Nix Packages](https://search.nixos.org/packages) collection
* Support for Nix-based development environment used by various open-source projects
* Use Home Manager to manage your home environment as code, and partially also system environment

## Getting Started

Starting with Nix Toolbox is really simple.
Make sure you are running a system with [Toolbx](https://containertoolbx.org/) installed.

!!! note

    We are investigating how to run Nix Toolbox with `distrobox`.
    Until that time, using of `toolbox` is required.

Create Nix Toolbox container

```shell
toolbox create --image ghcr.io/thrix/nix-toolbox:42
```

This will create the `nix-toolbox` the container.

The Nix and Home Manager setup is then performed when you first time enter the container:

```shell
toolbox enter nix-toolbox-42
```

??? info "Example output"

    ```
    TBD
    ```

!!! note

    Do not be afraid, the next start of the container will be as quick as with Fedora Toolbox.

!!! note

    Depending on your setup, the first time setup can take a long time, especially if you already have some Home Manager configuration available.

The Home Manager configuration is optional, and you can skip it to have only the `nix` command.

After the Nix is installed, you can opt-in to install Home Manager.

!!! info

    Currently, the project provides an empty Home Manager configuration.
    Please take a look at the [Examples](examples.md) to get most out of Nix Toolbox.
    We are planning to throw out a more reasonable template later for easier onboarding.

The home manager configuration is available at `~/.config/home-manager/home.nix`.
When changing the Home Manager configuration it is a good practice to put it under revision control to keep history of your changes to be able to easily replicate the setup on another computer.

## Uninstalling

To remove Nix Toolbox from your system, delete the toolbox container:

```shell
toolbox rm -f nix-toolbox-42
```

To remove the nix store and the links to Nix programs:

```shell
sudo rm -rvf ~/.local/share/nix/ ~/.nix-profile
```
