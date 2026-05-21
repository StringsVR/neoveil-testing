#!/bin/bash

set -euo pipefail

# Set Variables
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/arch"
SETUP="$ROOT/setup"

echo "[*] Adding 'neoveil' user..."

echo "[+] Modified /etc/passwd"
printf '%s\n' 'neoveil:x:1000:1000::/home/archie:/usr/bin/zsh' >> $ARCH/airootfs/etc/passwd

echo "[+] Modified /etc/shadow"
echo 'neoveil:$6$71CLk2xXONXxRrzj$YO2B/5C65OU1NY9WupMHB0/8g2xFNhh3af6xDBKZpwmiXBAjqMTw4MXKb17zZtLqYtiI7FNvlkbHzv3z407b0/:14871::::::' >> $ARCH/airootfs/etc/shadow

echo "[+] Created /etc/group"
cat > $ARCH/airootfs/etc/group <<EOF
root:x:0:root
adm:x:4:neoveil
wheel:x:10:neoveil
uucp:x:14:neoveil
video:x:18:neoveil
input:x:97:neoveil
i2c:x:998:neoveil
seat:x:xxx:neoveil
neoveil:x:1000:
EOF

echo "[+] Created /etc/gshadow"
cat > $ARCH/airootfs/etc/gshadow <<EOF
root:!*::root
neoveil:!*::
EOF

echo "[+] Created /profiledef.sh"
cat > $ARCH/profiledef.sh <<EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="neoveil"
iso_label="neoveil"
iso_publisher="NeoVeil Linux <https://archlinux.org>"
iso_application="NeoVeil Linux Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="neoveil"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
EOF

echo "[+] Enable 'neoveil' user auto-start"
cat > $ARCH/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --noreset --noclear --autologin neoveil - ${TERM}
EOF
