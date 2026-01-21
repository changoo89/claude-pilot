#!/bin/bash

# Dead Code Cleanup Script
# Part of claude-pilot plugin
# Safe dead code cleanup with conservative detection and two-step verification

# Source common environment library
# shellcheck source=../lib/env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/env.sh" ]]; then
    source "$SCRIPT_DIR/../lib/env.sh"
fi

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MODE="${MODE:-imports}"
SCOPE="${SCOPE:-repo}"
APPLY="${APPLY:-false}"
DETECTION_PATH="."
BATCH_SIZE=10
CURRENT_BATCH=0
ROLLBACK_FILES=()

# Parse arguments
for arg in "$@"; do
  case $arg in
    mode=*)
      MODE="${arg#mode=}"
      ;;
    scope=*)
      SCOPE="${arg#scope=}"
      ;;
    path=*)
      DETECTION_PATH="${arg#path=}"
      SCOPE="${arg#path=}"
      ;;
    --apply)
      APPLY=true
      ;;
    --help|-h)
      echo "Usage: $0 [mode=imports|files|all] [scope=repo|path=...] [--apply]"
      echo ""
      echo "Modes:"
      echo "  imports  - Detect unused import statements (Tier 1)"
      echo "  files    - Detect dead files with zero references (Tier 2)"
      echo "  all      - Both imports and files"
      echo ""
      echo "Scope:"
      echo "  repo     - Entire repository (default)"
      echo "  path=... - Specific path (e.g., path=src/components)"
      echo ""
      echo "Options:"
      echo "  --apply  - Actually perform deletions (default: dry-run)"
      echo ""
      echo "Examples:"
      echo "  $0 mode=imports                    # Detect unused imports"
      echo "  $0 mode=files --apply              # Delete dead files"
      echo "  $0 mode=all path=src/components    # Analyze specific directory"
      exit 0
      ;;
  esac
done

# Set detection path
if [ "$SCOPE" = "repo" ]; then
  DETECTION_PATH="."
else
  DETECTION_PATH="$SCOPE"
fi

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required commands exist
check_dependencies() {
  local missing=()

  command -v jq >/dev/null 2>&1 || missing+=("jq")
  command -v rg >/dev/null 2>&1 || missing+=("ripgrep (rg)")

  if [ ${#missing[@]} -gt 0 ]; then
    log_error "Missing dependencies: ${missing[*]}"
    echo ""
    echo "Install with:"
    echo "  brew install ${missing[*]}"
    exit 1
  fi
}

# Detect verification command based on project type
detect_verification_command() {
  # Check for custom verification command in CLAUDE.local.md
  if [ -f "CLAUDE.local.md" ] && grep -q "verification_command:" CLAUDE.local.md 2>/dev/null; then
    grep "verification_command:" CLAUDE.local.md | sed 's/.*verification_command:[[:space:]]*//' | head -1
    return
  fi

  # Check for monorepo (package.json with workspaces)
  if [ -f "package.json" ]; then
    if grep -q '"workspaces"' package.json 2>/dev/null; then
      echo "npm test --workspaces"
      return
    else
      echo "npm test"
      return
    fi
  fi

  # Check for Python project
  if [ -f "pyproject.toml" ]; then
    echo "pytest"
    return
  fi

  # Check for Go project
  if [ -f "go.mod" ]; then
    echo "go test ./..."
    return
  fi

  # Fallback to git status
  echo "git status --porcelain"
}

# Calculate risk score based on file path and name
calculate_risk_score() {
  local file="$1"
  local risk="Low"

  # Check file path components
  if [[ "$file" =~ (test|spec|mock|example|demo) ]]; then
    risk="Low"
  elif [[ "$file" =~ (util|helper|service|handler) ]]; then
    risk="Medium"
  elif [[ "$file" =~ (component|route|controller|middleware|plugin) ]]; then
    risk="High"
  fi

  echo "$risk"
}

# Check if file should be excluded from Tier 2 analysis
should_exclude_file() {
  local file="$1"

  # Exclusion patterns (converted to bash regex)
  # Exact filenames
  if [[ "$file" =~ ^(index|main|cli)\.(ts|js|tsx|jsx)$ ]]; then
    return 0  # Should exclude
  fi

  # Config files
  if [[ "$file" =~ \.config\.(ts|js)$ ]]; then
    return 0
  fi

  # Test files
  if [[ "$file" =~ \.(test|spec|mock)\.(ts|tsx|js)$ ]]; then
    return 0
  fi

  # Type definition files
  if [[ "$file" =~ \.d\.ts$ ]]; then
    return 0
  fi

  # Directory exclusions
  if [[ "$file" =~ ^(dist|build|node_modules|\.next|out)/ ]]; then
    return 0
  fi

  return 1  # Should not exclude
}

# Check file references using ripgrep
check_file_references() {
  local file="$1"
  local basename=$(basename "$file" | sed 's/\.[^.]*$//')

  # Escape special characters for ripgrep
  local escaped_file=$(echo "$file" | sed 's/[][\.*^$()+?{|\\]/\\&/g')
  local escaped_basename=$(echo "$basename" | sed 's/[][\.*^$()+?{|\\]/\\&/g')

  # Count references (excluding the file itself)
  local ref_count=$(rg -c "(from[[:space:]]+['\"]$escaped_file|import[[:space:]]+.*from[[:space:]]+['\"]$escaped_file|import[[:space:]]+['\"].*$escaped_basename)" \
    --glob "!$file" \
    --glob "!node_modules/**" \
    --glob "!.next/**" \
    --glob "!dist/**" \
    --glob "!build/**" \
    . 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')

  echo "${ref_count:-0}"
}

# Detect unused imports (Tier 1) - Using ESLint and TypeScript
detect_unused_imports() {
  log_info "Detecting unused imports (Tier 1) with ESLint/TypeScript..."

  # Check for ESLint
  if ! command -v eslint >/dev/null 2>&1; then
    log_warning "ESLint not found, skipping Tier 1. Install: npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin"
    return
  fi

  # Run ESLint for unused imports
  local eslint_output
  eslint_output=$(eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error' --format json 2>/dev/null) || true

  # Check for TypeScript compiler
  local tsc_available=false
  if command -v tsc >/dev/null 2>&1; then
    tsc_available=true
  fi

  # Parse ESLint output and format as table
  if echo "$eslint_output" | jq -e '.results' >/dev/null 2>&1; then
    echo "$eslint_output" | jq -r '.results[] | select(.messages | length > 0) |
      .messages[] | select(.ruleId == "@typescript-eslint/no-unused-vars") |
      "| \(.filePath) | \(.message | gsub("''"; "") | gsub("\\n"; " ")) | Tier 1 | Low | eslint . --fix | git checkout HEAD -- \(.filePath) |"' 2>/dev/null || true
  fi

  # Run TypeScript compiler for unused locals/parameters
  if [ "$tsc_available" = true ]; then
    local tsc_output
    tsc_output=$(tsc --noUnusedLocals --noUnusedParameters --noEmit 2>&1) || true

    if [ -n "$tsc_output" ]; then
      echo "$tsc_output" | grep "error TS6133" | while IFS= read -r line; do
        local file=$(echo "$line" | sed 's/^\(.*\)[0-9]*:[0-9]*.*$/\1/' | xargs)
        local msg=$(echo "$line" | sed 's/.*error TS6133: \(.*\)$/\1/')
        echo "| $file | $msg | Tier 1 | Low | Manual removal | git checkout HEAD -- $file |"
      done
    fi
  fi

  log_info "Tier 1 detection complete. See @.claude/skills/code-cleanup/SKILL.md for manual removal procedures."
}

# Detect dead files (Tier 2)
detect_dead_files() {
  log_info "Detecting dead files (Tier 2)..."

  # Find source files
  local source_files
  source_files=$(rg --files --type ts --type js --type tsx --type jsx \
    --glob '!*.test.ts' --glob '!*.test.tsx' --glob '!*.test.js' \
    --glob '!*.spec.ts' --glob '!*.spec.tsx' --glob '!*.spec.js' \
    --glob '!*.mock.ts' --glob '!*.mock.tsx' --glob '!*.mock.js' \
    --glob '!*.d.ts' \
    --glob '!*.config.ts' --glob '!*.config.js' \
    --glob '!dist/**' --glob '!build/**' \
    --glob '!node_modules/**' --glob '!.next/**' \
    "$DETECTION_PATH" 2>/dev/null)

  if [ -z "$source_files" ]; then
    log_warning "No source files found in $DETECTION_PATH"
    return
  fi

  # Check each file for references
  local total=0
  local dead=0

  while IFS= read -r file; do
    if [ -z "$file" ]; then
      continue
    fi

    ((total++))

    # Skip excluded files
    if should_exclude_file "$file"; then
      continue
    fi

    # Check references
    local ref_count
    ref_count=$(check_file_references "$file")

    if [ "$ref_count" -eq 0 ]; then
      local risk
      risk=$(calculate_risk_score "$file")
      echo "| $file | No inbound imports | Tier 2 | $risk | npm test | git checkout HEAD -- $file |"
      ((dead++))
    fi
  done <<< "$source_files"

  log_info "Analyzed $total files, found $dead dead files"
}

# Rollback current batch
rollback_current_batch() {
  log_error "Rolling back current batch..."

  for file in "${ROLLBACK_FILES[@]}"; do
    if [ -f ".trash/$file" ]; then
      mv ".trash/$file" "$file"
      log_info "Restored: $file"
    else
      git checkout HEAD -- "$file" 2>/dev/null || true
    fi
  done

  ROLLBACK_FILES=()
}

# Apply deletions
apply_deletions() {
  local verification_cmd
  verification_cmd=$(detect_verification_command)

  log_warning "⚠️  APPLY MODE - Files will be deleted!"
  log_info "Verification command: $verification_cmd"
  echo ""

  # Read candidates from stdin or run detection
  local candidates=()

  if [ "$MODE" = "imports" ] || [ "$MODE" = "all" ]; then
    while IFS= read -r line; do
      [[ "$line" =~ ^\| ]] && candidates+=("$line")
    done < <(detect_unused_imports)
  fi

  if [ "$MODE" = "files" ] || [ "$MODE" = "all" ]; then
    while IFS= read -r line; do
      [[ "$line" =~ ^\| ]] && candidates+=("$line")
    done < <(detect_dead_files)
  fi

  if [ ${#candidates[@]} -eq 0 ]; then
    log_success "No candidates found for deletion"
    return
  fi

  log_info "Found ${#candidates[@]} candidates for deletion"
  echo ""

  # Process each candidate
  for candidate in "${candidates[@]}"; do
    local file
    file=$(echo "$candidate" | cut -d'|' -f2 | xargs)

    if [ -z "$file" ]; then
      continue
    fi

    log_info "Processing: $file"

    # Check if file is git-tracked
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      # Git-tracked file - use git rm
      git rm "$file"
      log_success "Removed with git rm: $file"
    else
      # Non-tracked file - move to .trash
      mkdir -p .trash
      mv "$file" .trash/
      log_success "Moved to .trash/: $file"
    fi

    # Track for rollback
    ROLLBACK_FILES+=("$(basename "$file")")

    # Run verification after each batch
    ((CURRENT_BATCH++))
    if [ $((CURRENT_BATCH % BATCH_SIZE)) -eq 0 ]; then
      log_info "Running verification ($CURRENT_BATCH/${#candidates[@]} processed)..."
      if eval "$verification_cmd"; then
        log_success "Verification passed"
        ROLLBACK_FILES=()  # Clear rollback on success
      else
        log_error "Verification failed!"
        rollback_current_batch
        exit 1
      fi
    fi
  done

  # Final verification
  if [ $CURRENT_BATCH -gt 0 ]; then
    log_info "Running final verification..."
    if eval "$verification_cmd"; then
      log_success "All deletions completed successfully"
    else
      log_error "Final verification failed!"
      rollback_current_batch
      exit 1
    fi
  fi
}

# Main execution
main() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║         Dead Code Cleanup - Safe Detection Tool          ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  # Check dependencies
  check_dependencies

  # Show configuration
  log_info "Configuration:"
  echo "  Mode: $MODE"
  echo "  Scope: $SCOPE"
  echo "  Path: $DETECTION_PATH"
  echo "  Apply: $APPLY"
  echo ""

  # Check if apply mode
  if [ "$APPLY" != "true" ]; then
    log_warning "🚨 DRY-RUN MODE - No files will be deleted"
    echo ""

    # Print table header
    echo "| Item | Reason | Detection | Risk | Verification | Rollback |"
    echo "|------|--------|-----------|------|-------------|----------|"

    # Detect candidates
    if [ "$MODE" = "imports" ] || [ "$MODE" = "all" ]; then
      detect_unused_imports
    fi

    if [ "$MODE" = "files" ] || [ "$MODE" = "all" ]; then
      detect_dead_files
    fi

    echo ""
    log_info "→ Review candidates above, then run:"
    echo "   /05_cleanup mode=$MODE scope=$SCOPE --apply"
  else
    apply_deletions
  fi

  echo ""
}

# Run main function
main "$@"
