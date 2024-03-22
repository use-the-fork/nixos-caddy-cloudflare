#!/usr/bin/env bash
ROOT_DIR="$(pwd)"

git_push() {
    (
        cd "$ROOT_DIR" || return
        git config --global user.name 'Updater'
        git config --global user.email 'robot@nowhere.invalid'
        git remote update

        git add flake.lock
        git add flake.nix
        git add caddy-src

        git commit -m "$1"
        git push
    )
}

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

        git_push "ci: caddy and deps bumped"
    else
        echo "Up to date"
        git_push "chore: update flake.nix"
    fi
)
