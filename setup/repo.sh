#!/bin/bash

set -euo pipefail

# Set Variables
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/arch"
SETUP="$ROOT/setup"
REPO="$ROOT/neo-repo"

init_repo() {
    echo "[-] Reset neo-repo"
    rm -rf "$REPO"

    echo "[+] Created /neo-repo"
    mkdir "$REPO"

    echo "[+] Add 'neo-repo' to 'pacman.conf'"
    cat >> $ARCH/pacman.conf <<EOF

[neo-repo]
SigLevel = Optional TrustAll
Server = file://$REPO
EOF
}

install_yay() {
    git clone https://aur.archlinux.org/yay-bin.git /tmp/buildyay
    cd /tmp/buildyay
    makepkg --si --noconfirm --nosign
    cd /tmp/
    rm -rf /tmp/buildyay
}


build_aur_repo() {
    echo "[+] Building OS dependencies"
    local file="$SETUP/packages/aur-git"
    local builddir="/tmp/neoveil-aur"

    rm -rf "$builddir"
    mkdir -p "$builddir"

    while IFS= read -r repo; do
        [[ -z "$repo" || "$repo" =~ ^# ]] && continue

        local name
        name="$(basename "$repo" .git)"

        echo "[*] Building $name"

        rm -rf "$builddir/$name"

        git clone "$repo" "$builddir/$name" || {
            echo "[-] Failed to clone $repo"
            continue
        }

        (
            cd "$builddir/$name" || exit 1
            makepkg -si --noconfirm
            cp *.pkg.tar.zst $REPO/
        ) || {
            echo "[-] Failed building $name"
            continue
        }

    done < "$file"
    rm -rf "$builddir"
}

build_illogical_impulse()
{
    local t=~/.cache/dots-hyprland

    rm -rf "$t"
    git clone https://github.com/end-4/dots-hyprland.git "$t" --filter=blob:none --recurse-submodules
    cd "$t"

    for dir in "$t/sdata/dist-arch/"*/; do
        cd $dir
        makepkg --si --noconfirm --nosign
        cp *.pkg.tar.zst $REPO/
        local pkg="$(basename "$dir")"
        echo "$pkg" >> "$ARCH/packages.x86_64"
    done
}

install_illogical_impulse()
{
    local t=~/.cache/dots-hyprland
    cp -a "$t/dots/." "$ARCH/airootfs/etc/skel/"
}

add_package() {
    echo "[+] Installing dependencies"
    local file="$SETUP/packages/depend/pacman"

    sudo pacman -S --needed --noconfirm - < "$file"

    if ! command -v yay >/dev/null 2>&1;then
        echo "[+] YAY not detected. Installing..."
        install_yay
    fi    

    local file="$SETUP/packages/depend/hyprland"
    #yay -S --needed --noconfirm - < "$file"

    echo "[+] Building AUR packages"
    build_aur_repo

    echo "[+] Building Illogical Impulse"
    build_illogical_impulse

    echo "[+] Create 'neo-repo'"
    repo-add $REPO/neo-repo.db.tar.zst $REPO/*.pkg.tar.zst

    echo "[+] Install Illogical Impulse"
    install_illogical_impulse
}

main() {
    echo "[*] Initializing 'neo-repo' pacman"
    init_repo
    echo "[*] Adding packages to 'neo-repo'."
    add_package
}

main
