#!/bin/bash
#
# tmux-manager uninstaller
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/share/tmux-manager"
BIN_DIR="$HOME/.local/bin"

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

echo -e "${BOLD}${CYAN}"
echo "╔════════════════════════════════════╗"
echo "║   tmux-manager uninstaller         ║"
echo "╚════════════════════════════════════╝"
echo -e "${NC}"

# Remove symlink
if [[ -L "$BIN_DIR/tmux-manager" ]]; then
    info "Removing symlink..."
    rm -f "$BIN_DIR/tmux-manager"
    success "Symlink removed"
fi

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    info "Removing installation directory..."
    rm -rf "$INSTALL_DIR"
    success "Directory removed"
fi

# Offer to clean .bashrc
BASHRC="$HOME/.bashrc"
if grep -q "tmux-manager" "$BASHRC" 2>/dev/null; then
    echo
    echo -e "${CYAN}Remove tmux-manager from .bashrc?${NC}"
    echo -ne "${BOLD}[y/N]: ${NC}"
    read -r response

    if [[ "$response" =~ ^[yY]$ ]]; then
        info "Cleaning .bashrc..."
        cp "$BASHRC" "$BASHRC.bak"
        sed -i '/# tmux-manager:/d' "$BASHRC"
        sed -i '/tmux-manager$/d' "$BASHRC"
        # Remove the if block
        sed -i '/^if.*TMUX.*SSH_TTY.*then$/,/^fi$/{ /tmux-manager/d; }' "$BASHRC"
        # Clean up empty if blocks
        sed -i '/^if.*TMUX.*SSH_TTY.*then$/,/^fi$/d' "$BASHRC"
        success "Cleaned .bashrc (backup: .bashrc.bak)"
    fi
fi

echo
echo -e "${GREEN}${BOLD}Uninstallation complete!${NC}"
