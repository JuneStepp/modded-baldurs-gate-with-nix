{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  weidu,
  unzip,
}:
rustPlatform.buildRustPackage rec {
  pname = "modda";
  version = "154dea27e0a09b4c0b45ba4ae29de1fadd059b76";

  src = fetchFromGitHub {
    owner = "mleduque";
    repo = pname;
    rev = version;
    hash = "sha256-hIKBvKz5XNp0wdzUc9RSkvSnHMwL/twdH2y7JBgMJmY=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [makeWrapper];
  buildInputs = [weidu];

  postFixup = ''
    wrapProgram "$out/bin/modda" \
      --prefix PATH : "${weidu}/bin" \
      --prefix PATH : "${unzip}/bin" # Needed by some Weidu scripts. At least DLCMerger.
  '';

  meta = {
    description = "Weidu install automation";
    homepage = "https://github.com/mleduque/modda";
    license = lib.licenses.mit;
  };
}
