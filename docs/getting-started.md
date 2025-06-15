# Getting Started

Starting with Nix Toolbox is really simple.
Make sure you are running a system with [Toolbx](https://containertoolbx.org/) or [Distrobox](https://distrobox.it/) installed.

Create Nix Toolbox container

=== "Toolbox"

    ```shell
    toolbox create --image ghcr.io/thrix/nix-toolbox:42
    ```

=== "Distrobox"

    ```shell
    distrobox create --image ghcr.io/thrix/nix-toolbox:42
    ```

This will create the `nix-toolbox` the container.

The Nix and Home Manager setup is then performed when you first time enter the container:

=== "Toolbox"

    ```shell
    toolbox enter nix-toolbox-42
    ```

=== "Distrobox"

    ```shell
    distrobox enter nix-toolbox-42
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
