{ ... }:
import <nixpkgs> { inherit lib; }

stdenv.mkDerivation {
  name = "test.release";
  NIX_PATH="nixpkgs=${nixpkgs}";

  buildCommand = ''
    set
  '';
  };
}
