# Uninstalling

To remove Nix Toolbox from your system, delete the toolbox container:

```shell
toolbox rm -f nix-toolbox-42
```

To remove the nix store and the links to Nix programs:

```shell
sudo rm -rf ~/.local/share/nix/ ~/.nix-profile ~/.config/nix-toolbox
```

To remove also the Home Manager configuration:

```shell
rm -rf ~/.config/home-manager
```
