{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iedup";
  version = "50479b778d0820d1bebe83ec6d01635aa82f14ba";

  src = fetchFromGitHub {
    owner = "mleduque";
    repo = pname;
    rev = version;
    hash = "sha256-zb8Jkx0T9L68gLRGu9xm3uE7pQVj87dK9TYHvqpfAnM=";
  };

  patches = [./modern-clap.patch];

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "Duplicate an infinity engine game install using symbolic links";
    homepage = "https://github.com/mleduque/iedup";
    license = lib.licenses.mit;
  };
}
