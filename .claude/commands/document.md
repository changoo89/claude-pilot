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

**Size**: ≤200 lines per file

---

## Step 3: Verify Compliance

Run `docs-verify.sh --strict` for comprehensive validation:

```bash
# Run full documentation verification with strict mode
# - Tier 1 line limits (≤200 lines): CLAUDE.md, project-structure.md, docs-overview.md
# - ai-context file count (exactly 2 files)
# - Cross-reference validation
# - Circular reference detection

.claude/scripts/docs-verify.sh --strict

# On failure: Script exits with error code and prints refactoring instructions
# Fix violations before proceeding
```

**Validation includes**:
- All 3 Tier 1 docs ≤200 lines (FAIL on violation, not warn)
- docs/ai-context/ contains exactly 2 files
- No broken cross-references
- No circular references

---

## Related Skills

**three-tier-docs**: Full 3-tier system | **vibe-coding**: File size standards

---

**See**: @.claude/skills/three-tier-docs/SKILL.md
