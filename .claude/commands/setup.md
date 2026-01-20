# /pilot:setup

> **Purpose**: Configure claude-pilot plugin with MCP servers and project initialization

---

## Overview

Setup claude-pilot by:
1. Merge `.claude/settings.json` (hooks, LSP, permissions)
2. Create `.pilot/` directories
3. Set hooks executable
4. Detect project type
5. Configure MCP servers

---

## Step 1: Verify Plugin Installation

```bash
if [ ! -d ".claude" ]; then
    echo "❌ Not a claude-pilot project directory"
    exit 1
fi

echo "✓ claude-pilot plugin found"
```

---

## Step 2: Create Directories

```bash
mkdir -p .pilot/{plan/{pending,in_progress,done},state/archive}
mkdir -p .claude/{commands,skills,agents}
echo "✓ Directories created"
```

---

## Step 3: Merge Settings

```bash
if [ -f ".claude/settings.json" ]; then
    # Merge with project settings
    if [ -f ".claude/settings.local.json" ]; then
        jq -s '.[0] * .[1]' ".claude/settings.json" ".claude/settings.local.json" > merged.json
        mv merged.json ".claude/settings.json"
    fi
    echo "✓ Settings merged"
fi
```

---

## Step 4: Configure MCP Servers

```bash
# Auto-detect project type
if [ -f "package.json" ]; then
    PROJECT_TYPE="node"
elif [ -f "pyproject.toml" ]; then
    PROJECT_TYPE="python"
fi

# Configure recommended MCPs
echo "✓ Project type: $PROJECT_TYPE"
```

---

## Step 5: Set Permissions

```bash
find .claude/scripts -type f -exec chmod +x {} \;
echo "✓ Scripts executable"
```

---

## Complete

```bash
echo "✓ claude-pilot setup complete"
echo "  Run /00_plan to start working"
```

---

**See**: CLAUDE.md for plugin documentation
