#!/bin/bash
#
# tmux-manager installer
#
# Usage:
#   Interactive:  curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash
#   With flags:   curl -fsSL ... | bash -s -- [OPTIONS]
#
# Options:
#   --bashrc          Enable auto-start on SSH login (modify .bashrc)
#   --no-bashrc       Don't modify .bashrc
#   --path-export     Add ~/.local/bin to PATH in .bashrc
#   --no-path-export  Don't modify PATH
#   -y, --yes         Accept all defaults (non-interactive)
#   -h, --help        Show this help message
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VERSION="1.1.0"
INSTALL_DIR="$HOME/.local/share/tmux-manager"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/z4nr34l/tmux-manager.git"

# Configuration (null = ask user)
CONFIG_BASHRC=""
CONFIG_PATH_EXPORT=""
NON_INTERACTIVE=false

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

show_help() {
    echo "tmux-manager installer"
    echo
    echo "Usage: curl -fsSL <url>/install.sh | bash -s -- [OPTIONS]"
    echo
    echo "Options:"
    echo "  --bashrc          Enable auto-start on SSH login (modify .bashrc)"
    echo "  --no-bashrc       Don't modify .bashrc"
    echo "  --path-export     Add ~/.local/bin to PATH in .bashrc"
    echo "  --no-path-export  Don't modify PATH"
    echo "  -y, --yes         Accept all defaults (non-interactive)"
    echo "  -h, --help        Show this help message"
    echo
    echo "Examples:"
    echo "  # Interactive installation"
    echo "  curl -fsSL <url>/install.sh | bash"
    echo
    echo "  # Non-interactive with auto-start enabled"
    echo "  curl -fsSL <url>/install.sh | bash -s -- --bashrc -y"
    echo
    echo "  # Non-interactive, no .bashrc modification"
    echo "  curl -fsSL <url>/install.sh | bash -s -- --no-bashrc -y"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --bashrc)
            CONFIG_BASHRC=true
            shift
            ;;
        --no-bashrc)
            CONFIG_BASHRC=false
            shift
            ;;
        --path-export)
            CONFIG_PATH_EXPORT=true
            shift
            ;;
        --no-path-export)
            CONFIG_PATH_EXPORT=false
            shift
            ;;
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            warn "Unknown option: $1"
            shift
            ;;
    esac
done

# Ask user a yes/no question
# Usage: ask_user "prompt" default_value
# Returns: sets REPLY to true/false
ask_user() {
    local prompt="$1"
    local default="$2"

    if [[ "$NON_INTERACTIVE" == true ]]; then
        REPLY="$default"
        return
    fi

    local hint="[y/n]"
    if [[ "$default" == true ]]; then
        hint="[Y/n]"
    elif [[ "$default" == false ]]; then
        hint="[y/N]"
    fi

    # Always read from /dev/tty for curl | bash compatibility
    if [[ -e /dev/tty ]]; then
        echo -ne "${CYAN}$prompt ${BOLD}$hint${NC}: " > /dev/tty
        read -r response < /dev/tty
    else
        # Fallback: use defaults if no tty available
        warn "No terminal available, using default: $default"
        REPLY="$default"
        return
    fi

    case "$response" in
        [yY]|[yY][eE][sS])
            REPLY=true
            ;;
        [nN]|[nN][oO])
            REPLY=false
            ;;
        "")
            REPLY="$default"
            ;;
        *)
            REPLY="$default"
            ;;
    esac
}

print_header() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════╗"
    echo "║   tmux-manager installer v${VERSION}    ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${NC}"
}

print_header

# Check dependencies
info "Checking dependencies..."

if ! command -v tmux &> /dev/null; then
    error "tmux is not installed. Please install tmux first."
fi

if ! command -v git &> /dev/null; then
    error "git is not installed. Please install git first."
fi

success "Dependencies OK (tmux, git)"

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
        warn "Git clone failed, trying direct download..."
        mkdir -p "$INSTALL_DIR"
        curl -fsSL "https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/tmux-manager" -o "$INSTALL_DIR/tmux-manager"
    }
    success "Downloaded"
fi

# Make executable and create symlink
info "Installing binary..."
chmod +x "$INSTALL_DIR/tmux-manager"
ln -sf "$INSTALL_DIR/tmux-manager" "$BIN_DIR/tmux-manager"
success "Installed to $BIN_DIR/tmux-manager"

# ============================================
# WIZARD
# ============================================

echo
echo -e "${BOLD}${CYAN}── Configuration ──${NC}"
echo

BASHRC="$HOME/.bashrc"
PATH_IN_BASHRC=false
TMUX_MANAGER_IN_BASHRC=false

# Check current state
if grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null || [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    PATH_IN_BASHRC=true
fi

if grep -q "tmux-manager" "$BASHRC" 2>/dev/null; then
    TMUX_MANAGER_IN_BASHRC=true
fi

# Question 1: PATH export
if [[ "$PATH_IN_BASHRC" == true ]]; then
    success "~/.local/bin already in PATH"
else
    if [[ -n "$CONFIG_PATH_EXPORT" ]]; then
        # Use flag value
        if [[ "$CONFIG_PATH_EXPORT" == true ]]; then
            info "Adding ~/.local/bin to PATH..."
            echo '' >> "$BASHRC"
            echo '# Added by tmux-manager installer' >> "$BASHRC"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
            success "Added to PATH"
        else
            warn "Skipping PATH configuration (--no-path-export)"
        fi
    else
        # Ask user
        ask_user "Add ~/.local/bin to PATH in .bashrc?" true
        if [[ "$REPLY" == true ]]; then
            info "Adding ~/.local/bin to PATH..."
            echo '' >> "$BASHRC"
            echo '# Added by tmux-manager installer' >> "$BASHRC"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
            success "Added to PATH"
        fi
    fi
fi

# Question 2: Auto-start on SSH
if [[ "$TMUX_MANAGER_IN_BASHRC" == true ]]; then
    success "tmux-manager already configured for SSH auto-start"
else
    if [[ -n "$CONFIG_BASHRC" ]]; then
        # Use flag value
        if [[ "$CONFIG_BASHRC" == true ]]; then
            info "Configuring SSH auto-start..."

            # Remove old tmux auto-attach if present
            if grep -q "tmux attach-session.*tmux new-session" "$BASHRC" 2>/dev/null; then
                info "Removing old tmux auto-attach configuration..."
                cp "$BASHRC" "$BASHRC.bak"
                sed -i '/tmux attach-session.*tmux new-session/d' "$BASHRC"
                sed -i '/^if.*TMUX.*SSH_TTY.*then$/,/^fi$/d' "$BASHRC"
            fi

            cat >> "$BASHRC" << 'EOF'

# tmux-manager: Interactive tmux session selector on SSH login
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux-manager
fi
EOF
            success "SSH auto-start enabled"
        else
            warn "Skipping SSH auto-start (--no-bashrc)"
        fi
    else
        # Ask user
        echo
        echo -e "  ${BOLD}Auto-start on SSH login${NC}"
        echo -e "  When enabled, tmux-manager will automatically run when you"
        echo -e "  connect via SSH, letting you choose or create a tmux session."
        echo
        ask_user "Enable auto-start on SSH login?" true
        if [[ "$REPLY" == true ]]; then
            info "Configuring SSH auto-start..."

            # Remove old tmux auto-attach if present
            if grep -q "tmux attach-session.*tmux new-session" "$BASHRC" 2>/dev/null; then
                info "Removing old tmux auto-attach configuration..."
                cp "$BASHRC" "$BASHRC.bak"
                sed -i '/tmux attach-session.*tmux new-session/d' "$BASHRC"
                sed -i '/^if.*TMUX.*SSH_TTY.*then$/,/^fi$/d' "$BASHRC"
            fi

            cat >> "$BASHRC" << 'EOF'

# tmux-manager: Interactive tmux session selector on SSH login
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux-manager
fi
EOF
            success "SSH auto-start enabled"
        fi
    fi
fi

# ============================================
# DONE
# ============================================

echo
echo -e "${BOLD}${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   Installation complete!           ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════╝${NC}"
echo
echo -e "Usage:"
echo -e "  ${BOLD}tmux-manager${NC}    Run session manager"
echo
echo -e "Uninstall:"
echo -e "  ${BOLD}curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/uninstall.sh | bash${NC}"
echo
