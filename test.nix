{ dryRun ? true
, keymaster
, root
, nixpkgs
, pipeline
, officialRelease ? false
, pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) stdenv lib runCommand nix bash git openssh jq nixopsUnstable curl;

  provisionJob = tag:
    lib.hydraJob (runCommand "keymaster-${tag}" {
      buildInputs = with nixpkgs; [
        nix
        bash
        git
        openssh
        nixopsUnstable
        curl
        jq
      ];
      buildCommand = ''
        set -ex
        mkdir -p $out $out/log $out/db $out/nix-support

        declare -rx Z_DEPLOYMENT_TMPDIR="$(mktemp -d -t "$name.XXXXX.$$")"
        mkdir -p $Z_DEPLOYMENT_TMPDIR
        declare -x HOME=$Z_DEPLOYMENT_TMPDIR
        declare -rx DD_AGENT_KEY=null
        declare -rx NIX_REMOTE=daemon
        declare -rx Z_DEPLOYMENT_ENV_TYPE="dev"
        declare -rx Z_DEPLOYMENT_TARGET="ec2"
        declare -rx Z_DEPLOYMENT_PROFILE="singlenode"
        declare -rx NIX_PATH="nixpkgs=${nixpkgs}:lookout=${pipeline}/channels/lookout"
        declare -rx NIXOPS_STATE="$Z_DEPLOYMENT_TMPDIR/state.nixops"
        declare -rx Z_REMOTE_USER=jenkins

        pushd "${root}"
        source z/setup/env.sh
        source /etc/hydra/ec2.environment
        echo "$AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY dev" > "$HOME/.ec2-keys"
        popd

        pushd "${keymaster}"
        # here until ci hooks pass this in
        declare -rx Z_REMOTE_REF="$(git rev-parse HEAD)"
        ./z/bin/nixops-provision | tee "$out/log/provision.log"
        ./z/bin/validate-infrastructure | tee "$out/log/validate.log"
        nixops ssh keymasterApp 'curl --silent --show-error --fail \
          --retry 30 --retry-delay 5 \
          http://localhost:3000/health.json  \
          | jq -r .' > "$out/log/keymaster-health.json" 2>&1
        cp "$NIXOPS_STATE" "$out/db/keymaster.nixops"
        set > "$out/log/env.log"
        ssh gerrit.flexilis.local -- gerrit review "$Z_REMOTE_REF" --message Validated
      '';
    } ''
      {
        echo "file keymaster-health.json $out/log/keymaster-health.json"
        echo "file keymaster.nixops $out/db/keymaster.nixops"
        echo "file provision.log $out/log/provision.log"
        echo "file validate.log $out/log/validate.log"
        echo "file env.log $out/log/env.log"
      } > $out/nix-support/hydra-build-products
      popd
    '');

in {
  infrastructure = provisionJob "release";
}
