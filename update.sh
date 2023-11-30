#!/usr/bin/env bash

(
  nix flake update

  cd ./caddy-src || return
  OLD_HASH="$(sha256sum ./go.sum)"

  rm go*
  go mod init caddy
  go mod tidy

  NEW_HASH="$(sha256sum ./go.sum)"

  if [ "$OLD_HASH" != "$NEW_HASH" ]; then
    sed -i 's/vendorHash.*/vendorHash = "";/' ../flake.nix

    NEW_VENDOR_HASH="$(nix build ../.# |& sed -n 's/.*got: *//p')"

    sed -i "s#vendorHash.*#vendorHash = \"$NEW_VENDOR_HASH\";#" ../flake.nix
  else
    echo "Up to date"
  fi
)
