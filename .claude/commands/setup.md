# /pilot:setup

> Initialize claude-pilot for this project

---

## Step 1: Create Directories

```bash
mkdir -p .pilot/{plan/{draft,pending,in_progress,done},state/archive}
echo "✓ .pilot directories created"
```

---

## Step 2: Configure Statusline

```bash
# 플러그인 설치 경로 찾기
PLUGIN_PATH=$(jq -r '.plugins["claude-pilot@claude-pilot"][0].installPath // empty' ~/.claude/plugins/installed_plugins.json 2>/dev/null)

# 소스 경로 결정
if [ -f ".claude/scripts/statusline.sh" ]; then
    SOURCE_SCRIPT=".claude/scripts/statusline.sh"
elif [ -n "$PLUGIN_PATH" ] && [ -f "$PLUGIN_PATH/.claude/scripts/statusline.sh" ]; then
    SOURCE_SCRIPT="$PLUGIN_PATH/.claude/scripts/statusline.sh"
else
    SOURCE_SCRIPT=""
fi

# 스크립트 복사 및 설정
if [ -n "$SOURCE_SCRIPT" ]; then
    mkdir -p .claude/scripts
    cp "$SOURCE_SCRIPT" .claude/scripts/statusline.sh
    chmod +x .claude/scripts/statusline.sh

    # settings.json에 statusLine 추가
    if [ -f ".claude/settings.json" ]; then
        if ! jq -e '.statusLine' .claude/settings.json >/dev/null 2>&1; then
            jq '. + {"statusLine": {"type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/statusline.sh"}}' \
              .claude/settings.json > tmp.json && mv tmp.json .claude/settings.json
        fi
    else
        echo '{"statusLine": {"type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/statusline.sh"}}' > .claude/settings.json
    fi
    echo "✓ Statusline configured"
else
    echo "⚠ Statusline script not found, skipping"
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
