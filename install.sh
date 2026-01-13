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
NC='\033[0m' # No Color

# Version
VERSION="2.0.0"

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
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print info
info() {
    echo -e "${BLUE}i${NC} $1"
}

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# =============================================================================
# INSTALLATION
# =============================================================================

# Check for pipx or pip
check_installation_method() {
    if command -v pipx &> /dev/null; then
        echo "pipx"
    elif command -v pip3 &> /dev/null; then
        echo "pip"
    else
        echo ""
    fi
}

# Install using pipx
install_with_pipx() {
    info "Installing claude-pilot with pipx..."
    pipx install claude-pilot
}

# Install using pip
install_with_pip() {
    info "Installing claude-pilot with pip..."
    pip3 install --user claude-pilot
}

# Main installation flow
do_install() {
    print_banner

    # Check installation method
    local method=$(check_installation_method)

    if [[ -z "${method}" ]]; then
        error_exit "Neither pipx nor pip3 found. Please install Python 3.9+ and pip first."
    fi

    success "Found ${method} - installing claude-pilot..."

    # Perform installation
    if [[ "${method}" == "pipx" ]]; then
        install_with_pipx
    else
        install_with_pip
    fi

    # Verify installation
    echo ""
    if command -v claude-pilot &> /dev/null; then
        success "CLI installed successfully!"
        echo ""
        info "Verification:"
        claude-pilot --version
        echo ""
        info "Usage:"
        echo "  cd your-project"
        echo "  claude-pilot init ."
        echo "  claude-pilot update"
        echo ""
    else
        warning "Installation completed, but 'claude-pilot' command not found in PATH."
        echo ""
        info "If you used pip --user, add to PATH:"
        echo "  export PATH=\"\$(python3 -m site --user-base)/bin:\$PATH\""
        echo "  # Add this to your ~/.zshrc or ~/.bashrc"
        echo ""
        info "Then verify with:"
        echo "  claude-pilot --version"
        echo ""
    fi

    success "Installation complete!"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    do_install
}

main
