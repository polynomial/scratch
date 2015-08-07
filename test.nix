{ dryRun ? true
, keymaster
, testVar ? "sometestvar"
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};
  nix = pkgs.nix;
  bash = pkgs.bash;
  nixops = pkgs.nixopsUnstable;
  curl = pkgs.curl;

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
      buildInputs = [
        nix
        bash
        nixops
        curl
      ];
      name = "keymaster-release";
      buildCommand = ''
        export NIX_REMOTE=daemon
        set -x
        whoami
        mkdir -p $out
        cd ${keymaster}
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure
      '';
    };
}
