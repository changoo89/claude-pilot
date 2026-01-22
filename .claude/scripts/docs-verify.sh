#!/usr/bin/env bash
# Documentation verification script
# Validates: skill count, cross-references, line counts, version sync, Tier 1 limits
# Requirements: Bash 3.2+ (no associative arrays used for macOS compatibility)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Parse arguments
STRICT_MODE=false
for arg in "$@"; do
    case "$arg" in
        --strict) STRICT_MODE=true ;;
    esac
done

# Tier 1 configuration
TIER1_LIMIT=200

# Track errors
ERRORS=0
WARNINGS=0

echo "🔍 Documentation Verification"
if [ "$STRICT_MODE" = true ]; then
    echo "   Mode: STRICT (line violations = errors)"
fi
echo "================================"

# 1. Skill count validation
echo ""
echo "📊 Skill count validation..."

ACTUAL_SKILL_COUNT=$(find "$PROJECT_ROOT/.claude/skills" -name "SKILL.md" | wc -l | tr -d ' ')
README_FILE="$PROJECT_ROOT/README.md"

if [ -f "$README_FILE" ]; then
    # Extract skill count from README.md (format: "- **25 Skills**: ...")
    STATED_SKILL_COUNT=$(grep -oE '\*\*[0-9]+ Skills\*\*' "$README_FILE" | grep -oE '[0-9]+' || echo "0")

    if [ "$ACTUAL_SKILL_COUNT" -eq "$STATED_SKILL_COUNT" ]; then
        echo -e "${GREEN}✓ Skill count matches: $ACTUAL_SKILL_COUNT${NC}"
    else
        echo -e "${YELLOW}⚠ Skill count mismatch: README claims $STATED_SKILL_COUNT, found $ACTUAL_SKILL_COUNT (warning only)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠ README.md not found, skipping skill count check${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 2. Cross-reference validation
echo ""
echo "🔗 Cross-reference validation..."

# Find all @.claude/ and @docs/ references in documentation files
# Exclude: .trash, .git, node_modules, template placeholders, .pilot/plan/done
# Performance: Process files in batches and use faster grep
CROSS_REF_WARNINGS=0

# Build list of doc files once
DOC_FILES=$(find "$PROJECT_ROOT" \( -name "*.md" -o -name "CONTEXT.md" \) \
    ! -path "*/.trash/*" \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/.pilot/plan/done/*" 2>/dev/null)

# Quick validation: only check if references exist as files
for doc_file in $DOC_FILES; do
    [ ! -f "$doc_file" ] && continue

    # Extract all references at once and validate
    refs=$(grep -oE '@\.(claude|docs)/[^)[:space:]]+' "$doc_file" 2>/dev/null || true)

    for ref in $refs; do
        # Quick skip of templates
        [[ "$ref" =~ \{|\}|\.\.\. ]] && continue

        # Clean markdown artifacts
        cleaned_ref="${ref%[\`\*\]\"]}"
        cleaned_ref="${cleaned_ref%[\*]}"

        # Check existence (quick)
        ref_path="${cleaned_ref#@}"
        [ -e "$PROJECT_ROOT/$ref_path" ] && continue

        # Not found - count warning
        CROSS_REF_WARNINGS=$((CROSS_REF_WARNINGS + 1))
    done
done

if [ "$CROSS_REF_WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ All cross-references valid${NC}"
else
    echo -e "${YELLOW}⚠ Found $CROSS_REF_WARNINGS broken cross-reference(s) (warnings only)${NC}"
    WARNINGS=$((WARNINGS + CROSS_REF_WARNINGS))
fi

# 3. Line count validation
echo ""
echo "📏 Line count validation..."

LINE_COUNT_ERRORS=0
# Check CONTEXT.md files for stated line counts
while IFS= read -r context_file; do
    if [ ! -f "$context_file" ]; then
        continue
    fi

    # Look for patterns like "**Line Count**: 191 lines (Target: ≤200 lines)"
    while IFS= read -r line; do
        # Extract stated count and target
        stated=$(echo "$line" | grep -oE '[0-9]+' | head -1 || echo "0")

        # Get directory containing CONTEXT.md
        dir=$(dirname "$context_file")

        # Count actual lines in all files in that directory (excluding hidden files)
        actual=$(find "$dir" -type f ! -name ".*" -exec wc -l {} \; | awk '{sum+=$1} END {print sum}' || echo "0")

        # Allow 5% tolerance
        tolerance=$(echo "$stated * 0.05" | bc -l | awk '{print int($1+0.5)}')
        diff=$((actual - stated))
        diff_abs=${diff#-}

        if [ "$diff_abs" -gt "$tolerance" ]; then
            echo -e "${YELLOW}⚠ Line count drift in $context_file: stated $stated, actual $actual${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    done < <(grep -E 'Line Count.*[0-9]+ lines' "$context_file" 2>/dev/null || true)
done < <(find "$PROJECT_ROOT" -name "CONTEXT.md")

if [ "$LINE_COUNT_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ Line count validation complete${NC}"
fi

# 4. Tier 1 file count validation
echo ""
echo "📁 Tier 1 file count validation..."

AI_CONTEXT_DIR="$PROJECT_ROOT/docs/ai-context"
if [ -d "$AI_CONTEXT_DIR" ]; then
    AI_CONTEXT_COUNT=$(find "$AI_CONTEXT_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
    if [ "$AI_CONTEXT_COUNT" -eq 2 ]; then
        echo -e "${GREEN}✓ docs/ai-context/ contains exactly 2 files${NC}"
    else
        echo -e "${RED}✗ docs/ai-context/ should contain exactly 2 files (project-structure.md, docs-overview.md), found $AI_CONTEXT_COUNT${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ docs/ai-context/ directory not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 5. Tier 1 line limit validation
echo ""
echo "📏 Tier 1 line limit validation (≤$TIER1_LIMIT lines)..."

TIER1_LINE_ERRORS=0
TIER1_FILES=(
    "$PROJECT_ROOT/CLAUDE.md"
    "$PROJECT_ROOT/docs/ai-context/project-structure.md"
    "$PROJECT_ROOT/docs/ai-context/docs-overview.md"
)

for tier1_file in "${TIER1_FILES[@]}"; do
    if [ -f "$tier1_file" ]; then
        LINE_COUNT=$(wc -l < "$tier1_file" | tr -d ' ')
        FILENAME="${tier1_file#$PROJECT_ROOT/}"

        if [ "$LINE_COUNT" -le "$TIER1_LIMIT" ]; then
            echo -e "${GREEN}✓ $FILENAME: $LINE_COUNT lines${NC}"
        else
            OVER=$((LINE_COUNT - TIER1_LIMIT))
            if [ "$STRICT_MODE" = true ]; then
                echo -e "${RED}✗ $FILENAME: $LINE_COUNT lines (exceeds limit by $OVER lines - REFACTOR REQUIRED)${NC}"
                echo "  → Extract content to Tier 2 CONTEXT.md files"
                TIER1_LINE_ERRORS=$((TIER1_LINE_ERRORS + 1))
            else
                echo -e "${YELLOW}⚠ $FILENAME: $LINE_COUNT lines (exceeds limit by $OVER lines)${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    else
        echo -e "${YELLOW}⚠ $tier1_file not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done

if [ "$TIER1_LINE_ERRORS" -gt 0 ]; then
    ERRORS=$((ERRORS + TIER1_LINE_ERRORS))
    echo ""
    echo -e "${RED}⚠️  REFACTORING REQUIRED:${NC}"
    echo "  Tier 1 documents must be ≤$TIER1_LIMIT lines."
    echo "  Extract detailed content to Tier 2 CONTEXT.md files."
fi

# 6. Circular reference detection (self-references in REFERENCE.md are allowed as examples)
echo ""
echo "🔄 Circular reference detection..."

CIRCULAR_FOUND=0

# Check for direct self-references (A → A), skip REFERENCE.md files (they contain examples)
while IFS= read -r doc_file; do
    [ ! -f "$doc_file" ] && continue

    # Skip REFERENCE.md files (allowed to have self-refs for examples)
    [[ "$doc_file" == *"REFERENCE.md" ]] && continue

    key="${doc_file#$PROJECT_ROOT/}"

    # Extract @.claude/ and @docs/ references from this file
    refs=$(grep -oE '@\.(claude|docs)/[^)[:space:]]+' "$doc_file" 2>/dev/null || true)

    for ref in $refs; do
        [[ "$ref" =~ \{|\}|\.\.\. ]] && continue
        cleaned_ref="${ref%[\`\*\]\"]}"
        cleaned_ref="${cleaned_ref%[\*]}"
        ref_path="${cleaned_ref#@}"

        # Self-reference check
        if [ "$ref_path" = "$key" ]; then
            echo -e "${RED}✗ Self-reference detected: $key${NC}"
            CIRCULAR_FOUND=$((CIRCULAR_FOUND + 1))
        fi
    done
done < <(find "$PROJECT_ROOT" \( -name "*.md" -o -name "CONTEXT.md" \) ! -path "*/.trash/*" ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/.pilot/plan/done/*" 2>/dev/null)

if [ "$CIRCULAR_FOUND" -eq 0 ]; then
    echo -e "${GREEN}✓ No circular references detected${NC}"
else
    ERRORS=$((ERRORS + CIRCULAR_FOUND))
fi

# 6. Orphan document detection (simplified - just warn about CONTEXT.md not linked from Tier 1)
echo ""
echo "🔍 Orphan document detection..."

# Build list of referenced CONTEXT.md files from Tier 1
TIER1_REFS=""
for tier1_file in "$PROJECT_ROOT/CLAUDE.md" "$PROJECT_ROOT/docs/ai-context/project-structure.md" "$PROJECT_ROOT/docs/ai-context/docs-overview.md"; do
    [ -f "$tier1_file" ] && TIER1_REFS="$TIER1_REFS $(grep -oE '@\.(claude|docs)/[^)[:space:]]+' "$tier1_file" 2>/dev/null | sed 's/@//' || true)"
done

ORPHAN_COUNT=0
while IFS= read -r context_file; do
    [ ! -f "$context_file" ] && continue
    key="${context_file#$PROJECT_ROOT/}"

    # Check if this file is referenced from Tier 1
    if ! echo "$TIER1_REFS" | grep -qF "$key"; then
        echo -e "${YELLOW}⚠ Orphan document (not linked from Tier 1): $key${NC}"
        ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    fi
done < <(find "$PROJECT_ROOT" -name "CONTEXT.md" ! -path "*/.trash/*" ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null)

if [ "$ORPHAN_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No orphan documents detected${NC}"
else
    echo -e "${YELLOW}⚠ Found $ORPHAN_COUNT orphan document(s)${NC}"
    WARNINGS=$((WARNINGS + ORPHAN_COUNT))
fi

# 7. Temporary file validation
echo ""
echo "🗑️ Temporary file validation..."

# Check for temp files outside .tmp/ (exclude the .tmp directory itself)
TEMP_OUTSIDE_COUNT=0
while IFS= read -r temp_file; do
    # Skip the .tmp directory itself
    [ "$temp_file" = "$PROJECT_ROOT/.tmp" ] && continue
    echo -e "${YELLOW}⚠ Temp file outside .tmp/: $temp_file${NC}"
    TEMP_OUTSIDE_COUNT=$((TEMP_OUTSIDE_COUNT + 1))
done < <(find "$PROJECT_ROOT" \( -name "*.tmp" -o -name "*.temp" -o -name "tmp.*" -o -name "temp.*" \) \
    ! -path "*/.tmp/*" ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/.trash/*" 2>/dev/null)

if [ "$TEMP_OUTSIDE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No temp files outside .tmp/${NC}"
else
    echo -e "${YELLOW}⚠ Found $TEMP_OUTSIDE_COUNT temp file(s) outside .tmp/${NC}"
    WARNINGS=$((WARNINGS + TEMP_OUTSIDE_COUNT))
fi

# 8. Version sync validation
echo ""
echo "🔢 Version sync validation..."

VERSION_ERRORS=0

# Get version from CLAUDE.md
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    CLAUDE_VERSION=$(grep -oE 'Version.*: [0-9]+\.[0-9]+\.[0-9]+' "$CLAUDE_MD" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")

    # Check against package.json if it exists
    PACKAGE_JSON="$PROJECT_ROOT/package.json"
    if [ -f "$PACKAGE_JSON" ]; then
        PACKAGE_VERSION=$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' "$PACKAGE_JSON" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")

        if [ -n "$CLAUDE_VERSION" ] && [ -n "$PACKAGE_VERSION" ]; then
            if [ "$CLAUDE_VERSION" = "$PACKAGE_VERSION" ]; then
                echo -e "${GREEN}✓ Version sync: CLAUDE.md ($CLAUDE_VERSION) matches package.json${NC}"
            else
                echo -e "${RED}✗ Version mismatch: CLAUDE.md ($CLAUDE_VERSION) vs package.json ($PACKAGE_VERSION)${NC}"
                VERSION_ERRORS=$((VERSION_ERRORS + 1))
            fi
        fi
    else
        # No package.json, just report CLAUDE.md version
        if [ -n "$CLAUDE_VERSION" ]; then
            echo -e "${GREEN}✓ Version sync: CLAUDE.md version is $CLAUDE_VERSION (no package.json to check)${NC}"
        else
            echo -e "${YELLOW}⚠ Could not extract version from CLAUDE.md${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
else
    echo -e "${YELLOW}⚠ CLAUDE.md not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

ERRORS=$((ERRORS + VERSION_ERRORS))

# Summary
echo ""
echo "================================"
echo "📋 Summary"
echo "================================"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ "$ERRORS" -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Documentation verification FAILED${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ Documentation verification PASSED${NC}"
    exit 0
fi
