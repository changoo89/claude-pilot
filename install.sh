#!/usr/bin/env bash
# claude-pilot CLI Installer
# One-line installation script for claude-pilot Python CLI
#
# Usage:
#   Install: curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Version
VERSION="3.3.0"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print banner
print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
       _                 _                  _ _       _
   ___| | __ _ _   _  __| | ___       _ __ (_) | ___ | |_
  / __| |/ _` | | | |/ _` |/ _ \_____| '_ \| | |/ _ \| __|
 | (__| | (_| | |_| | (_| |  __/_____| |_) | | | (_) | |_
  \___|_|\__,_|\__,_|\__,_|\___|     | .__/|_|_|\___/ \__|
                                     |_|
                         Your Claude Code Pilot
EOF
    echo -e "${NC}"
    echo -e "${GREEN}claude-pilot v${VERSION} CLI Installer${NC}"
    echo ""
}

# Function to print error and exit
error_exit() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    exit 1
}

# Function to print info
info() {
    echo -e "${BLUE}→${NC} $1"
}

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Function to print dim text
dim() {
    echo -e "${DIM}  $1${NC}"
}

# Spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}%c${NC}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# =============================================================================
# PATH MANAGEMENT
# =============================================================================

# Get user's bin directory
get_user_bin_dir() {
    if command -v python3 &> /dev/null; then
        python3 -m site --user-base 2>/dev/null | xargs -I {} echo "{}/bin"
    else
        echo "$HOME/.local/bin"
    fi
}

# Detect shell config file
get_shell_config() {
    local shell_name=$(basename "$SHELL")
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash)
            if [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.profile" ;;
    esac
}

# Add to PATH if needed
setup_path() {
    local bin_dir=$(get_user_bin_dir)
    local config_file=$(get_shell_config)

    # Check if already in PATH
    if echo "$PATH" | tr ':' '\n' | grep -q "^${bin_dir}$"; then
        return 0
    fi

    # Check if already in config file
    if [[ -f "$config_file" ]] && grep -q "$bin_dir" "$config_file" 2>/dev/null; then
        return 0
    fi

    # Add to config file
    local path_export="export PATH=\"$bin_dir:\$PATH\""

    echo "" >> "$config_file"
    echo "# Added by claude-pilot installer" >> "$config_file"
    echo "$path_export" >> "$config_file"

    # Export for current session
    export PATH="$bin_dir:$PATH"

    return 1  # Indicates PATH was modified
}

# =============================================================================
# INSTALLATION
# =============================================================================

# Check for pipx or pip
check_installation_method() {
    if command -v pipx &> /dev/null; then
        echo "pipx"
    elif command -v pip3 &> /dev/null; then
        echo "pip3"
    elif command -v pip &> /dev/null; then
        echo "pip"
    else
        echo ""
    fi
}

# Install pipx if not available
ensure_pipx() {
    if command -v pipx &> /dev/null; then
        return 0
    fi

    # Try to install pipx
    if command -v pip3 &> /dev/null; then
        pip3 install --user pipx > /dev/null 2>&1
        # Add pipx to PATH for this session
        local user_bin=$(python3 -m site --user-base 2>/dev/null)/bin
        export PATH="$user_bin:$PATH"
        # Run ensurepath to set up PATH permanently
        "$user_bin/pipx" ensurepath > /dev/null 2>&1 || true
        return 0
    fi
    return 1
}

# Install using pipx (preferred)
install_with_pipx() {
    pipx install claude-pilot --force > /dev/null 2>&1
    pipx ensurepath > /dev/null 2>&1 || true
}

# Install using pip
install_with_pip() {
    local pip_cmd=$1
    $pip_cmd install --user --upgrade claude-pilot > /dev/null 2>&1
}

# Main installation flow
do_install() {
    print_banner

    # Check Python
    if ! command -v python3 &> /dev/null; then
        error_exit "Python 3 is required but not found. Please install Python 3.9+ first."
    fi

    # Try to use pipx (preferred) - install if needed
    info "Installing claude-pilot..."

    if command -v pipx &> /dev/null; then
        dim "Using pipx (recommended)"
        install_with_pipx &
        spinner $!
        wait $!
    elif ensure_pipx && command -v pipx &> /dev/null; then
        dim "Installed pipx, using it now"
        install_with_pipx &
        spinner $!
        wait $!
    elif command -v pip3 &> /dev/null; then
        dim "Using pip3"
        install_with_pip "pip3" &
        spinner $!
        wait $!
        setup_path || true
    elif command -v pip &> /dev/null; then
        dim "Using pip"
        install_with_pip "pip" &
        spinner $!
        wait $!
        setup_path || true
    else
        error_exit "Neither pipx nor pip found. Please install pip first:\n  python3 -m ensurepip --upgrade"
    fi

    echo ""

    # Verify installation
    local bin_dir=$(get_user_bin_dir)
    local config_file=$(get_shell_config)

    if command -v claude-pilot &> /dev/null; then
        # Already in PATH - best case
        success "Installation complete!"
        echo ""
        local installed_version=$(claude-pilot --version 2>/dev/null | head -1)
        dim "Installed: $installed_version"
        echo ""
        info "Quick Start:"
        echo -e "  ${CYAN}cd${NC} your-project"
        echo -e "  ${CYAN}claude-pilot init .${NC}"
        echo ""
    elif [[ -f "$bin_dir/claude-pilot" ]]; then
        # Installed but not in current PATH
        success "Installation complete!"
        echo ""
        local installed_version=$("$bin_dir/claude-pilot" --version 2>/dev/null | head -1)
        dim "Installed: $installed_version"
        echo ""
        info "Quick Start (works right now):"
        echo -e "  ${CYAN}${bin_dir}/claude-pilot init .${NC}"
        echo ""
        info "Or open a ${GREEN}new terminal${NC} and run:"
        echo -e "  ${CYAN}claude-pilot init .${NC}"
        echo ""
    else
        warning "Installation completed but verification failed."
        echo ""
        info "Try manually:"
        echo -e "  ${CYAN}pip3 install claude-pilot${NC}"
        echo ""
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    do_install
}

main
