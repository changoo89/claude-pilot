#!/usr/bin/env bash
# claude-pilot Installer
# One-line installation script for Claude Code preset

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Print banner
echo -e "${BLUE}"
cat << "EOF"
       _                 _                  _ _       _
   ___| | __ _ _   _  __| | ___       _ __ (_) | ___ | |_
  / __| |/ _` | | | |/ _` |/ _ \_____| '_ \| | |/ _ \| __|
 | (__| | (_| | |_| | (_| |  __/_____| |_) | | | (_) | |_
  \___|_|\__,_|\__,_|\__,_|\___|     | .__/|_|_|\___/ \__|
                                     |_|
                         Your Claude Code Copilot
EOF
echo -e "${NC}"
echo -e "${GREEN}claude-pilot v${VERSION}${NC}"
echo ""

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

# Check if curl is available
if ! command -v curl &> /dev/null; then
    error_exit "curl is required but not installed. Please install curl first."
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if running from cloned repo or via curl
if [[ -f "${SCRIPT_DIR}/.claude/settings.json" ]]; then
    # Running from cloned repo
    TEMPLATE_DIR="${SCRIPT_DIR}"
    info "Installing from local template: ${TEMPLATE_DIR}"
else
    # Running via curl - would need to download
    error_exit "Please clone the repository first or use local installation"
fi

# Ask for language preference
echo ""
info "Select your preferred language:"
echo "  1) English (en)"
echo "  2) Korean (ko)"
echo "  3) Japanese (ja)"
echo ""
read -p "Enter choice [1-3] (default: 1): " lang_choice
lang_choice=${lang_choice:-1}

case $lang_choice in
    1) LANGUAGE="en"; success "Language: English";;
    2) LANGUAGE="ko"; success "Language: Korean";;
    3) LANGUAGE="ja"; success "Language: Japanese";;
    *) warning "Invalid choice, defaulting to English"; LANGUAGE="en";;
esac

# Ask for installation directory
echo ""
read -p "Install to current directory? [Y/n]: " install_current
install_current=${install_current:-Y}

if [[ "$install_current" =~ ^[Yy]$ ]]; then
    TARGET_DIR="$(pwd)"
else
    read -p "Enter installation directory: " TARGET_DIR
    if [[ ! -d "$TARGET_DIR" ]]; then
        error_exit "Directory does not exist: $TARGET_DIR"
    fi
fi

success "Installing to: ${TARGET_DIR}"

# Ask about components
echo ""
info "Select components to install:"
read -p "Include commands? [Y/n]: " include_commands
include_commands=${include_commands:-Y}

read -p "Include hooks? [Y/n]: " include_hooks
include_hooks=${include_hooks:-Y}

read -p "Include guides? [Y/n]: " include_guides
include_guides=${include_guides:-Y}

read -p "Include templates? [Y/n]: " include_templates
include_templates=${include_templates:-Y}

# Create .claude directory if it doesn't exist
CLAUDE_DIR="${TARGET_DIR}/.claude"
if [[ -d "$CLAUDE_DIR" ]]; then
    warning ".claude directory already exists. Backing up..."
    BACKUP_DIR="${CLAUDE_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$CLAUDE_DIR" "$BACKUP_DIR"
    success "Backed up to: ${BACKUP_DIR}"
fi

mkdir -p "$CLAUDE_DIR"
success "Created .claude directory"

# Copy settings.json and update language
info "Configuring settings.json..."
if [[ -f "${TEMPLATE_DIR}/.claude/settings.json" ]]; then
    cp "${TEMPLATE_DIR}/.claude/settings.json" "${CLAUDE_DIR}/settings.json"
    # Update language using jq if available, otherwise sed
    if command -v jq &> /dev/null; then
        jq ".language = \"${LANGUAGE}\"" "${CLAUDE_DIR}/settings.json" > "${CLAUDE_DIR}/settings.json.tmp"
        mv "${CLAUDE_DIR}/settings.json.tmp" "${CLAUDE_DIR}/settings.json"
    else
        sed -i.bak "s/\"language\": \"[^\"]*\"/\"language\": \"${LANGUAGE}\"/" "${CLAUDE_DIR}/settings.json"
        rm -f "${CLAUDE_DIR}/settings.json.bak"
    fi
    success "Configured language: ${LANGUAGE}"
else
    warning "settings.json not found in template, creating default..."
    cat > "${CLAUDE_DIR}/settings.json" << EOF
{
  "language": "${LANGUAGE}",
  "alwaysThinkingEnabled": true,
  "enableAllProjectMcpServers": true,
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(git:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(grep:*)",
      "Read",
      "Write",
      "Edit"
    ],
    "deny": ["Bash(sudo:*)"]
  }
}
EOF
fi

# Copy commands
if [[ "$include_commands" =~ ^[Yy]$ ]]; then
    info "Installing commands..."
    mkdir -p "${CLAUDE_DIR}/commands"
    if [[ -d "${TEMPLATE_DIR}/.claude/commands" ]]; then
        cp -r "${TEMPLATE_DIR}/.claude/commands/"* "${CLAUDE_DIR}/commands/" 2>/dev/null || true
        success "Commands installed"
    fi
fi

# Copy hooks
if [[ "$include_hooks" =~ ^[Yy]$ ]]; then
    info "Installing hooks..."
    mkdir -p "${CLAUDE_DIR}/scripts/hooks"
    if [[ -d "${TEMPLATE_DIR}/.claude/scripts/hooks" ]]; then
        cp -r "${TEMPLATE_DIR}/.claude/scripts/hooks/"* "${CLAUDE_DIR}/scripts/hooks/" 2>/dev/null || true
        # Make hooks executable
        chmod +x "${CLAUDE_DIR}/scripts/hooks/"*.sh 2>/dev/null || true
        success "Hooks installed"
    fi
fi

# Copy guides
if [[ "$include_guides" =~ ^[Yy]$ ]]; then
    info "Installing guides..."
    mkdir -p "${CLAUDE_DIR}/guides"
    if [[ -d "${TEMPLATE_DIR}/.claude/guides" ]]; then
        cp -r "${TEMPLATE_DIR}/.claude/guides/"* "${CLAUDE_DIR}/guides/" 2>/dev/null || true
        success "Guides installed"
    fi
fi

# Copy templates
if [[ "$include_templates" =~ ^[Yy]$ ]]; then
    info "Installing templates..."
    mkdir -p "${CLAUDE_DIR}/templates"
    if [[ -d "${TEMPLATE_DIR}/.claude/templates" ]]; then
        cp -r "${TEMPLATE_DIR}/.claude/templates/"* "${CLAUDE_DIR}/templates/" 2>/dev/null || true
        success "Templates installed"
    fi
fi

# Copy main documentation files
info "Installing documentation..."
if [[ -f "${TEMPLATE_DIR}/CLAUDE.md" ]]; then
    cp "${TEMPLATE_DIR}/CLAUDE.md" "${TARGET_DIR}/CLAUDE.md"
    success "CLAUDE.md installed"
fi

if [[ -f "${TEMPLATE_DIR}/AGENTS.md" ]]; then
    cp "${TEMPLATE_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
    success "AGENTS.md installed"
fi

# Copy mcp.json if exists
if [[ -f "${TEMPLATE_DIR}/mcp.json" ]]; then
    cp "${TEMPLATE_DIR}/mcp.json" "${TARGET_DIR}/mcp.json"
    success "mcp.json installed"
fi

# Create .pilot directory for plan management
info "Creating .pilot directory..."
mkdir -p "${TARGET_DIR}/.pilot/plan/pending"
mkdir -p "${TARGET_DIR}/.pilot/plan/in_progress"
mkdir -p "${TARGET_DIR}/.pilot/plan/done"
mkdir -p "${TARGET_DIR}/.pilot/plan/active"
success ".pilot directory created"

# Summary
echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
info "Summary:"
echo "  Language: ${LANGUAGE}"
echo "  Target: ${TARGET_DIR}"
echo "  Settings: ${CLAUDE_DIR}/settings.json"
echo ""
info "Next Steps:"
echo "  1. Review CLAUDE.md and customize for your project"
echo "  2. Test: /00_plan 'test feature'"
echo "  3. Start building with /02_execute"
echo ""
info "Documentation:"
echo "  - Context Engineering: .claude/guides/context-engineering.md"
echo "  - Ralph Loop TDD: .claude/guides/ralph-loop-tdd.md"
echo ""
success "Happy coding with claude-pilot!"
echo ""
