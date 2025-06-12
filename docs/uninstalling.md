# Uninstalling

To remove Nix Toolbox from your system, delete the toolbox container:

```shell
toolbox rm -f nix-toolbox-42
```

To remove the nix store and the links to Nix programs:

```shell
sudo rm -rvf ~/.local/share/nix/ ~/.nix-profile
```
