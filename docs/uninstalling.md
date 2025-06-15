# Uninstalling

To remove Nix Toolbox from your system, delete the toolbox container:

=== "Toolbox"

    ```shell
    toolbox rm -f nix-toolbox-42
    ```

=== "Distrobox"

    ```shell
    distrobox rm -f nix-toolbox-42
    ```

To remove the nix store and the links to Nix programs:

```shell
sudo rm -rf ~/.local/share/nix/ ~/.nix-profile ~/.config/nix-toolbox
```

To remove also the Home Manager configuration:

```shell
rm -rf ~/.config/home-manager
```
