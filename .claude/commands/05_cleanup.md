---
description: Safe dead code cleanup - detect and remove unused imports and dead files with dry-run verification
argument-hint: "[mode=imports|files|all] [scope=repo|path=...] [--apply] - cleanup mode and scope"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /05_cleanup

_Safe dead code cleanup with conservative detection and two-step verification._

## Core Philosophy

- **Two-step workflow**: Dry-run by default, `--apply` flag required for deletions
- **Conservative detection**: Tier 1 (imports) → Tier 2 (files) with explicit exclusions
- **Safe deletion**: Integrates with `safe-file-ops` skill (git rm, .trash/ for untracked)
- **Verification**: Project-specific commands after each batch (max 10 deletions)

## Usage

```bash
/05_cleanup [mode=imports|files|all] [scope=repo|path=...] [--apply]
```

**Modes**:
- `imports` (Tier 1): Unused import statements via `smart-import-generator.mjs`
- `files` (Tier 2): Dead files (zero references) via ripgrep
- `all` (Tier 1+2): Both imports and files

**Scope**:
- `repo` (default): Entire repository
- `path=...`: Specific path (e.g., `path=src/components`)

---

## Step 1: Parse Arguments

```bash
MODE="${MODE:-imports}"
SCOPE="${SCOPE:-repo}"
APPLY="${APPLY:-false}"

for arg in "$@"; do
  case $arg in
    mode=*) MODE="${arg#mode=}" ;;
    scope=*) SCOPE="${arg#scope=}" ;;
    path=*) SCOPE="${arg#path=}" ;;
    --apply) APPLY=true ;;
  esac
done

DETECTION_PATH="$([ "$SCOPE" = "repo" ] && echo "." || echo "$SCOPE")"
```

---

## Step 2: Detection Phase (Dry-Run)

### Tier 1: Unused Imports

```bash
if [ "$MODE" = "imports" ] || [ "$MODE" = "all" ]; then
  OUTPUT=$(node .claude/scripts/smart-import-generator.mjs --dir "$DETECTION_PATH" 2>&1)
  echo "$OUTPUT" | jq -r '.unused_imports[]? | select(.imports[].can_remove == true) |
    "| \(.file) | Unused import | Tier 1 | Low | npm test | git checkout HEAD -- \(.file) |"'
fi
```

### Tier 2: Dead Files

```bash
if [ "$MODE" = "files" ] || [ "$MODE" = "all" ]; then
  SOURCE_FILES=$(rg --files --type ts --type js --glob '!*.test.ts' --glob '!*.spec.ts' \
                 --glob '!*.mock.ts' --glob '!*.d.ts' --glob '!*.config.ts' \
                 --glob '!dist/**' --glob '!build/**' "$DETECTION_PATH")

  for file in $SOURCE_FILES; do
    REF_COUNT=$(check_file_references "$file")
    if [ "$REF_COUNT" -eq 0 ]; then
      RISK=$(calculate_risk_score "$file")
      echo "| $file | No inbound imports | Tier 2 | $RISK | npm test | git checkout HEAD -- $file |"
    fi
  done
fi
```

**Exclusions**: `index.ts`, `main.ts`, `cli.ts`, `*.config.ts`, `*.test.ts`, `*.spec.ts`, `*.mock.ts`, `*.d.ts`, `dist/**`, `build/**`

---

## Step 3: Candidates Table

**Output Format**:
```markdown
| Item | Reason | Detection | Risk | Verification | Rollback |
|------|--------|-----------|------|-------------|----------|
| src/utils/deprecated.ts | No inbound imports | Tier 2 | Medium | npm test | git checkout HEAD -- src/utils/deprecated.ts |
```

**Sorting**: Primary by Risk (Low first), Secondary by File Size

---

## Step 4: Two-Step Workflow

### Dry-Run (Default)

```bash
if [ "$APPLY" != "true" ]; then
  echo "🚨 DRY-RUN MODE - No files will be deleted"
  echo "→ Review candidates above, then run:"
  echo "   /05_cleanup mode=$MODE scope=$SCOPE --apply"
  exit 0
fi
```

### Apply Mode (--apply flag)

> **⚠️ CRITICAL**: Use `safe-file-ops` skill (@.claude/skills/safe-file-ops/SKILL.md)

```bash
VERIFICATION_CMD=$(detect_verification_command)
BATCH_SIZE=10

for candidate in $DELETION_CANDIDATES; do
  file=$(echo "$candidate" | cut -d'|' -f1 | xargs)
  git ls-files --error-unmatch "$file" >/dev/null 2>&1 && git rm "$file" || mkdir -p .trash && mv "$file" .trash/

  if ! ((++CURRENT_BATCH % BATCH_SIZE)); then
    eval "$VERIFICATION_CMD" || { echo "❌ Verification failed - rolling back"; rollback_current_batch; exit 1; }
  fi
done
```

---

## Step 5: Verification Command Detection

**Priority**: Custom → Monorepo → Package → Fallback

```bash
detect_verification_command() {
  grep -q "verification_command:" CLAUDE.local.md 2>/dev/null && \
    grep "verification_command:" CLAUDE.local.md | cut -d: -f2 && return
  [ -f "package.json" ] && { grep -q '"workspaces"' package.json 2>/dev/null && echo "npm test --workspaces" || echo "npm test"; return; }
  [ -f "pyproject.toml" ] && echo "pytest" && return
  [ -f "go.mod" ] && echo "go test ./..." && return
  echo "git status --porcelain"
}
```

---

## Safety & Examples

**Risk Levels**: Low (tests/mocks) | Medium (utils) | High (components/routes)

**Safety Checks**:
1. Dry-run default (always review first)
2. Verification commands after each batch
3. Stop-on-failure with automatic rollback
4. Safe-file-ops integration (git rm, .trash/)

**Limitations**: Tier 2 does not detect dynamic imports with variables; side-effect files may be missed

**Examples**:
```bash
/05_cleanup mode=imports                    # Detect unused imports
/05_cleanup mode=files                      # Detect dead files
/05_cleanup mode=imports --apply            # Execute deletions
/05_cleanup mode=files path=src/components  # Specific scope
```

---

## Success Criteria

- [ ] Candidates table generated (all 6 columns)
- [ ] Risk levels assigned (Low/Medium/High)
- [ ] Dry-run requires `--apply` flag
- [ ] Verification commands execute after batches
- [ ] Safe-file-ops integration verified
- [ ] Stop-on-failure with rollback

---

**Related**: @.claude/skills/safe-file-ops/SKILL.md | @.claude/skills/vibe-coding/SKILL.md
