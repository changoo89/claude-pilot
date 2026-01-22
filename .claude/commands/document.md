---
description: Update project documentation with Context Engineering (full auto, no prompts)
argument-hint: "[auto-sync from RUN_ID] | [folder_name] - auto-sync from action_plan or generate folder CONTEXT.md"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*)
---

# /document

_Update documentation with full auto-sync and hierarchical CONTEXT.md management._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 in sequence
- This command has NO user interaction - run to completion

---

## Core Philosophy

**Full Auto**: No prompts, always full sync | **Context Engineering**: Generate folder CONTEXT.md | **Zero Intervention**: Complete without user interaction

---

## Step 1: Sync Tier 1 Documents

**Tier 1 Structure** (3 files total):
- `CLAUDE.md` - Project architecture, features, Quick Start (≤200 lines)
- `docs/ai-context/project-structure.md` - Tech stack, file tree
- `docs/ai-context/docs-overview.md` - Documentation navigation, Tier mapping

**Required**: CLAUDE.md must reference project-structure.md and docs-overview.md at the top

---

## Step 2: Generate CONTEXT.md

```bash
for dir in src/ components/ lib/; do
    [ -d "$dir" ] || continue
    echo "# $(basename "$dir") Context" > "$dir/CONTEXT.md"
    echo "## Purpose" >> "$dir/CONTEXT.md"
    echo "## Key Files" >> "$dir/CONTEXT.md"
    ls -1 "$dir"*.ts 2>/dev/null | while read f; do
        echo "- **$(basename "$f")**: Purpose" >> "$dir/CONTEXT.md"
    done
done
```

**Size**: ≤100 lines per file

---

## Step 3: Verify Compliance

```bash
# Tier 1 validation
test $(wc -l < CLAUDE.md) -le 200 || echo "CLAUDE.md too large"
test $(find docs/ai-context -maxdepth 1 -name "*.md" | wc -l) -eq 2 || echo "docs/ai-context should have exactly 2 files"

# Tier 2 validation
for f in **/CONTEXT.md; do test $(wc -l < "$f") -le 100 || echo "$f too large"; done

# Circular reference validation
.claude/scripts/docs-verify.sh --circular-check
```

---

## Related Skills

**three-tier-docs**: Full 3-tier system | **vibe-coding**: File size standards

---

**See**: @.claude/skills/three-tier-docs/SKILL.md
