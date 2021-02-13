#!/usr/bin/env bash

# Download package.json and package-lock.json from the v1.7.0 release
curl https://raw.githubusercontent.com/matrix-org/matrix-appservice-slack/d589aa2e258213ec5ee61ab1d6205c4fb56d116d/package.json -o package.json
curl https://raw.githubusercontent.com/matrix-org/matrix-appservice-slack/d589aa2e258213ec5ee61ab1d6205c4fb56d116d/package-lock.json -o package-lock.json

$(nix-build $ROOT -A  nodePackages.node2nix --no-out-link)/bin/node2nix \
  --nodejs-12 \
  --node-env ../../../development/node-packages/node-env.nix \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix
