#!/usr/bin/env bash
# BLADE.RUN Setup Script — Linux
# Run with: chmod +x setup.sh && ./setup.sh

set -euo pipefail

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "\e[36m"
cat << 'EOF'
  ____  _      _    ____  _____   ____  _   _ _   _
 | __ )| |    / \  |  _ \| ____| |  _ \| | | | \ | |
 |  _ \| |   / _ \ | | | |  _|   | |_) | | | |  \| |
 | |_) | |__/ ___ \| |_| | |___  |  _ <| |_| | |\  |
 |____/|____/_/   \_|____/|_____| |_| \_\\___/|_| \_|

 SYSTEM SETUP :: LINUX :: v1.0
 ================================
EOF
echo -e "\e[0m"

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[33m[WARN]  Not running as root — will use sudo where needed\e[0m"
fi

SUDO=""
if command -v sudo &>/dev/null && [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# ── Distro detection ──────────────────────────────────────────────────────────
echo -e "\e[33m[INIT]  Detecting distribution...\e[0m"

DISTRO_ID=""
DISTRO_FAMILY=""

if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
fi

case "$DISTRO_ID" in
    ubuntu|debian|linuxmint|pop)
        DISTRO_FAMILY="debian"
        PKG_UPDATE="$SUDO apt-get update -qq"
        PKG_INSTALL="$SUDO apt-get install -y"
        ;;
    fedora|rhel|centos|rocky|alma)
        DISTRO_FAMILY="fedora"
        PKG_UPDATE="$SUDO dnf check-update -q || true"
        PKG_INSTALL="$SUDO dnf install -y"
        ;;
    arch|manjaro|endeavouros)
        DISTRO_FAMILY="arch"
        PKG_UPDATE="$SUDO pacman -Sy --noconfirm"
        PKG_INSTALL="$SUDO pacman -S --noconfirm --needed"
        ;;
    *)
        echo -e "\e[31m[ERROR] Unsupported distro: $DISTRO_ID\e[0m"
        echo "        Supported: Ubuntu/Debian, Fedora/RHEL, Arch"
        exit 1
        ;;
esac

echo -e "\e[32m[OK]    Detected: $DISTRO_ID ($DISTRO_FAMILY family)\e[0m"
echo ""

# ── Update package index ──────────────────────────────────────────────────────
echo -e "\e[36m[UPDATE] Refreshing package index...\e[0m"
eval "$PKG_UPDATE"
echo -e "\e[32m[OK]    Index refreshed\e[0m"
echo ""

# ── Helpers ───────────────────────────────────────────────────────────────────
OK_COUNT=0
FAIL_COUNT=0
RESULTS=()

mark_ok()   { echo -e "\e[32m[OK]    $1 ready\e[0m";          RESULTS+=("OK:$1");   (( OK_COUNT++ ))   || true; }
mark_fail() { echo -e "\e[31m[FAIL]  $1 — $2\e[0m";           RESULTS+=("FAIL:$1"); (( FAIL_COUNT++ )) || true; }

# ── Install: Google Chrome ────────────────────────────────────────────────────
echo -e "\e[36m[INSTALL] Google Chrome...\e[0m"

case "$DISTRO_FAMILY" in
    debian)
        TMP_DEB=$(mktemp /tmp/chrome-XXXXXX.deb)
        if wget -qO "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"; then
            $SUDO apt-get install -y "$TMP_DEB" && mark_ok "Google Chrome" || mark_fail "Google Chrome" "dpkg install failed"
            rm -f "$TMP_DEB"
        else
            mark_fail "Google Chrome" "download failed"
        fi
        ;;
    fedora)
        TMP_RPM=$(mktemp /tmp/chrome-XXXXXX.rpm)
        if wget -qO "$TMP_RPM" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"; then
            $SUDO dnf install -y "$TMP_RPM" && mark_ok "Google Chrome" || mark_fail "Google Chrome" "rpm install failed"
            rm -f "$TMP_RPM"
        else
            mark_fail "Google Chrome" "download failed"
        fi
        ;;
    arch)
        if command -v yay &>/dev/null; then
            yay -S --noconfirm google-chrome && mark_ok "Google Chrome" || mark_fail "Google Chrome" "yay install failed"
        elif command -v paru &>/dev/null; then
            paru -S --noconfirm google-chrome && mark_ok "Google Chrome" || mark_fail "Google Chrome" "paru install failed"
        else
            mark_fail "Google Chrome" "AUR helper (yay/paru) not found — install manually"
        fi
        ;;
esac

# ── Install: Steam ────────────────────────────────────────────────────────────
echo -e "\e[36m[INSTALL] Steam...\e[0m"

case "$DISTRO_FAMILY" in
    debian)
        $SUDO apt-get install -y steam-installer 2>/dev/null || \
        $SUDO apt-get install -y steam 2>/dev/null && \
        mark_ok "Steam" || mark_fail "Steam" "apt install failed (enable multiverse repo?)"
        ;;
    fedora)
        # Steam lives in RPM Fusion free
        $SUDO dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            2>/dev/null || true
        $SUDO dnf install -y steam && mark_ok "Steam" || mark_fail "Steam" "dnf install failed"
        ;;
    arch)
        $SUDO pacman -S --noconfirm --needed steam && mark_ok "Steam" || mark_fail "Steam" "pacman install failed (enable multilib?)"
        ;;
esac

# ── Install: Claude ───────────────────────────────────────────────────────────
echo -e "\e[36m[INSTALL] Claude...\e[0m"

case "$DISTRO_FAMILY" in
    debian)
        TMP_DEB=$(mktemp /tmp/claude-XXXXXX.deb)
        CLAUDE_URL="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nupkg/claude-latest.deb"
        if wget -qO "$TMP_DEB" "$CLAUDE_URL"; then
            $SUDO apt-get install -y "$TMP_DEB" && mark_ok "Claude" || mark_fail "Claude" "dpkg install failed"
            rm -f "$TMP_DEB"
        else
            mark_fail "Claude" "download failed — check https://claude.ai/download"
        fi
        ;;
    fedora)
        # Flatpak fallback — widely available
        if command -v flatpak &>/dev/null; then
            flatpak install -y flathub ai.anthropic.claude 2>/dev/null && \
            mark_ok "Claude (Flatpak)" || mark_fail "Claude" "flatpak install failed"
        else
            mark_fail "Claude" "no .rpm available — install flatpak then: flatpak install ai.anthropic.claude"
        fi
        ;;
    arch)
        if command -v yay &>/dev/null; then
            yay -S --noconfirm claude-desktop-bin && mark_ok "Claude" || mark_fail "Claude" "AUR install failed"
        elif command -v paru &>/dev/null; then
            paru -S --noconfirm claude-desktop-bin && mark_ok "Claude" || mark_fail "Claude" "AUR install failed"
        else
            mark_fail "Claude" "AUR helper (yay/paru) not found — install manually"
        fi
        ;;
esac

# ── Install: Discord ──────────────────────────────────────────────────────────
echo -e "\e[36m[INSTALL] Discord...\e[0m"

case "$DISTRO_FAMILY" in
    debian)
        TMP_DEB=$(mktemp /tmp/discord-XXXXXX.deb)
        if wget -qO "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"; then
            $SUDO apt-get install -y "$TMP_DEB" && mark_ok "Discord" || mark_fail "Discord" "dpkg install failed"
            rm -f "$TMP_DEB"
        else
            mark_fail "Discord" "download failed"
        fi
        ;;
    fedora)
        TMP_RPM=$(mktemp /tmp/discord-XXXXXX.rpm)
        if wget -qO "$TMP_RPM" "https://discord.com/api/download?platform=linux&format=rpm"; then
            $SUDO dnf install -y "$TMP_RPM" && mark_ok "Discord" || mark_fail "Discord" "rpm install failed"
            rm -f "$TMP_RPM"
        else
            mark_fail "Discord" "download failed"
        fi
        ;;
    arch)
        $SUDO pacman -S --noconfirm --needed discord && mark_ok "Discord" || mark_fail "Discord" "pacman install failed"
        ;;
esac

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m─────────────────────────────────\e[0m"
echo -e "\e[36m INSTALLATION SUMMARY\e[0m"
echo -e "\e[36m─────────────────────────────────\e[0m"

for entry in "${RESULTS[@]}"; do
    status="${entry%%:*}"
    name="${entry#*:}"
    if [[ "$status" == "OK" ]]; then
        echo -e "\e[32m  [OK]   $name\e[0m"
    else
        echo -e "\e[31m  [FAIL] $name\e[0m"
    fi
done

echo -e "\e[36m─────────────────────────────────\e[0m"
echo -e "\e[37m  $OK_COUNT succeeded · $FAIL_COUNT failed\e[0m"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "\e[32m ALL SYSTEMS GO — SETUP COMPLETE\e[0m"
else
    echo -e "\e[33m SETUP COMPLETE WITH ERRORS — check failed apps above\e[0m"
fi

echo ""
