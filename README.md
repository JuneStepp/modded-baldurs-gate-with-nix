# Modded Baldur's Gate with Nix

A modded [Enhanced Edition Trilogy](https://www.gibberlings3.net/mods/other/eet/) game made declarative and easy to install using [Nix](https://nixos.org/) and [Modda](https://github.com/mleduque/modda). This was made for someone's single personal playthrough using the Steam version of the games but should be easy to adapt for your own needs.
The mods can be changed in the `flake.nix` file. If using the GOG version of the games, you should switch from `duplicate_readonly_game_dir.py` to `iedup` (also packaged here) for duplicating the game directories.

**Note:** This is Nix only i.e. no Windows. [Modda](https://github.com/mleduque/modda) can be used on its own for mostly declarative modding without Nix.

## Installation

1. Clone this repository and `cd` in.
2. Install Baldur's Gate EE 1 and 2 from Steam. Disable Steam auto game updates.
3. Add your game folders to the Nix store:
    - Baldur's Gate EE: `nix store add-path "/home/<username>/.local/share/Steam/steamapps/common/Baldur's Gate Enhanced Edition/" --name baldurs-gate-ee-2.6.6-game-folder`
    - Baldur's Gate II EE: `nix store add-path "/home/<username>/.local/share/Steam/steamapps/common/Baldur's Gate II Enhanced Edition/" --name baldurs-gate-2-ee-2.6.6-game-folder`
    - You may have to update the hashes in `flake.nix`. You can find what hash to use with `nix-store --query --hash <STORE_PATH_OUTPUTTED_FROM_A_PREVIOUS_COMMAND>`.
4. If not using NixOS, make sure FUSE (not FUSE3) is installed and available in PATH.
5. Run `nix build && nix run`, and follow the instructions. `nix build` is necessary, so that a link is made to prevent garbage collection.
6. You should be good to go! `fusermount -u out/ciopfs_games_dir_mount/ && rm -r out` can be used to reset everything if you need to rebuild.

