# /pilot:setup

> **Purpose**: Configure claude-pilot plugin with MCP servers and optional GitHub star
> **Scope**: Initial setup after plugin installation

---

## Overview

This command sets up claude-pilot by:
1. Configuring recommended MCP servers (with merge strategy for existing configs)
2. Optionally prompting user to star the GitHub repository
3. Verifying plugin installation

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

## Step 2: Configure MCP Servers

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

## Step 3: GitHub Star Prompt (Optional)

### Prompt User

Ask the user if they'd like to star the repository:

**User Question**:
```
Would you like to star the claude-pilot repository on GitHub?
This helps support the project and makes it easier to find.

Options:
1. Yes, star it automatically! (requires GitHub CLI)
2. No thanks, maybe later
3. Open the repository page (I'll star manually)
```

### Handle Response

**Option 1: Yes (Automatic Star)**

```bash
# Check if gh CLI is installed and authenticated
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        # Star the repository
        gh api -X PUT /user/starred/changoo89/claude-pilot
        echo "✓ Starred changoo89/claude-pilot! Thank you for your support!"
    else
        echo "GitHub CLI found but not authenticated."
        echo "Please run: gh auth login"
        echo "Then star manually at: https://github.com/changoo89/claude-pilot"
    fi
else
    echo "GitHub CLI not found."
    echo "Please star manually at: https://github.com/changoo89/claude-pilot"
fi
```

**Option 2: No Thanks**

```bash
echo "No problem! You can always star later at:"
echo "https://github.com/changoo89/claude-pilot"
```

**Option 3: Open Repository Page**

```bash
echo "Opening repository page..."
open https://github.com/changoo89/claude-pilot 2>/dev/null || \
    xdg-open https://github.com/changoo89/claude-pilot 2>/dev/null || \
    echo "Please visit: https://github.com/changoo89/claude-pilot"
```

---

## Step 4: Verify Setup

Run verification commands to confirm setup complete:

```bash
# Verify MCP configuration
echo "MCP Servers configured:"
jq '.mcpServers | keys' .mcp.json 2>/dev/null || echo "  (No .mcp.json found)"

# Verify plugin commands
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
