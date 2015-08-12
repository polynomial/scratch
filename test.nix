{ dryRun ? true
, keymaster
, root
, nixpkgs
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};
  nix = pkgs.nix;
  bash = pkgs.bash;
  openssh = pkgs.openssh;
  jq = pkgs.jq;
  nixops = pkgs.nixopsUnstable;
  curl = pkgs.curl;

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
      buildInputs = [
        nix
        bash
        openssh
        nixops
        curl
        jq
      ];
      name = "keymaster-release";
      buildCommand = ''
        set -x
        mkdir -p $out
        cd ${root}
        source z/setup/env.sh
        declare -r -x Z_DEPLOYMENT_TMPDIR=/tmp/$$
        mkdir -p $Z_DEPLOYMENT_TMPDIR
        declare -r -x DD_AGENT_KEY=null
        declare -r -x NIX_REMOTE=daemon
        declare -r -x Z_DEPLOYMENT_ENV_TYPE="dev"
        declare -r -x Z_DEPLOYMENT_TARGET="ec2"
        declare -r -x Z_DEPLOYMENT_PROFILE="singlenode"
        declare -r -x USER=hydra
        declare -r -x NIX_PATH="nixpkgs=${nixpkgs}"
        declare -r -x NIXOPS_STATE="$Z_DEPLOYMENT_TMPDIR/nixops.state"
        declare -r -x AWS_ACCESS_KEY_ID=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.AccessKeyId' |sed 's/"//g')
        declare -r -x AWS_SECRET_ACCESS_KEY=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.SecretAccessKey' |sed 's/"//g')
        set
        cd ${keymaster}
        ./z/bin/nixops-provision | tee $out/nixops-provision.log
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure.log
      '';
    };
}
