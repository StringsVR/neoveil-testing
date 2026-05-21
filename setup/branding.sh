#!/bin/bash

set -euo pipefail

# Set Variables
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/arch"
SETUP="$ROOT/setup"

echo "[*] Changing Arch branding"
echo "[+] Modified /etc/hostname"
echo 'neoveil' > $ARCH/airootfs/etc/hostname

echo "[+] Created /etc/os-release"
cat > $ARCH/airootfs/etc/os-release <<EOF
NAME="NeoVeil Linux"
PRETTY_NAME="NeoVeil Linux"
ID=neoveil
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
EOF
