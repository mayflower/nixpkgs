#!/usr/bin/env nix-shell
#! nix-shell -i bash -p yarn2nix yarn

version="${1:?Usage: generate-dependencies.sh <version>}"
set -exuo pipefail
matrix_appservice_slack_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "$(mktemp -dt matrix-appservice-slack-update.XXXXXXXX)"
workdir=$(pwd)
trap 'cd /; rm -rf "$workdir"' EXIT

curl -f https://raw.githubusercontent.com/matrix-org/matrix-appservice-slack/"$version"/package.json -o package.json
yarn --ignore-scripts
yarn2nix > yarn.nix

mv package.json yarn.lock yarn.nix "$matrix_appservice_slack_dir"
