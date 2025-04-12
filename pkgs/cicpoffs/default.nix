# This isn't used, because it caused odd issues.
{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  fuse3,
  fuse,
  attr,
}:
stdenv.mkDerivation (
  finalAttrs: {
    pname = "cicpoffs";
    version = "ae6112ff6ceeb287149beaab759a1b17d4e27dc1";

    src = fetchFromGitHub {
      owner = "adlerosn";
      repo = finalAttrs.pname;
      rev = finalAttrs.version;
      hash = "sha256-lkD0/g7LEtktOLTiPosA+72aCpm1pl3o0+zHziGsTHo=";
    };

    buildInputs = [fuse3 fuse attr.dev];
    nativeBuildInputs = [pkg-config];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv cicpoffs $out/bin

      runHook postInstall
    '';

    meta = {
      description = "Case-Insensitive Case-Preserving Overlay FUSE File System";
      homepage = "https://github.com/adlerosn/cicpoffs";
      license = lib.licenses.gpl2;
      platforms = lib.platforms.linux;
    };
  }
)
