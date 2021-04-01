#!/usr/bin/env bash

# Download package.json and package-lock.json from the v1.7.0 release
curl https://raw.githubusercontent.com/matrix-org/matrix-appservice-slack/1.7.0/package.json -o package.json
curl https://raw.githubusercontent.com/matrix-org/matrix-appservice-slack/1.7.0/package-lock.json -o package-lock.json

$(nix-build $ROOT -A  nodePackages.node2nix --no-out-link)/bin/node2nix \
  --nodejs-12 \
  --node-env ../../../development/node-packages/node-env.nix \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix
