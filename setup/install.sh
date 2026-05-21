#!/bin/bash

set -euo pipefail

# Set Variables
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/arch"
SETUP="$ROOT/setup"

echo "[*] Resetting arch workspace..."
rm -rf "$ARCH"

cp -r /usr/share/archiso/configs/releng "$ARCH"

echo "[*] Running setup modules..."

bash "$SETUP/user.sh"
bash "$SETUP/services.sh"
bash "$SETUP/branding.sh"
bash "$SETUP/repo.sh"

echo "[+] ArchISO workspace prepared."
