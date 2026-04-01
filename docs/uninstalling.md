# Uninstalling

To remove Nix Toolbox from your system, delete the toolbox container:

=== "Fedora 42"

    === "Toolbox"

        ```shell
        toolbox rm -f nix-toolbox-42
        ```

    === "Distrobox"

        ```shell
        distrobox rm -f nix-toolbox-42
        ```

=== "Fedora 43 (latest)"

    === "Toolbox"

        ```shell
        toolbox rm -f nix-toolbox-43
        ```

    === "Distrobox"

        ```shell
        distrobox rm -f nix-toolbox-43
        ```

=== "Fedora 44 (Branched)"

    === "Toolbox"

        ```shell
        toolbox rm -f nix-toolbox-44
        ```

    === "Distrobox"

        ```shell
        distrobox rm -f nix-toolbox-44
        ```

=== "Fedora Rawhide (Development)"

    === "Toolbox"

        ```shell
        toolbox rm -f nix-toolbox-rawhide
        ```

    === "Distrobox"

        ```shell
        distrobox rm -f nix-toolbox-rawhide
        ```

To remove the Nix store and the links to Nix programs:

```shell
sudo rm -rf ~/.local/share/nix/ ~/.nix-profile ~/.config/nix-toolbox
```

To remove also the Home Manager configuration:

```shell
rm -rf ~/.config/home-manager
```
