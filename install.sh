#!/bin/bash
#
# tmux-manager installer
# Usage: curl -fsSL https://raw.githubusercontent.com/USER/tmux-manager/main/install.sh | bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/share/tmux-manager"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/z4nr34l/tmux-manager.git"

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

echo -e "${BOLD}${CYAN}"
echo "╔════════════════════════════════════╗"
echo "║   tmux-manager installer           ║"
echo "╚════════════════════════════════════╝"
echo -e "${NC}"

# Check dependencies
info "Checking dependencies..."

if ! command -v tmux &> /dev/null; then
    error "tmux is not installed. Please install tmux first."
fi

if ! command -v git &> /dev/null; then
    error "git is not installed. Please install git first."
fi

success "Dependencies OK"

# Create directories
info "Creating directories..."
mkdir -p "$BIN_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone or update repository
if [[ -d "$INSTALL_DIR" ]]; then
    info "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --quiet origin main 2>/dev/null || git pull --quiet origin master 2>/dev/null || true
    success "Updated"
else
    info "Downloading tmux-manager..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || {
        # Fallback: download directly if git clone fails
        warn "Git clone failed, trying direct download..."
        mkdir -p "$INSTALL_DIR"
        curl -fsSL "https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/tmux-manager" -o "$INSTALL_DIR/tmux-manager"
    }
    success "Downloaded"
fi

# Make executable and create symlink
info "Installing..."
chmod +x "$INSTALL_DIR/tmux-manager"
ln -sf "$INSTALL_DIR/tmux-manager" "$BIN_DIR/tmux-manager"
success "Installed to $BIN_DIR/tmux-manager"

# Check if BIN_DIR is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR is not in your PATH"
    echo -e "    Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "    ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

# Configure .bashrc
echo
echo -e "${CYAN}Configuring auto-start on SSH login...${NC}"

BASHRC="$HOME/.bashrc"
SKIP_BASHRC=false

# Check if --no-bashrc flag was passed
for arg in "$@"; do
    if [[ "$arg" == "--no-bashrc" ]]; then
        SKIP_BASHRC=true
    fi
done

if [[ "$SKIP_BASHRC" == false ]]; then
    # Check if already configured
    if grep -q "tmux-manager" "$BASHRC" 2>/dev/null; then
        success "Already configured in .bashrc"
    else
        # Remove old tmux auto-attach if present
        if grep -q "tmux attach-session.*tmux new-session" "$BASHRC" 2>/dev/null; then
            info "Removing old tmux auto-attach configuration..."
            # Create backup
            cp "$BASHRC" "$BASHRC.bak"
            # Remove old pattern (common variations)
            sed -i '/tmux attach-session.*tmux new-session/d' "$BASHRC"
            sed -i '/^if.*TMUX.*SSH_TTY.*then$/,/^fi$/d' "$BASHRC"
        fi

        # Add tmux-manager
        info "Adding tmux-manager to .bashrc..."
        cat >> "$BASHRC" << 'EOF'

# tmux-manager: Interactive tmux session selector on SSH login
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux-manager
fi
EOF
        success "Added to .bashrc"
    fi
fi

echo
echo -e "${GREEN}${BOLD}Installation complete!${NC}"
echo
echo -e "Usage:"
echo -e "  ${BOLD}tmux-manager${NC}    - Run interactively"
echo
if [[ "$SKIP_BASHRC" == false ]]; then
    echo -e "On your next SSH login, you'll be prompted to select or create a tmux session."
else
    echo -e "Run ${BOLD}tmux-manager${NC} manually or add it to your shell config."
fi
echo
echo -e "To install without .bashrc modification:"
echo -e "  ${BOLD}curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash -s -- --no-bashrc${NC}"
