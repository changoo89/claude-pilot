# /pilot:setup

> Initialize claude-pilot for this project

---

## MCP Servers (Recommended)

| Server | Purpose | Package |
|--------|---------|---------|
| **context7** | Latest library documentation | `@upstash/context7-mcp` |
| **filesystem** | Local file operations | `@modelcontextprotocol/server-filesystem` |
| **sequential-thinking** | Step-by-step reasoning | `@modelcontextprotocol/server-sequential-thinking` |

**Configuration**: Add to `~/.claude.json` under `projects.<project-path>.mcpServers`

---

## Step 1: Create Directories

```bash
mkdir -p .pilot/{plan/{draft,pending,in_progress,done},state/archive}
echo "✓ .pilot directories created"
```

---

## Step 2: Configure Statusline

```bash
# Unified statusline configuration script
# Always copies from plugin (ensures latest version), then updates settings.json

PLUGIN_PATH=$(jq -r '.plugins["claude-pilot@claude-pilot"][0].installPath // empty' ~/.claude/plugins/installed_plugins.json 2>/dev/null || true)
SOURCE=""

# Always prefer plugin version to ensure latest
[[ -n "$PLUGIN_PATH" && -f "$PLUGIN_PATH/.claude/scripts/statusline.sh" ]] && SOURCE="$PLUGIN_PATH/.claude/scripts/statusline.sh"

if [[ -n "$SOURCE" ]]; then
    mkdir -p .claude/scripts
    cp "$SOURCE" .claude/scripts/statusline.sh
    chmod +x .claude/scripts/statusline.sh

    SETTINGS=".claude/settings.json"
    STATUSLINE='{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/statusline.sh"}'

    if [[ -f "$SETTINGS" ]]; then
        jq --argjson sl "$STATUSLINE" '. + {statusLine: $sl}' "$SETTINGS" > /tmp/settings.json && mv /tmp/settings.json "$SETTINGS"
    else
        echo "{\"statusLine\": $STATUSLINE}" > "$SETTINGS"
    fi
    echo "✓ Statusline configured (from plugin v$(jq -r '.version' "$PLUGIN_PATH/.claude-plugin/plugin.json" 2>/dev/null || echo 'unknown'))"
else
    echo "⚠ Statusline script not found in plugin, skipping"
fi
```

---

## Step 3: Initial Documentation (Optional)

Use `AskUserQuestion` to ask if user wants to run initial documentation sync.

Options: "Yes, generate docs" / "No, skip"

**If yes**: Execute `/document` command (3-tier docs sync)
- Syncs CLAUDE.md
- Generates CONTEXT.md for folders
- Verifies compliance

**If no**: Skip and continue.

---

## Step 4: GitHub Star Request

Use `AskUserQuestion` to ask if user wants to star the repo.

Options: "Yes, star the repo" / "No thanks"

**If yes**: Check if `gh` CLI is available and run:
```bash
gh api -X PUT /user/starred/changoo89/claude-pilot
```

If `gh` is not available or fails, provide manual link:
```
https://github.com/changoo89/claude-pilot
```

**If no**: Thank them and continue.

---

## Complete

```bash
echo ""
echo "✓ claude-pilot setup complete"
echo "  Run /00_plan to start planning"
```

---

**See**: CLAUDE.md for plugin documentation
