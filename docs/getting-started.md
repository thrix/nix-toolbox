# Getting Started

Starting with Nix Toolbox is really simple.
Make sure you are running a system with [Toolbx](https://containertoolbx.org/) or [Distrobox](https://distrobox.it/) installed.

## Available Images

Nix Toolbox provides container images for the following Fedora releases:

- **Fedora 42**: `ghcr.io/thrix/nix-toolbox:42`
- **Fedora 43**: `ghcr.io/thrix/nix-toolbox:43`
- **Fedora 44**: `ghcr.io/thrix/nix-toolbox:44`
- **Fedora Rawhide**: `ghcr.io/thrix/nix-toolbox:rawhide`

## Create a Container

Pick your Fedora release and create a Nix Toolbox container:

=== "Fedora 42"

    === "Toolbox"

        ```shell
        toolbox create --image ghcr.io/thrix/nix-toolbox:42
        ```

    === "Distrobox"

        ```shell
        distrobox create --image ghcr.io/thrix/nix-toolbox:42
        ```

=== "Fedora 43 (latest)"

    === "Toolbox"

        ```shell
        toolbox create --image ghcr.io/thrix/nix-toolbox:43
        ```

    === "Distrobox"

        ```shell
        distrobox create --image ghcr.io/thrix/nix-toolbox:43
        ```

=== "Fedora 44 (Branched)"

    === "Toolbox"

        ```shell
        toolbox create --image ghcr.io/thrix/nix-toolbox:44
        ```

    === "Distrobox"

        ```shell
        distrobox create --image ghcr.io/thrix/nix-toolbox:44
        ```

=== "Fedora Rawhide (Development)"

    === "Toolbox"

        ```shell
        toolbox create --image ghcr.io/thrix/nix-toolbox:rawhide
        ```

    === "Distrobox"

        ```shell
        distrobox create --image ghcr.io/thrix/nix-toolbox:rawhide
        ```


This will create the nix-toolbox container.

## Enter the Container

The Nix and Home Manager setup is then performed the first time you enter the container:

=== "Fedora 42"

    === "Toolbox"

        ```shell
        toolbox enter nix-toolbox-42
        ```

    === "Distrobox"

        ```shell
        distrobox enter nix-toolbox-42
        ```

=== "Fedora 43 (latest)"

    === "Toolbox"

        ```shell
        toolbox enter nix-toolbox-43
        ```

    === "Distrobox"

        ```shell
        distrobox enter nix-toolbox-43
        ```

=== "Fedora 44 (Branched)"

    === "Toolbox"

        ```shell
        toolbox enter nix-toolbox-44
        ```

    === "Distrobox"

        ```shell
        distrobox enter nix-toolbox-44
        ```

=== "Fedora Rawhide (Development)"

    === "Toolbox"

        ```shell
        toolbox enter nix-toolbox-rawhide
        ```

    === "Distrobox"

        ```shell
        distrobox enter nix-toolbox-rawhide
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

## Running Multiple Containers

You can run multiple nix-toolbox containers with different Fedora versions side by side.
All containers share the same Nix store (`~/.local/share/nix`), so packages installed in one container are immediately available in all others.

Create containers for the versions you need:

=== "Toolbox"

    ```shell
    toolbox create --image ghcr.io/thrix/nix-toolbox:42
    toolbox create --image ghcr.io/thrix/nix-toolbox:43
    ```

=== "Distrobox"

    ```shell
    distrobox create --image ghcr.io/thrix/nix-toolbox:42
    distrobox create --image ghcr.io/thrix/nix-toolbox:43
    ```

Then switch between them freely:

=== "Toolbox"

    ```shell
    toolbox enter nix-toolbox-42   # enter the first container
    toolbox enter nix-toolbox-43   # enter the second container
    ```

=== "Distrobox"

    ```shell
    distrobox enter nix-toolbox-42   # enter the first container
    distrobox enter nix-toolbox-43   # enter the second container
    ```

!!! tip

    The Nix installation and Home Manager configuration are shared across all containers.
    This means you only need to set up Nix once — subsequent containers will pick up the existing installation automatically.
