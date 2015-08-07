with import ./.. { };
#with lib;

stdenv.mkDerivation {
  name = "nixpkgs-manual";

  buildCommand = ''
    set
  '';
}

