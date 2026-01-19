# /pilot:setup

> **Purpose**: Configure claude-pilot plugin with MCP servers, settings merge, and project initialization
> **Scope**: Initial setup after plugin installation

---

## Overview

This command sets up claude-pilot by:
1. Merging `.claude/settings.json` (hooks, LSP, permissions)
2. Creating `.pilot/` directories for plan management
3. Setting hooks executable permissions
4. Prompting for language selection (en/ko/ja)
5. Detecting project type and configuring LSP
6. Configuring recommended MCP servers (with merge strategy)
7. Optionally prompting user to star the GitHub repository

---

## Setup Preparation

Disable typecheck and lint hooks during setup to avoid unnecessary full project scans:

```bash
export PILOT_SETUP_IN_PROGRESS=1
```

---

## Step 1: Verify Plugin Installation

First, confirm the plugin is properly installed:

```bash
# Check plugin files exist
ls -la .claude-plugin/marketplace.json .claude-plugin/plugin.json

# Count commands, agents, skills
echo "Commands: $(ls -1 .claude/commands/*.md 2>/dev/null | wc -l)"
echo "Agents: $(ls -1 .claude/agents/*.md 2>/dev/null | wc -l)"
echo "Skills: $(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l)"
```

Expected output:
- marketplace.json and plugin.json exist
- Commands: 9+
- Agents: 8+
- Skills: 5+

---

## Step 2: Merge .claude/settings.json

**IMPORTANT**: This setup merges claude-pilot's settings with your existing settings, preserving your configurations.

### Settings Merge Strategy

**Logic**:
1. Read user's existing `~/.claude/settings.json` (if exists)
2. Merge claude-pilot's hooks, LSP, permissions
3. Preserve user settings on conflict (user wins)
4. Write merged settings to project `.claude/settings.json`

```bash
# Get user's home directory
USER_HOME="${HOME}"
USER_SETTINGS="${USER_HOME}/.claude/settings.json"
PROJECT_SETTINGS=".claude/settings.json"

# Check if user has existing settings
if [ -f "$USER_SETTINGS" ]; then
    echo "Existing user settings found. Merging configurations..."

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "WARNING: jq is required for settings merge"
        echo "Install jq: brew install jq (macOS) or sudo apt-get install jq (Ubuntu)"
        echo "Skipping settings merge. Using default settings."
    else
        # Create temporary merged settings
        TMPFILE=$(mktemp)

        # Merge strategy: Start with user settings, add plugin hooks/LSP/permissions
        # User settings take precedence on conflicts
        jq -s '
            # Merge two settings objects
            .[0] as $user | .[1] as $plugin |
            {
                # Use $schema from user if exists, otherwise plugin
                ($user.$schema // $plugin.$schema) as $schema |
                # Merge env (user takes precedence)
                env: ($plugin.env // {}) + ($user.env // {}),
                # Use language from selection (will be set in Step 5)
                language: ($user.language // $plugin.language),
                # Merge other boolean settings
                alwaysThinkingEnabled: ($user.alwaysThinkingEnabled // $plugin.alwaysThinkingEnabled),
                enableAllProjectMcpServers: ($user.enableAllProjectMcpServers // $plugin.enableAllProjectMcpServers),
                # Merge enabled MCP servers (combine unique)
                enabledMcpjsonServers: (($user.enabledMcpjsonServers // []) + ($plugin.enabledMcpjsonServers // [])) | unique,
                # Merge permissions (combine unique)
                permissions: {
                    allow: (($user.permissions.allow // []) + ($plugin.permissions.allow // [])) | unique,
                    ask: (($user.permissions.ask // []) + ($plugin.permissions.ask // [])) | unique,
                    deny: (($user.permissions.deny // []) + ($plugin.permissions.deny // [])) | unique
                },
                # Merge hooks (user takes precedence on conflicts)
                hooks: ($user.hooks // $plugin.hooks),
                # Merge LSP (combine all)
                lsp: ($plugin.lsp // {}) + ($user.lsp // {}),
                # Preserve statusLine from user if exists
                statusLine: ($user.statusLine // $plugin.statusLine)
            } | if $schema != null then . + {"$schema": $schema} else . end
        "$USER_SETTINGS" "$PROJECT_SETTINGS" > "$TMPFILE"

        # Validate JSON before replacing
        if jq empty "$TMPFILE" 2>/dev/null; then
            mv "$TMPFILE" "$PROJECT_SETTINGS"
            echo "Settings merged successfully. Your configurations preserved."
        else
            rm -f "$TMPFILE"
            echo "ERROR: Invalid JSON generated during merge" >&2
            echo "Using default settings."
        fi
    fi
else
    echo "No existing user settings found. Using default settings."
    echo "These will be saved to: $PROJECT_SETTINGS"
fi
```

---

## Step 3: Create .pilot/ Directories

Create the plan management directory structure:

```bash
# Create .pilot/plan directory structure
echo "Creating .pilot/ directories..."

mkdir -p .pilot/plan/pending
mkdir -p .pilot/plan/in_progress
mkdir -p .pilot/plan/done
mkdir -p .pilot/plan/active

echo "Created .pilot/plan/{pending,in_progress,done,active}/"
```

---

## Step 4: Set Hooks Executable Permissions

Ensure all hook scripts have execute permissions:

```bash
# Check if hooks are executable before running chmod
echo "Checking hook script permissions..."

# Count non-executable hooks (portable method for macOS/Linux)
NON_EXEC_COUNT=0
for hook in .claude/scripts/hooks/*.sh; do
    if [ -f "$hook" ] && [ ! -x "$hook" ]; then
        NON_EXEC_COUNT=$((NON_EXEC_COUNT + 1))
    fi
done

if [ "$NON_EXEC_COUNT" -gt 0 ]; then
    echo "Found $NON_EXEC_COUNT non-executable hook(s). Fixing permissions..."

    # Set execute permissions on all .sh files in hooks directory
    find .claude/scripts/hooks -name "*.sh" -type f -exec chmod +x {} \;

    echo "✓ Permissions fixed automatically"
else
    echo "✓ All hooks already executable (no fix needed)"
fi

# Verify permissions
echo ""
echo "Hook scripts permissions:"
ls -la .claude/scripts/hooks/*.sh

# Final verification (portable method)
EXEC_COUNT=0
TOTAL_COUNT=0
for hook in .claude/scripts/hooks/*.sh; do
    if [ -f "$hook" ]; then
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        if [ -x "$hook" ]; then
            EXEC_COUNT=$((EXEC_COUNT + 1))
        fi
    fi
done

echo ""
if [ "$EXEC_COUNT" -eq "$TOTAL_COUNT" ]; then
    echo "✓ All $TOTAL_COUNT hook(s) have execute permissions"
else
    echo "⚠ Warning: Only $EXEC_COUNT of $TOTAL_COUNT hooks are executable"
fi
```

---

## Step 5: Language Selection

Prompt user to select their preferred language:

**User Question**:
```
Select language / 언어 선택 / 语言选择:

1. English (en)
2. 한국어 (ko)
3. 日本語 (ja)
```

### Handle Language Selection

**Option 1: English (en)**
```bash
echo "Language set to English"

# Update settings.json with selected language
if [ -f ".claude/settings.json" ] && command -v jq &> /dev/null; then
    TMPFILE=$(mktemp)
    jq '.language = "en"' .claude/settings.json > "$TMPFILE"
    jq empty "$TMPFILE" 2>/dev/null && mv "$TMPFILE" .claude/settings.json || rm -f "$TMPFILE"
fi
```

**Option 2: 한국어 (ko)**
```bash
echo "언어가 한국어로 설정되었습니다"

# Update settings.json with selected language
if [ -f ".claude/settings.json" ] && command -v jq &> /dev/null; then
    TMPFILE=$(mktemp)
    jq '.language = "ko"' .claude/settings.json > "$TMPFILE"
    jq empty "$TMPFILE" 2>/dev/null && mv "$TMPFILE" .claude/settings.json || rm -f "$TMPFILE"
fi
```

**Option 3: 日本語 (ja)**
```bash
echo "言語が日本語に設定されました"

# Update settings.json with selected language
if [ -f ".claude/settings.json" ] && command -v jq &> /dev/null; then
    TMPFILE=$(mktemp)
    jq '.language = "ja"' .claude/settings.json > "$TMPFILE"
    jq empty "$TMPFILE" 2>/dev/null && mv "$TMPFILE" .claude/settings.json || rm -f "$TMPFILE"
fi
```

---

## Step 6: Project Type Detection and LSP Configuration

Detect project type and configure appropriate LSP servers:

```bash
# Detect project type
echo "Detecting project type..."

PROJECT_TYPE="unknown"
if [ -f "package.json" ]; then
    PROJECT_TYPE="node"
    echo "Detected: Node.js project"
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    PROJECT_TYPE="python"
    echo "Detected: Python project"
elif [ -f "go.mod" ]; then
    PROJECT_TYPE="go"
    echo "Detected: Go project"
elif [ -f "Cargo.toml" ]; then
    PROJECT_TYPE="rust"
    echo "Detected: Rust project"
else
    echo "No specific project type detected. Using default LSP configuration."
fi

# Configure LSP based on project type
if [ -f ".claude/settings.json" ] && command -v jq &> /dev/null; then
    case "$PROJECT_TYPE" in
        node)
            echo "Configuring LSP for Node.js (TypeScript/JavaScript)..."
            # Already configured in default settings.json
            ;;
        python)
            echo "Configuring LSP for Python..."
            # Already configured in default settings.json
            ;;
        go)
            echo "Configuring LSP for Go..."
            # Already configured in default settings.json
            ;;
        rust)
            echo "Configuring LSP for Rust..."
            # Already configured in default settings.json
            ;;
        *)
            echo "Using default LSP configuration for all supported languages."
            ;;
    esac
    echo "LSP configuration complete."
else
    echo "Skipping LSP configuration (jq not available or settings.json missing)."
fi
```

---

## Step 7: Configure MCP Servers

### MCP Merge Strategy

**IMPORTANT**: This setup uses a merge strategy to preserve existing MCP configurations.

**Logic**:
1. If project `.mcp.json` exists → Merge (preserve user's existing servers, add only new ones)
2. If no `.mcp.json` exists → Create new with recommended servers
3. If server name conflict → Skip (preserve user's config)

### Recommended MCP Servers

| Server | Purpose | Command |
|--------|---------|---------|
| **context7** | Latest library documentation | `npx -y @modelcontextprotocol/server-context7` |
| **serena** | Semantic code operations | `npx -y @modelcontextprotocol/server-serena` |
| **grep-app** | Advanced search operations | `npx -y @modelcontextprotocol/server-grep-app` |
| **sequential-thinking** | Complex reasoning | `npx -y @modelcontextprotocol/server-sequential-thinking` |

### MCP Configuration Script

```bash
# Check for required dependencies
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is required but not installed"
    echo ""
    echo "Install jq:"
    echo "  macOS:   brew install jq"
    echo "  Ubuntu:  sudo apt-get install jq"
    echo "  Docs:    https://stedolan.github.io/jq/"
    echo ""
    echo "Skipping MCP server configuration."
    echo "You can manually configure MCP servers later."
else
    # Check if .mcp.json exists in project
    if [ -f ".mcp.json" ]; then
        echo "Existing .mcp.json found. Merging recommended servers..."

        # Read existing mcpServers
        EXISTING_SERVERS=$(jq '.mcpServers | keys' .mcp.json)

    # Define recommended servers
    RECOMMENDED_SERVERS=(
        "context7"
        "serena"
        "grep-app"
        "sequential-thinking"
    )

    # Add only new servers (skip if exists)
    for server in "${RECOMMENDED_SERVERS[@]}"; do
        if echo "$EXISTING_SERVERS" | grep -q "\"$server\""; then
            echo "  ✓ $server already configured (skipping)"
        else
            echo "  + Adding $server..."
            # Add server to .mcp.json with atomic write pattern
            TMPFILE=$(mktemp)
            if jq --arg server "$server" \
               '.mcpServers[$server] = {
                 "command": "npx",
                 "args": ["-y", "@modelcontextprotocol/server-" + $server],
                 "description": "MCP server for " + $server
               }' .mcp.json > "$TMPFILE"; then
                # Validate JSON before replacing original
                if jq empty "$TMPFILE" 2>/dev/null; then
                    mv "$TMPFILE" .mcp.json
                else
                    rm -f "$TMPFILE"
                    echo "  ERROR: Invalid JSON generated for $server" >&2
                    exit 1
                fi
            else
                rm -f "$TMPFILE"
                echo "  ERROR: jq processing failed for $server" >&2
                exit 1
            fi
        fi
    done

    echo "Merge complete. Existing configurations preserved."
    else
        echo "No .mcp.json found. Creating new configuration..."

    # Create .mcp.json with recommended servers
    cat > .mcp.json << 'EOF'
{
  "$schema": "https://modelcontextprotocol.io/schema.json",
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-context7"],
      "description": "Retrieve up-to-date documentation and code examples for any library"
    },
    "serena": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-serena"],
      "description": "Semantic code operations with LSP-powered tools"
    },
    "grep-app": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-grep-app"],
      "description": "Advanced search and grep operations"
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "description": "Complex reasoning and step-by-step thinking"
    }
  },
  "recommendedServers": [
    {
      "name": "context7",
      "purpose": "Latest library documentation",
      "url": "https://github.com/modelcontextprotocol/servers/tree/main/src/context7"
    },
    {
      "name": "serena",
      "purpose": "Semantic code operations",
      "url": "https://github.com/modelcontextprotocol/servers/tree/main/src/serena"
    },
    {
      "name": "grep-app",
      "purpose": "Advanced search",
      "url": "https://github.com/modelcontextprotocol/servers/tree/main/src/grep-app"
    },
    {
      "name": "sequential-thinking",
      "purpose": "Complex reasoning",
      "url": "https://github.com/modelcontextprotocol/servers/tree/main/src/sequential-thinking"
    }
  ]
}
EOF
        echo "Created .mcp.json with 4 recommended MCP servers."
    fi
fi
```

---

## Step 8: Create CLAUDE.local.md (Optional)

Offer to create project-specific documentation template:

**User Question**:
```
Would you like to create CLAUDE.local.md for your project?

CLAUDE.local.md contains your project-specific:
- Structure and organization
- Testing strategy and coverage targets
- Quality standards and pre-commit hooks
- MCP server configuration
- Documentation conventions

Options:
1. Yes, create CLAUDE.local.md from template
2. No thanks (I'll create it manually later)
```

**Option 1: Yes (Create Template)**

```bash
# Check if template exists
TEMPLATE_FILE=".claude/templates/CLAUDE.local.template.md"
if [ -f "$TEMPLATE_FILE" ]; then
    # Copy template to project root
    cp "$TEMPLATE_FILE" ./CLAUDE.local.md
    echo "✓ CLAUDE.local.md created from template"
    echo ""
    echo "Next steps:"
    echo "  1. Edit CLAUDE.local.md with your project details"
    echo "  2. Customize YAML configuration (coverage, testing, etc.)"
    echo "  3. Update project structure section"
    echo "  4. Add your quality standards and conventions"
    echo ""
    echo "Template location: $TEMPLATE_FILE"
    echo "Your file: ./CLAUDE.local.md"
else
    echo "⚠ Template not found at: $TEMPLATE_FILE"
    echo "You can create CLAUDE.local.md manually later."
fi
```

**Option 2: No Thanks**

```bash
echo "✓ Skipping CLAUDE.local.md creation"
echo ""
echo "You can create it later with:"
echo "  cp .claude/templates/CLAUDE.local.template.md ./CLAUDE.local.md"
echo ""
echo "See docs/ai-context/project-structure.md for details."
```

---

## Step 9: Ask About Starring

Use AskUserQuestion to ask the user if they'd like to ⭐ star the claude-pilot repository on GitHub to support the project.

**User Question**:
```
Would you like to star the claude-pilot repository on GitHub?

Options:
1. Yes, star the repo
2. No thanks
```

**Option 1: Yes (Automatic Star)**

```bash
# Check if gh CLI is available and run
if command -v gh &> /dev/null; then
    gh api -X PUT /user/starred/changoo89/claude-pilot
    echo ""
    echo "  ⭐ 깃허브 스타 완료!"
    echo "  claude-pilot를 사용해 주셔서 정말 감사합니다 🎉"
    echo "  여러분의 응원이 더 나은 기능을 만드는 큰 힘이 됩니다 💪"
    echo ""
else
    # If gh is not available or the command fails, provide the manual link
    echo ""
    echo "  아래 링크에서 수동으로 스타를 눌러주세요:"
    echo "  https://github.com/changoo89/claude-pilot"
    echo ""
    echo "  여러분의 작은 응원이 큰 힘이 됩니다 ⭐"
    echo ""
fi
```

**Option 2: No Thanks**

```bash
echo ""
echo "  괜찮습니다! 😊"
echo "  claude-pilot을 사용해 주셔서 감사합니다"
echo "  편하게 문의사이트나 이슈트래커를 통해 피드백 주시면"
echo "  더 나은 경험을 만드는 데 큰 도움이 됩니다 💬"
echo ""
```

---

## Step 10: Update .gitignore for CLAUDE.local.md

Add gitignore entries to keep project-specific documentation private:

```bash
# Get project root
GITIGNORE_PATH="$(git rev-parse --show-toplevel)/.gitignore"

# Check if .gitignore exists
if [ ! -f "$GITIGNORE_PATH" ]; then
    echo "ERROR: .gitignore not found at $GITIGNORE_PATH" >&2
    exit 1
fi

# Backup .gitignore
cp "$GITIGNORE_PATH" "${GITIGNORE_PATH}.backup"

# Add CLAUDE.local.md entry (idempotent)
if ! grep -q "^CLAUDE\.local\.md$" "$GITIGNORE_PATH"; then
    echo "CLAUDE.local.md" >> "$GITIGNORE_PATH"
    echo "✓ Added CLAUDE.local.md to .gitignore"
else
    echo "✓ CLAUDE.local.md already in .gitignore"
fi

# Add .claude/*.local.md pattern (idempotent)
if ! grep -q "\.claude/\*\.local\.md$" "$GITIGNORE_PATH"; then
    echo ".claude/*.local.md" >> "$GITIGNORE_PATH"
    echo "✓ Added .claude/*.local.md pattern to .gitignore"
else
    echo "✓ .claude/*.local.md pattern already in .gitignore"
fi

# Remove backup on success
rm "${GITIGNORE_PATH}.backup"

# Verify gitignore behavior
if git check-ignore -v CLAUDE.local.md >/dev/null 2>&1; then
    echo "✓ CLAUDE.local.md will be gitignored"
else
    echo "⚠ Warning: CLAUDE.local.md may not be gitignored correctly"
fi
```

---

## Step 11: Verify Setup

Run verification commands to confirm setup complete:

```bash
# Display formatted status report
echo "claude-pilot Status"
echo "───────────────────────────────────────────────────"
MCP_COUNT=$(jq '.mcpServers | keys | length' .mcp.json 2>/dev/null || echo '0')
HOOKS_COUNT=$(find .claude/scripts/hooks -name '*.sh' -executable 2>/dev/null | wc -l | tr -d ' ')
LANGUAGE=$(jq -r '.language // "en"' .claude/settings.json 2>/dev/null || echo 'en')
PROJECT_TYPE="generic"
[ -f "package.json" ] && PROJECT_TYPE="node"
[ -f "pyproject.toml" ] || [ -f "requirements.txt" ] && PROJECT_TYPE="python"
[ -f "go.mod" ] && PROJECT_TYPE="go"
[ -f "Cargo.toml" ] && PROJECT_TYPE="rust"
echo "MCP Servers:    ✓ ${MCP_COUNT} configured"
echo "Hooks:          ✓ ${HOOKS_COUNT} executable"
echo "Plans:          ✓ .pilot/plan/ created"
echo "Language:       ✓ ${LANGUAGE}"
echo "Project Type:   ✓ ${PROJECT_TYPE}"
echo "───────────────────────────────────────────────────"
echo ""

# Detailed verification
echo "Plan directories:"
ls -la .pilot/plan/ 2>/dev/null || echo "  (No .pilot/plan/ found)"

echo ""
echo "Hook scripts (should have execute permissions):"
ls -la .claude/scripts/hooks/*.sh

echo ""
echo "Settings configured:"
jq '.language' .claude/settings.json 2>/dev/null || echo "  (No settings.json found)"

echo ""
echo "MCP Servers configured:"
jq '.mcpServers | keys' .mcp.json 2>/dev/null || echo "  (No .mcp.json found)"

echo ""
echo "Plugin commands available:"
ls -1 .claude/commands/*.md 2>/dev/null | wc -l

# Show next steps
echo ""
echo "Setup complete! Available commands:"
echo "  /00_plan    - Create SPEC-First plan"
echo "  /01_confirm - Review plan before execution"
echo "  /02_execute - Implement with TDD"
echo "  /03_close   - Archive and commit"
echo "  /90_review  - Multi-angle code review"
echo "  /91_document - Auto-sync documentation"
echo "  /999_publish - Publishing checklist"
echo ""
echo "Get started: /00_plan \"your task here\""
```

---

## Cleanup

Re-enable hooks by clearing the setup flag:

```bash
unset PILOT_SETUP_IN_PROGRESS
echo "✓ Hooks re-enabled for normal development"
```

---

## Troubleshooting

### Issue: MCP servers not working

**Check**: `cat .mcp.json`

**Solution**: Ensure npx is available: `which npx`

### Issue: GitHub CLI not working

**Check**: `gh auth status`

**Solution**: Install GitHub CLI or star manually

### Issue: Commands not found

**Check**: `ls -la .claude/commands/`

**Solution**: Reinstall plugin: `/plugin install claude-pilot`

---

## Related Documentation

- **Plugin Installation**: README.md
- **MCP Servers**: https://modelcontextprotocol.io
- **GitHub CLI**: https://cli.github.com
