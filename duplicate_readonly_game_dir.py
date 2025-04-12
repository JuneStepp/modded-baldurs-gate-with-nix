################################################################
# Duplicate Steam Baldur's gate Enhanced Editions game folders.
# Based on https://github.com/adlerosn/cicpoffs
################################################################
from pathlib import Path
import sys
from shutil import copyfile


def copytree_no_copystat(src: Path, dst: Path) -> None:
    for dirpath, _dirnames, filenames in src.walk():
        dst_dirpath = dst / dirpath.relative_to(src)
        dst_dirpath.mkdir()
        for filename in filenames:
            _ = copyfile(dirpath / filename, dst_dirpath / filename)


def basic_game_dir_check(game_dir: Path) -> bool:
    """Check if directory looks like a Stem Infinity Engine game dir"""
    if not game_dir.is_dir():
        return False

    if not (game_dir / "chitin.key").exists():
        return False

    return True


def process_movies_dir(source: Path, target: Path) -> None:
    # one set of movies at the root, one in 480, one in lo

    # link all root movies (non-dir files)
    for path in source.iterdir():
        if not path.is_dir():
            # EET has trouble when these files are links to read only versions even
            # though its not trying to edit the original file.
            if path.name.lower() in ("daynite.wbm", "niteday.wbm"):
                _ = copyfile(path, target / path.name)
            else:
                (target / path.name).symlink_to(path)

    source_480 = source / "480"
    if source_480.exists():
        target_480 = target / "480"
        target_480.mkdir()
        for path in source_480.iterdir():
            (target_480 / path.name).symlink_to(path)

    source_lo = source / "lo"
    if source_lo.exists():
        target_lo = target / "lo"
        target_lo.mkdir()
        for path in source_lo.iterdir():
            (target_lo / path.name).symlink_to(path)


def process_lang_dir(lang_dir: Path, target_lang_dir: Path) -> None:
    # In each language subdir:
    #   - one dialog.tlk OR dialog.tlk+dialogF.tlk -> copy because those are modifiable
    #   - [maybe]one movies subdir like movies subdir at root
    #   - [maybe]one sounds/ subdir
    #   - [maybe]one data/ subdir (ex: de_DE)
    #   - [maybe]one override/ subdir (ex: de_DE)
    for tlk_file in lang_dir.glob("*.tlk"):
        _ = copyfile(tlk_file, target_lang_dir / tlk_file.name)

    movies_dir = lang_dir / "movies"
    if movies_dir.exists():
        (target_lang_dir / "movies").mkdir()
        process_movies_dir(movies_dir, target_lang_dir / "movies")

    # *.wav files and one sndlist.txt -> create dir, link *.wav, copy sndlist.txt
    sounds_dir = lang_dir / "sounds"
    if sounds_dir.exists():
        target_sounds_dir = target_lang_dir / "sounds"
        target_sounds_dir.mkdir()
        for file in sounds_dir.iterdir():
            if file.suffix.lower() == ".wav":
                (target_sounds_dir / file.name).symlink_to(file)
            else:
                _ = copyfile(file, target_sounds_dir / file.name)

    override_dir = lang_dir / "override"
    if override_dir.exists():
        copytree_no_copystat(override_dir, target_lang_dir / "override")

    data_dir = lang_dir / "data"
    if data_dir.exists():
        target_data_dir = target_lang_dir / "data"
        target_data_dir.mkdir()
        # Link all files inside (should all be .bif)
        for path in data_dir.iterdir():
            (target_data_dir / path.name).symlink_to(path)


source = Path(sys.argv[1])
target = Path(sys.argv[2])

assert source.is_dir()
assert target.is_dir()

# Target dir must be empty
assert not next(target.iterdir(), None)

assert basic_game_dir_check(source)


# Can be modded
files_to_copy: tuple[Path, ...] = (
    source / "chitin.key",
    source / "engine.lua",
)
for file in files_to_copy:
    _ = copyfile(file, target / file.name)

for path in source.iterdir():
    if (path not in files_to_copy) and path.is_file():
        (target / path.name).symlink_to(path)

# The exisiting scripts can be modified and new scripts can be added
copytree_no_copystat(source / "scripts", target / "scripts")

target_data_dir = target / "data"
target_data_dir.mkdir()
# Link all files inside (should all be .bif)
for path in (source / "data").iterdir():
    (target_data_dir / path.name).symlink_to(path)

target_base_lang_dir = target / "lang"
target_base_lang_dir.mkdir()
for lang_dir in (source / "lang").glob("*/"):
    target_lang_dir = target_base_lang_dir / lang_dir.name
    target_lang_dir.mkdir()
    process_lang_dir(lang_dir, target_lang_dir)

target_movies_dir = target / "movies"
target_movies_dir.mkdir()
process_movies_dir(source / "movies", target_movies_dir)


# some .mus file at the root (couple dozen bytes each, 40 files or so)
# one lone .acm file
# around 40 directories with  some .acm inside
# create the directories, link the .acm inside
# copy all the .mus files and link the single .acm in the root
target_music_dir = target / "music"
target_music_dir.mkdir()
for path in (source / "music").iterdir():
    if path.is_dir():
        (target_music_dir / path.name).mkdir()
        for file in path.iterdir():
            (target_music_dir / path.name / file.name).symlink_to(file)
    else:
        # copy *.mus
        if path.stem.lower() == ".mus":
            _ = copyfile(path, target_music_dir / path.name)
        else:
            # link the non-dir, non-mus file(s)
            (target_music_dir / path.name).symlink_to(path)

source_dlc_dir = source / "dlc"
if source_dlc_dir.exists():
    target_dlc_dir = target / "dlc"
    target_dlc_dir.mkdir()
    for file in source_dlc_dir.iterdir():
        (target_dlc_dir / file.name).symlink_to(file)
(target / "Manuals").symlink_to(source / "Manuals")

override_dir = source / "override"
target_override_dir = target / "override"
if override_dir.exists():
    copytree_no_copystat(override_dir, target_override_dir)
else:
    target_override_dir.mkdir()
