{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      packages = import ./pkgs pkgs;
    in {
      packages =
        packages
        // {
          default = let
            bg1GameDir = pkgs.requireFile {
              name = "baldurs-gate-ee-2.6.6-game-folder";
              url = "https://store.steampowered.com/app/228280/Baldurs_Gate_Enhanced_Edition/";
              hashMode = "recursive";
              hash = "sha256:0jihfr3hixjd529y2j0dbrklx3d8mprsyx34jxmk49sq34x8mcy9";
            };
            bg2GameDir = pkgs.requireFile {
              name = "baldurs-gate-2-ee-2.6.6-game-folder";
              url = "https://store.steampowered.com/app/257350/Baldurs_Gate_II_Enhanced_Edition/";
              hashMode = "recursive";
              hash = "sha256:0c831gq9p45d73829fi92lkzr03apfckvaykv1s0hwi9s7xzc627";
            };
            modda-cfg = pkgs.writeText "modda-config.yml" (pkgs.lib.generators.toYAML {} {
              archive_cache = null;
              extract_location = null;
              weidu_path = "${pkgs.weidu}/bin/weidu";
            });
            bg1Mods = [
              (pkgs.fetchFromGitHub {
                owner = "Argent77";
                repo = "A7-DlcMerger";
                rev = "511316f40d4699bc457189839c14317a0b1b5b9d";
                hash = "sha256-xbr/ISp+turaqXOCD8etYYTEbPVC3K8HD0upbZhpc5c=";
              })
              (pkgs.fetchFromGitHub {
                owner = "Pocket-Plane-Group";
                repo = "bg1ub";
                rev = "4b5486fffbe21da5ee2e238e0ff971a2bfe22dac";
                hash = "sha256-he0ljuSDzLMX3ILJgM+km3k+jM1Lv34YMMWi61RMU6o=";
              })
            ];
            bg1-modda-manifest = pkgs.writeText "bg1-modda-manifest.yml" (pkgs.lib.generators.toYAML {} {
              version = "1";
              global = {
                lang_dir = "en_US";
                lang_preferences = ["#rx#^english" "american english"];
              };
              modules = [
                {
                  name = "DlcMerger";
                  components = [
                    1 # Merge DLC into game -> Merge "Siege of Dragonspear"
                  ];
                }
                {
                  name = "bg1ub"; # Baldur's Gate 1 Unfinished Business
                  components = [
                    0 # Ice Island Level Two Restoration
                    11 # Scar abd the Sashenstar's Daughter
                    12 # Quoningar, the Cleric
                    13 # Shilo Chen and the Ogre-Magi
                    14 # Edie, the Merchant League Applicant
                    16 # Creature Corrections
                    17 # Creature Restorations
                    18 # Creature Name Restorations
                    19 # Minor Dialogue Restorations
                    21 # Store, Tavern and Inn Fixes and Restorations
                    22 # Item Corrections and Restorations
                    29 # Duke Eltan in the Harbor Master's Building
                    30 # Nim Furlwing Encounter
                    32 # Svlast, the Fallen Paladin Encounter
                    33 # Mal-Kalen, the Ulcaster Ghost
                    34 # Chapter 6 Dialogue Restorations
                  ];
                }
              ];
            });
            bg2Mods = [
              (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
                pname = "EET";
                version = "14.1";
                src = pkgs.fetchFromGitHub {
                  owner = "Gibberlings3";
                  repo = "EET";
                  rev = "v${finalAttrs.version}";
                  hash = "sha256-qDkzIFw37eKAMIXMwvugS8TKBbWaS3U3fq+2SS1Wopk=";
                };
                installPhase = ''
                  runHook preInstall

                  mkdir -p $out
                  mv * $out/

                  runHook postInstall
                '';
                dontFixup = true;
                patches = [./mod-patches/EET/nix-binaries.patch];
              }))
              (pkgs.fetchFromGitHub {
                owner = "Renegade0";
                repo = "InfinityUI";
                rev = "v0.94";
                hash = "sha256-bh7kEApUc4UheLSHeybCNTkalVLlq7LJKh/AnsAhc/w=";
              })
              (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
                pname = "baldurs-gate-graphical-overhaul";
                version = "3.3";
                src = pkgs.fetchFromGitHub {
                  owner = "Spellhold-Studios";
                  repo = "Baldurs-Gate-Graphical-Overhaul";
                  rev = "v${finalAttrs.version}";
                  hash = "sha256-1hdtGBCwqXZ4QjqE+FlWuOVxsZusGUiiyg7xuQwVkRg=";
                };
                # Missing .mos files that apparently don't cause issues.
                # See https://web.archive.org/web/20241108055203/https://www.gibberlings3.net/forums/topic/36946-baldurs-gate-graphical-overhaul-bggo-for-eet-bgt-tutu-bgee/page/19/#comment-342103
                patches = [./mod-patches/bggo/ignore-missing-bd-mos.patch];
                installPhase = ''
                  runHook preInstall

                  mkdir -p $out
                  mv * $out/

                  runHook postInstall
                '';
                dontFixup = true;
              }))
              (pkgs.fetchFromGitHub {
                owner = "Argent77";
                repo = "HQ-SoundClips-BG2EE";
                rev = "v1.3";
                hash = "sha256-4XWq/JQjFwvhu2irkJHw7zydJmdBObKUFJ3P3yHOsps=";
              })
              (pkgs.fetchFromGitHub {
                owner = "Gibberlings3";
                repo = "BG1NPC";
                rev = "v32";
                hash = "sha256-Gi6lzWDg4Jxm8htAGRO21Wj2cVJzNU9femiKF0AVwM4=";
              })
              (pkgs.fetchFromGitHub {
                owner = "Pocket-Plane-Group";
                repo = "UnfinishedBusiness";
                rev = "25af3368107fe81d7e43a108aa02ab8066467e83";
                hash = "sha256-Ord2bKZj8VzwzDSbOfRSrxCiOd/cuXcJI+2JNiLhSsg=";
              })
              (pkgs.fetchFromGitHub {
                owner = "InfinityMods";
                repo = "Ascension";
                rev = "2.0.28";
                hash = "sha256-lKfhdx7aZt8YHwgVeRKwf59+kePdQGOLgwPMhP/qePQ=";
              })
              (pkgs.fetchFromGitHub {
                owner = "K4thos";
                repo = "EET_Tweaks";
                rev = "v1.12";
                hash = "sha256-rXOryvOpFknF7WiUzAq+UHfozW9nnQBodNs0HP0EUwo=";
              })
              (pkgs.fetchFromGitHub {
                owner = "Argent77";
                repo = "A7-HiddenGameplayOptions";
                rev = "v4.7";
                hash = "sha256-p+nQKX8u0v9zE4ZLTwO7Tc6TbW9X/gam2X4vrylu4Yw=";
              })
              (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
                pname = "SwordCoastStratagems";
                version = "35.21";
                src = pkgs.fetchFromGitHub {
                  owner = "Gibberlings3";
                  repo = "SwordCoastStratagems";
                  rev = "v${finalAttrs.version}";
                  hash = "sha256-wd8Y/muJ07oHxK1V9tYjC8EKJnP+43C75pa2Tf/40BY=";
                };
                patches = [./mod-patches/SCS/use-shebang-perl.patch];
                # Sratagems has one Perl script that needs its shebang patched.
                buildInputs = [pkgs.perl];
                installPhase = ''
                  runHook preInstall

                  # Has to be executable to get its shebang patched
                  chmod +x stratagems/ssl/ssl.pl

                  mkdir -p $out
                  mv * $out/

                  runHook postInstall
                '';
              }))
              (pkgs.fetchFromGitHub {
                owner = "Spellhold-Studios";
                repo = "Generalized-Biffing";
                rev = "v2.8";
                hash = "sha256-lBbf2rk2VeGOahR1DhenROhtsICyacgweCstg+5kQYs=";
              })
            ];
            bg2-modda-manifest = pkgs.writeText "bg2-modda-manifest.yml" (pkgs.lib.generators.toYAML {} {
              version = "1";
              global = {
                lang_dir = "en_US";
                lang_preferences = ["#rx#^english" "american english"];
              };
              modules = [
                {
                  #########
                  # Early #
                  #########

                  # Needs `EET/bgee_dir.txt` with path to bg1 game directory inside
                  name = "EET";
                  components = [
                    0 # EET core (resource importation): V13.4
                  ];
                }
                {
                  name = "infinity_ui";
                  components = [
                    0 # Core
                    2 # Update several strings in Dialog.tlk
                    5 # 3 quicksave slots
                  ];
                }

                ######################
                # Resource overwrite #
                ######################
                {
                  name = "bggo";
                  components = [
                    0 # BGGO for EET, BGT, BGEE, BG2EE, ToB and Tutu: v3.1
                  ];
                }
                {
                  name = "HQ_SoundClips_BG2EE";
                  components = [0];
                }

                ###########
                # Content #
                ###########

                {
                  name = "bg1npc";
                  components = [
                    0 # The BG1 NPC Project # Required Modifcations
                    10 # The BG1 NPC Project # Banters, Quests and Intrerjections
                    120 # The BG1NPC Project # Bardic Reputation Adjustment
                    130 # The BG1NPC Sarevok's Diary Adjustments # SixofSpades Extended Sarevok's Diary
                    200 # The BG1NPC Project # Player-Initiated Dialogues
                  ];
                }
                {
                  name = "ub"; # BG2 Unfinished Business
                  components = [
                    0 # The Kidnapping of Boo by Cliffette
                    1 # The Suna Seni/Valygar Relationship
                    2 # Kalah and What He Was Promised
                    4 # Gorje Hilldark and the Extended Illithium Quest
                    5 # The Pai'Na/Spider's Bane Quest
                    6 # Restored Crooked Crane Inn
                    7 # Restored Encounters
                    8 # Artemis Entreri in Bodhi's Lair
                    9 # Corrected "Xzar's Creations"
                    10 # Restored Hell Minions, by SimDing0
                    12 # Item Restorations
                    15 # NPC Portrait Restorations
                    17 # Corrected Character Names and Biographies
                    18 # Restored Minor Dialogs
                    20 # Extended ToB Item Descriptions
                    21 # Throne of Bhaal Minor Restorations
                    25 # The Murder of Acton Balthis, by Kulyok
                  ];
                }
                {
                  name = "ascension";
                  components = [
                    0 # Rewritten Final Chapter of Throne of Bhaal: 2.0.28
                    10 # Balthazar can be redeemed: 2.0.28
                    20 # Improved Sarevok-Player Interactions: 2.0.28
                    30 # Improved Imoen-Player Interactions in Throne of Bhaal: 2.0.28
                    40 # Restored Bhaalspawn Powers: 2.0.28
                    50 # Improved Slayer Transformation: 2.0.28
                    60 # Expanded Epilogues for Bioware NPCs -> David Gaider's expanded epilogues for Bioware NPCs: 2.0.28
                    1000 # Tougher Abazigal: 2.0.28
                    1100 # Tougher Balthazar: 2.0.28
                    1200 # Tougher Demogorgon: 2.0.28
                    1300 # Tougher Gromnir: 2.0.28
                    1400 # Tougher Illasera: 2.0.28
                    1500 # Tougher Yaga-Shura: 2.0.28
                    2000 # Full-body portrait for Bodhi: 2.0.28
                    2100 # Alternate Balthazar portrait, by Cuv: 2.0.28
                    2200 # Extended Epilogues for additional Beamdog NPCs, by shawne: 2.0.28
                    2300 # Sharper portraits of Abazigal and Gromnir for the Enhanced Edition, by DavidW: 2.0.28
                    2400 # Slightly improved cutscenes, by DavidW: 2.0.28
                  ];
                }

                ###############
                # Late Tweaks #
                ###############
                {
                  name = "HiddenGameplayOptions";
                  components = [
                    0 # Install all Hidden Gameplay Options at once
                  ];
                }

                {
                  name = "stratagems";
                  components = [
                    1500 # Include arcane spells from Icewind Dale: Enhanced Edition: 35.20
                    1510 # Include divine spells from Icewind Dale: Enhanced Edition: 35.20
                    1520 # Include bard songs from Icewind Dale: Enhanced Edition: 35.20
                    2000 # Install all spell tweaks (if you don't select this, you will be given a chance to choose by category): 35.20
                    2500 # Add 9 new arcane spells: 35.20
                    2510 # Add 6 new divine spells (some borrowed from Divine Remix): 35.20
                    2520 # Revised elementals and elemental summoning: 35.20
                    3015 # Re-introduce potions of extra-healing: 35.20
                    3022 # Replace many +1 magic weapons with nonmagical "fine" ones -> Fine weapons are affected by the iron crisis: 35.20
                    3041 # Reduce the number of Arrows of Dispelling in stores -> Stores sell a maximum of 5 Arrows of Dispelling: 35.20
                    3505 # Wider selection of random scrolls: 35.20
                    4000 # More Appropriate-Speed Bears: 35.20
                    4020 # More realistic wolves and wild dogs: 35.20
                    4030 # Improved shapeshifting: 35.20
                    4050 # Decrease the rate at which reputation improves -> Reputation increases at about 2/3 the normal rate: 35.20
                    4115 # Thieves assign skill points in multiples of five: 35.20
                    4140 # Revised inn rooms: more expensive, more benefits: 35.20
                    4150 # Allow the Cowled Wizards to detect spellcasting in most indoor, above-ground areas in Athkatla: 35.20
                    4215 # Remove unrealistically helpful items from certain areas: 35.20
                    5000 # Ease-of-use party AI: 35.20
                    5080 # Improved BG Textscreens: 35.20
                    5900 # Initialise AI components (required for all tactical and AI components): 35.20
                    6000
                    6010
                    6030
                    6040 # Smarter Priests: 35.20
                    6100
                    6200 # Improved Spiders: 35.20
                    6300 # Smarter sirines and dryads: 35.20
                    6310
                    6320 # Smarter basilisks: 35.20
                    6500 # Improved golems: 35.20
                    6510 # Improved fiends and celestials: 35.20
                    6520 # Smarter genies: 35.20
                    6540 # Smarter dragons: 35.20
                    6550
                    6560
                    6570
                    6580
                    6590 # Smarter Throne of Bhaal final villain: 35.20
                    6800 # Smarter Illasera: 35.20
                    6810
                    6820 # Smarter Yaga-Shura: 35.20
                    6830 # Smarter Abazigal: 35.20
                    6840
                    6850
                    7000
                    7150 # Improved Carsa/Kahrk interaction: 35.20
                    8050
                    8090 # Party's items are taken from them in Spellhold: 35.20
                    8130 # Rebalanced troll regeneration: 35.20
                    8140
                    8170 # Improved Sendai's Enclave: 35.20
                  ];
                }
                {
                  name = "eet_tweaks";
                  components = [
                    2002 # Total XP CAP -> Disabled: 1.12
                    2051 # XP for killing creatures -> Decrease to 75%: 1.12
                    2061 # XP for quests -> Decrease to 75%: 1.12
                    3020 # Familiar death consequences -> Constitution loss & blocked summoning for 1 week: 1.12
                    4020 # Higher framerates support: 1.12
                    4050 # Books/Scrolls categorization: 1.12
                  ];
                }
                {
                  name = "EET_end";
                  components = [
                    0 # Standard installation
                  ];
                }
                {
                  name = "generalized_biffing";
                  components = [1];
                }
              ];
            });
          in
            pkgs.writeShellScriptBin "bg-setup"
            ''
              out="$PWD/out"

              read -p "Is $out the out directory you want to use? Type y to confirm: " -n 1 -r
              echo
              if [[ ! $REPLY =~ ^[Yy]$ ]]
              then
                exit 1
              fi

              mkdir $out

              game_copies_dir="$out/duplicated_game_dirs"
              mkdir $game_copies_dir

              ciopfs_mount="$out/ciopfs_game_dirs_mount"
              mkdir $ciopfs_mount
              ${pkgs.ciopfs}/bin/ciopfs $game_copies_dir $ciopfs_mount
              bg1_mount="$ciopfs_mount/bg1"
              bg2_mount="$ciopfs_mount/bg2"
              mkdir $bg1_mount
              mkdir $bg2_mount

              ${pkgs.python3.interpreter} ${./duplicate_readonly_game_dir.py} ${bg1GameDir} $bg1_mount || exit 1
              ${pkgs.python3.interpreter} ${./duplicate_readonly_game_dir.py} ${bg2GameDir} $bg2_mount || exit 1

              ln -s ${modda-cfg} $bg1_mount/modda.yml
              ln -s ${modda-cfg} $bg2_mount/modda.yml


              # Copy mod folders in
              for dir in ${pkgs.lib.concatMapStringsSep " " (p: "${p}/*/") bg1Mods}; do
                cp -r --no-preserve=mode,ownership $dir $bg1_mount/
              done

              cd $bg1_mount
              ${packages.modda}/bin/modda install --manifest-path "${bg1-modda-manifest}"


              # Copy mod folders in
              for dir in ${pkgs.lib.concatMapStringsSep " " (p: "${p}/*/") bg2Mods}; do
                cp -r --no-preserve=mode,ownership $dir $bg2_mount/
              done

              # Needed for EET to find the BG1 game dir
              echo -n "../bg1" > $bg2_mount/EET/bgee_dir.txt

              # This combined with a patch prevents EET from trying to use its pre-built
              # binaries.
              mkdir -p $bg2_mount/EET/bin/nixos
              ln -s ${pkgs.weidu}/bin/weidu $bg2_mount/EET/bin/nixos/weidu
              ln -s ${pkgs.lua5_3}/bin/lua $bg2_mount/EET/bin/nixos/lua

              # EET gives warning if this file doesn't already exist
              touch $bg2_mount/weidu.log

              cd $bg2_mount
              ${packages.modda}/bin/modda install --manifest-path "${bg2-modda-manifest}"


              mount_script="$out/ensure_ciopfs_mount"
              cat >$mount_script <<EOL
                #!${pkgs.runtimeShell}
                if [ ! -f ''${bg2_mount}/chitin.key ] ; then
                  ${pkgs.ciopfs}/bin/ciopfs ''${game_copies_dir} ''${ciopfs_mount}
                fi
              EOL
              chmod +x $mount_script
              echo
              echo "Set BG2 Steam launch options to: \`$mount_script && cd \"$bg2_mount\" && %command%\`"
              echo "The ensure_ciopfs_mount script won't work if Steam is running in a user namespace like FHS."
              echo "It can be manually unmounted if needed with: \`fusermount -u $ciopfs_mount\`"
            '';
        };

      devShells.default = pkgs.mkShell {
        packages = [
          packages.modda
          pkgs.weidu
        ];
        shellHook = ''
        '';
      };
      devShells.rust = pkgs.mkShell {
        packages = [
          pkgs.rustc
          pkgs.cargo
        ];
      };
    });
}
