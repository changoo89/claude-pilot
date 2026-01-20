---
description: Safe dead code cleanup - detect and remove unused imports and dead files with auto-apply for Low/Medium risk
argument-hint: "[mode=imports|files|all] [scope=repo|path=...] [--dry-run] [--apply] - cleanup mode and scope"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /05_cleanup

_Auto-apply dead code cleanup with risk-based confirmation._

## Core Philosophy

- **Auto-apply default**: Low/Medium risk items deleted without confirmation (interactive TTY)
- **Risk-based confirmation**: High-risk items require user confirmation
- **Safe flags**: `--dry-run` for preview, `--apply` for force-apply (mutually exclusive)
- **Verification**: Project-specific commands after each batch (max 10 deletions)
- **Rollback**: Automatic restore on verification failure

## Usage

```bash
/05_cleanup [mode=imports|files|docs|all] [scope=repo|path=...] [--dry-run] [--apply]
```

**Modes**:
- `imports` (Tier 1): Unused import statements
- `files` (Tier 2): Dead files (zero references)
- `docs` (Tier 3): Dead documentation files (zero @references)
- `all` (Tier 1+2+3): Imports, files, and documentation

**Scope**:
- `repo` (default): Entire repository
- `path=...`: Specific path (e.g., `path=src/components`)

**Flags**:
- `--dry-run`: Show candidates only, no deletions, no prompts
- `--apply`: Apply everything including High-risk, no prompts

---

## Step 1: Parse Arguments

```bash
MODE="${MODE:-imports}"
SCOPE="${SCOPE:-repo}"
DRY_RUN="${DRY_RUN:-false}"
APPLY="${APPLY:-false}"
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"

# Detect non-interactive environment (CI/non-TTY)
if [ ! -t 0 ] || [ -n "${CI:-}" ]; then
  NON_INTERACTIVE=true
fi

for arg in "$@"; do
  case $arg in
    mode=*) MODE="${arg#mode=}" ;;
    scope=*) SCOPE="${arg#scope=}" ;;
    path=*) SCOPE="${arg#path=}" ;;
    --dry-run) DRY_RUN=true ;;
    --apply) APPLY=true ;;
  esac
done

# Flag conflict detection (SC-5)
if [ "$DRY_RUN" = "true" ] && [ "$APPLY" = "true" ]; then
  echo "Error: --dry-run and --apply flags are mutually exclusive"
  echo ""
  echo "Usage: /05_cleanup [mode=imports|files|docs|all] [scope=...] [--dry-run | --apply]"
  echo "  --dry-run: Show candidates only, no deletions"
  echo "  --apply:   Apply everything including High-risk"
  exit 1
fi

# Non-interactive default (SC-10)
if [ "$NON_INTERACTIVE" = "true" ] && [ "$DRY_RUN" = "false" ] && [ "$APPLY" = "false" ]; then
  DRY_RUN=true
fi

DETECTION_PATH="$([ "$SCOPE" = "repo" ] && echo "." || echo "$SCOPE")"
```

---

## Step 2: Risk Level Classification (SC-6)

### Code File Risk Classification

```bash
# Calculate risk level for a code file
calculate_risk_level() {
  local file="$1"

  # Test files - Low risk
  if [[ "$file" =~ \.(test|spec|mock)\.(ts|js|go|py)$ ]] || [[ "$file" =~ _test\.(go|py)$ ]]; then
    echo "Low"
    return
  fi

  # Utility/helper files - Medium risk
  if [[ "$file" =~ (utils|helpers|lib)/.*\.(ts|js|go|py)$ ]]; then
    echo "Medium"
    return
  fi

  # Core components/routes - High risk
  if [[ "$file" =~ (components|routes|pages|controllers|models|services)/.*\.(ts|js|tsx|jsx|go|py)$ ]]; then
    echo "High"
    return
  fi

  # Default - Medium risk
  echo "Medium"
}

# Calculate risk score for backward compatibility
calculate_risk_score() {
  calculate_risk_level "$1"
}
```

### Documentation File Risk Classification (SC-3)

```bash
# Calculate risk level for a documentation file
calculate_doc_risk_level() {
  local file="$1"
  local basename
  basename=$(basename "$file" .md)

  # High risk: Core documentation files
  if [[ "$file" =~ CONTEXT\.md$ ]] || \
     [[ "$file" =~ CLAUDE\.md$ ]] || \
     [[ "$basename" =~ ^(README|ARCHITECTURE|DESIGN|CHANGELOG|CONTRIBUTING)$ ]]; then
    echo "High"
    return
  fi

  # Low risk: Deprecated/obsolete files
  if [[ "$file" =~ (deprecated|old|backup|archive|obsolete) ]] || \
     [[ "$basename" =~ (deprecated|old|backup|archive|obsolete) ]]; then
    echo "Low"
    return
  fi

  # Medium risk: Default for guides, commands, skills, agents
  echo "Medium"
}
```

---

## Step 2.5: Documentation Reference Detection (SC-2)

```bash
# Count @references to a documentation file
check_doc_references() {
  local file="$1"
  local basename
  basename=$(basename "$file" .md)

  # Count @references using ripgrep
  # Pattern: @basename.md or @basename (without .md extension)
  local ref_count
  ref_count=$(rg --glob '*.md' --glob '!*.md.bak' \
    --glob '!docs/**' \
    "@${basename}(\\.md)?\\b" \
    .claude/ 2>/dev/null | wc -l | tr -d ' ')

  echo "${ref_count:-0}"
}
```

---

## Step 3: Pre-Flight Safety Check (SC-7)

```bash
# Check if file has uncommitted modifications
check_file_modified() {
  local file="$1"

  # Check if file is tracked and modified
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    if ! git diff --quiet "$file" 2>/dev/null; then
      echo "true"
      return
    fi
    # Check if file is staged
    if git diff --cached --quiet "$file" 2>/dev/null; then
      :
    else
      echo "true"
      return
    fi
  fi

  echo "false"
}
```

---

## Step 4: Detection Phase (Dry-Run)

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
      RISK=$(calculate_risk_level "$file")

      # Pre-flight safety check (SC-7)
      IS_MODIFIED=$(check_file_modified "$file")
      if [ "$IS_MODIFIED" = "true" ]; then
        RISK="High (blocked)"
        echo "| $file | No inbound imports (modified) | Tier 2 | $RISK | npm test | SKIP: Uncommitted changes |"
      else
        echo "| $file | No inbound imports | Tier 2 | $RISK | npm test | git checkout HEAD -- $file |"
      fi
    fi
  done
fi
```

**Exclusions**: `index.ts`, `main.ts`, `cli.ts`, `*.config.ts`, `*.test.ts`, `*.spec.ts`, `*.mock.ts`, `*.d.ts`, `dist/**`, `build/**`

### Tier 3: Dead Documentation Files (SC-4)

```bash
if [ "$MODE" = "docs" ] || [ "$MODE" = "all" ]; then
  DOC_FILES=$(rg --files --glob '*.md' --glob '!*.md.bak' \
    --glob '!docs/**' \
    --glob '!README.md' \
    --glob '!CLAUDE.md' \
    --glob '!**/.trash/**' \
    --glob '!.claude/agents/**' \
    --glob '!.claude/commands/**' \
    --glob '!.claude/guides/**' \
    --glob '!.claude/hooks/**' \
    --glob '!.claude/skills/**' \
    --glob '!.claude/templates/**' \
    --glob '!.claude/tests/**' \
    --glob '!.claude/**/CONTEXT.md' \
    --glob '!**/CONTEXT.md' \
    --glob '!.pilot/plan/**' \
    --hidden \
    "$DETECTION_PATH" 2>/dev/null)

  for file in $DOC_FILES; do
    REF_COUNT=$(check_doc_references "$file")
    if [ "$REF_COUNT" -eq 0 ]; then
      RISK=$(calculate_doc_risk_level "$file")

      # Pre-flight safety check (SC-7)
      IS_MODIFIED=$(check_file_modified "$file")
      if [ "$IS_MODIFIED" = "true" ]; then
        RISK="High (blocked)"
        echo "| $file | No @references (modified) | Tier 3 | $RISK | npm test | SKIP: Uncommitted changes |"
      else
        echo "| $file | No @references | Tier 3 | $RISK | npm test | git checkout HEAD -- $file |"
      fi
    fi
  done
fi
```

**Exclusions**: `docs/**`, `README.md`, `CLAUDE.md`, `*.md.bak`, `.trash/**`, `.claude/agents/**`, `.claude/commands/**`, `.claude/guides/**`, `.claude/hooks/**`, `.claude/skills/**`, `.claude/templates/**`, `.claude/tests/**`, `.claude/**/CONTEXT.md`, `**/CONTEXT.md`, `.pilot/plan/**`

---

## Step 5: Candidates Table

**Output Format**:
```markdown
| Item | Reason | Detection | Risk | Verification | Rollback |
|------|--------|-----------|------|-------------|----------|
| src/utils/deprecated.ts | No inbound imports | Tier 2 | Medium | npm test | git checkout HEAD -- src/utils/deprecated.ts |
```

**Sorting**: Primary by Risk (Low first), Secondary by File Size

---

## Step 6: Dry-Run Mode (SC-3)

```bash
if [ "$DRY_RUN" = "true" ]; then
  echo "🔍 DRY-RUN MODE - No files will be deleted"
  if [ "$NON_INTERACTIVE" = "true" ] && [ "${CHANGES_FOUND:-false}" = "true" ]; then
    echo ""
    echo "Changes detected. Run with --apply to apply changes."
    exit 2
  fi
  exit 0
fi
```

---

## Step 7: Risk-Based Application (SC-1, SC-2, SC-4)

### Initialize Candidate Lists

```bash
LOW_RISK=()
MEDIUM_RISK=()
HIGH_RISK=()
BLOCKED_FILES=()

# Parse candidates table and categorize by risk
while IFS='|' read -r item reason detection risk verification rollback; do
  item=$(echo "$item" | xargs)
  if [[ "$risk" =~ High.*blocked ]]; then
    BLOCKED_FILES+=("$item")
  elif [[ "$risk" =~ Low ]]; then
    LOW_RISK+=("$item")
  elif [[ "$risk" =~ Medium ]]; then
    MEDIUM_RISK+=("$item")
  else
    HIGH_RISK+=("$item")
  fi
done <<< "$(parse_candidates_table)"

TOTAL_LOW=${#LOW_RISK[@]}
TOTAL_MEDIUM=${#MEDIUM_RISK[@]}
TOTAL_HIGH=${#HIGH_RISK[@]}
TOTAL_BLOCKED=${#BLOCKED_FILES[@]}

echo "📊 Risk Summary:"
echo "  Low risk:    $TOTAL_LOW files (auto-apply)"
echo "  Medium risk: $TOTAL_MEDIUM files (auto-apply)"
echo "  High risk:   $TOTAL_HIGH files (confirmation required)"
echo "  Blocked:     $TOTAL_BLOCKED files (uncommitted changes)"
```

### Auto-Apply Low/Medium Risk (SC-1, SC-4)

```bash
if [ "$APPLY" = "true" ] || [ "$TOTAL_HIGH" -eq 0 ]; then
  # Apply Low/Medium risk immediately (SC-1)
  apply_files "${LOW_RISK[@]}"
  apply_files "${MEDIUM_RISK[@]}"

  # Apply High-risk if --apply flag (SC-4)
  if [ "$APPLY" = "true" ]; then
    apply_files "${HIGH_RISK[@]}"
  fi
else
  # Interactive confirmation for High-risk (SC-2)
  if [ "$TOTAL_HIGH" -gt 0 ]; then
    echo ""
    echo "⚠️  High-risk files detected:"
    echo ""

    # Show top 5 High-risk files
    count=0
    for file in "${HIGH_RISK[@]}"; do
      if [ $count -lt 5 ]; then
        echo "  - $file"
        ((count++))
      fi
    done

    if [ "$TOTAL_HIGH" -gt 5 ]; then
      echo "  ... and $((TOTAL_HIGH - 5)) more"
    fi

    echo ""
    AskUserQuestion "How would you like to proceed?" \
      "Apply all high-risk" \
      "Skip high-risk" \
      "Review one-by-one"

    CHOICE=$?

    case $CHOICE in
      0) # Apply all high-risk
        apply_files "${HIGH_RISK[@]}"
        ;;
      1) # Skip high-risk (default safe choice)
        echo "⏭️  Skipping $TOTAL_HIGH high-risk files"
        echo "Skipped files:"
        printf '  - %s\n' "${HIGH_RISK[@]}"
        ;;
      2) # Review one-by-one
        for file in "${HIGH_RISK[@]}"; do
          echo ""
          echo "Review: $file"
          AskUserQuestion "Delete this file?" "Yes" "No"
          if [ $? -eq 0 ]; then
            apply_file "$file"
          else
            echo "  Skipped: $file"
          fi
        done
        ;;
    esac
  fi
fi

# Apply Low/Medium risk first
apply_files "${LOW_RISK[@]}"
apply_files "${MEDIUM_RISK[@]}"
```

---

## Step 8: Apply Function with Verification (SC-8, SC-9)

```bash
# Run manifest for rollback (SC-9)
RUN_MANIFEST="/tmp/cleanup_manifest_$$"
RUN_BATCH=()
RUN_DELETED_TRACKED=()
RUN_TRASHED_UNTRACKED=()
TRASH_DIR="$(pwd)/.trash"

apply_file() {
  local file="$1"

  # Check if tracked by git
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    git rm "$file"
    RUN_DELETED_TRACKED+=("$file")
  else
    mkdir -p "$TRASH_DIR"
    mv "$file" "$TRASH_DIR/"
    RUN_TRASHED_UNTRACKED+=("$file")
  fi

  RUN_BATCH+=("$file")
}

verify_and_rollback() {
  local verification_cmd="$1"

  echo "🧪 Running verification: $verification_cmd"
  if ! eval "$verification_cmd"; then
    echo "❌ Verification failed - rolling back ${#RUN_BATCH[@]} files"

    # Rollback tracked files (SC-9)
    for file in "${RUN_DELETED_TRACKED[@]}"; do
      git restore --source=HEAD --staged --worktree -- "$file" 2>/dev/null
    done

    # Rollback untracked files from trash (SC-9)
    for file in "${RUN_TRASHED_UNTRACKED[@]}"; do
      mv "$TRASH_DIR/$(basename "$file")" "$(dirname "$file")/" 2>/dev/null
    done

    echo "🔄 Rollback complete"
    exit 1
  fi

  # Clear batch after successful verification
  RUN_BATCH=()
  RUN_DELETED_TRACKED=()
  RUN_TRASHED_UNTRACKED=()
}

apply_files() {
  local files=("$@")
  local batch_size=10
  local count=0

  VERIFICATION_CMD=$(detect_verification_command)

  for file in "${files[@]}"; do
    apply_file "$file"
    ((count++))

    # Verification after each batch (SC-8)
    if ! ((count % batch_size)); then
      verify_and_rollback "$VERIFICATION_CMD"
    fi
  done
}

# Final verification at end (SC-8)
if [ ${#RUN_BATCH[@]} -gt 0 ]; then
  verify_and_rollback "$VERIFICATION_CMD"
fi
```

---

## Step 9: Verification Command Detection

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
1. Auto-apply Low/Medium risk only (High-risk requires confirmation)
2. Pre-flight safety: never delete modified/staged files
3. Verification commands after each batch (max 10 deletions)
4. Stop-on-failure with automatic rollback
5. Safe-file-ops integration (git rm, .trash/)
6. Documentation exclusions: `docs/**`, `README.md`, `CLAUDE.md`, `*.md.bak`, `.trash/**`, `.claude/agents/**`, `.claude/commands/**`, `.claude/guides/**`, `.claude/hooks/**`, `.claude/skills/**`, `.claude/templates/**`, `.claude/tests/**`, `.claude/**/CONTEXT.md`, `**/CONTEXT.md`, `.pilot/plan/**`

**Non-Interactive Mode** (CI/non-TTY):
- Default: behaves like `--dry-run` (no modifications)
- Exit code 2 if changes detected, else 0
- With `--apply`: applies everything including High-risk

**Examples**:
```bash
/05_cleanup mode=imports                    # Auto-apply Low/Medium
/05_cleanup mode=files                      # Auto-apply Low/Medium, confirm High
/05_cleanup mode=docs                       # Auto-apply Low/Medium docs, confirm High
/05_cleanup mode=all                        # All tiers (imports, files, docs)
/05_cleanup mode=imports --dry-run          # Preview only
/05_cleanup mode=files --apply              # Apply everything (no confirm)
/05_cleanup mode=docs path=.claude/guides   # Specific scope for docs
```

---

## Success Criteria

- [ ] Auto-apply Low/Medium risk without confirmation (SC-1)
- [ ] Per-batch confirmation for High-risk with 3 choices (SC-2)
- [ ] `--dry-run` flag shows candidates only (SC-3)
- [ ] `--apply` flag applies everything (SC-4)
- [ ] Flag conflict detection (--dry-run + --apply error) (SC-5)
- [ ] Risk level classification (Low/Medium/High) (SC-6)
- [ ] Pre-flight safety check (block modified files) (SC-7)
- [ ] Verification after each batch and at end (SC-8)
- [ ] Rollback on verification failure (SC-9)
- [ ] Non-interactive detection (CI mode) (SC-10)

---

**Related**: @.claude/skills/safe-file-ops/SKILL.md | @.claude/skills/vibe-coding/SKILL.md
