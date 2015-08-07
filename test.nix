{ dryRun ? true
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};

in rec {

  release =
    with import <nixpkgs> { };
  
    stdenv.mkDerivation {
      name = "keymaster-release";
      buildCommand = ''
        set
        find .
      '';
    };
}
