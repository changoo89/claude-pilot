# Execute Plan - Detailed Reference

> **Purpose**: Extended details for plan execution workflow
> **Main Skill**: @.claude/skills/execute-plan/SKILL.md
> **Last Updated**: 2026-01-22

---

## Step 1: Plan Detection (Full Bash)

```bash
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"

[ -z "$PLAN_PATH" ] && { echo "❌ No plan found"; exit 1; }

# Move from pending/ to in_progress/
if echo "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

echo "✓ Plan: $PLAN_PATH"

# Extract SCs (supports both header ### SC-N: and checkbox - [ ] **SC-N** formats)
SC_LIST=$(grep -E "^### SC-[0-9]+:|^- \[ \] \*\*SC-[0-9]+\*\*" "$PLAN_PATH" | sed -E 's/.*SC-([0-9]+).*/SC-\1/')
SC_COUNT=$(echo "$SC_LIST" | grep -c "SC-" || echo "0")

if [ "$SC_COUNT" -eq 0 ]; then
    echo "❌ No Success Criteria found in plan"
    exit 1
fi

echo "✓ Found $SC_COUNT Success Criteria"
echo "$SC_LIST"
```

---

## Step 2.7: Pre-Execution Confidence (Full Bash)

```bash
# Confidence detection (arch/multi/uncertain patterns reduce score)
ARCH_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'architecture|tradeoff|design|scalability|pattern|choice' || echo "0")
APPROACH_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'could|might|option [AB]|either' || echo "0")
UNCERTAINTY_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'not sure|unclear|depends' || echo "0")

# Calculate: 1.0 - (arch*0.3) - (approach*0.2) - (uncertain*0.2), clamp to [0,1]
CONFIDENCE=$(echo "scale=2; 1.0 - ($ARCH_COUNT * 0.3) - ($APPROACH_COUNT * 0.2) - ($UNCERTAINTY_COUNT * 0.2)" | bc)
CONFIDENCE=$(echo "$CONFIDENCE" | awk '{if ($1 < 0) print 0; else if ($1 > 1) print 1; else print $1}')
echo "📊 Pre-Execution Confidence: $CONFIDENCE"

# Proactive GPT if < 0.5 (graceful fallback if codex unavailable)
if (( $(echo "$CONFIDENCE < 0.5" | bc -l) )); then
    echo "⚠️  Low confidence - consulting GPT Architect"
    if command -v codex &> /dev/null; then
        codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "TASK: Review SC $SC for architecture/approach/risks. Confidence: $CONFIDENCE"
        echo "✓ GPT consultation complete - apply recommendations"
    else
        echo "⚠️  Codex unavailable - Claude-only mode (graceful fallback)"
    fi
fi
```

---

## Step 3: Dependency Analysis (Full Bash)

```bash
for SC in $SC_LIST; do
    SC_NUM=$(echo "$SC" | sed 's/SC-//')
    SC_CONTENT=$(sed -n "/### SC-${SC_NUM}:/,/^###\|^- \[ \] \*\*SC-/p" "$PLAN_PATH" | tail -n +2 | head -n -1 2>/dev/null)
    if [ -z "$SC_CONTENT" ]; then
        SC_CONTENT=$(sed -n "/\*\*SC-${SC_NUM}\*\*/,/^\*- \[ \]/p" "$PLAN_PATH" | tail -n +2 | head -n -1 2>/dev/null)
    fi

    # Extract SC-specific files (look for file paths in backticks)
    SC_FILES=$(echo "$SC_CONTENT" | grep -oE '\`[^`]+\.(ts|tsx|js|jsx|py|md|sh)\`' | tr -d '`' || echo "")

    # Test Type Detection (explicit rules: path + keyword + script-based)
    if echo "$SC_CONTENT" | grep -qiE 'e2e|integration|playwright|cypress|\.e2e\.|/e2e/|/integration/'; then
        TEST_TYPE="e2e"
        echo "SC-${SC_NUM}: TestType=$TEST_TYPE (sequential execution required)"
    else
        TEST_TYPE="unit"
        echo "SC-${SC_NUM}: TestType=$TEST_TYPE (parallel allowed)"
    fi

    # Per-SC Agent Selection (Priority: plugin > frontend > backend > coder)
    if echo "$SC_FILES" | grep -qE "^\.claude/|^docs/"; then
        SC_AGENT="coder"
        echo "SC-${SC_NUM}: Agent=coder (plugin/docs), Files: $SC_FILES"
    elif echo "$SC_FILES" | grep -qE "^src/components/|^src/ui/" && \
         echo "$SC_CONTENT" | grep -qiE "component|UI|React|CSS|Tailwind"; then
        SC_AGENT="frontend-engineer"
        echo "SC-${SC_NUM}: Agent=frontend-engineer, Files: $SC_FILES"
    elif echo "$SC_FILES" | grep -qE "^src/api/|^src/server/|^server/" && \
         echo "$SC_CONTENT" | grep -qiE "API|endpoint|database|server|backend"; then
        SC_AGENT="backend-engineer"
        echo "SC-${SC_NUM}: Agent=backend-engineer, Files: $SC_FILES"
    else
        SC_AGENT="coder"
        echo "SC-${SC_NUM}: Agent=coder (default), Files: $SC_FILES"
    fi

    # Determine grouping (E2E tests always sequential for safety)
    if [ "$TEST_TYPE" = "e2e" ] || echo "$SC_CONTENT" | grep -qiE 'after|depends|requires|follows'; then
        echo "**SequentialGroup**: $SC (test-type=$TEST_TYPE)"
    else
        echo "**ParallelGroup**: $SC (test-type=$TEST_TYPE)"
    fi
done
```

---

## Worktree Mode Setup

Full guide: **@.claude/skills/using-git-worktrees/SKILL.md**

### Creation Process

| Step | Action |
|------|--------|
| **1. Parse flag** | Check `--wt` argument |
| **2. Create worktree** | `git worktree add -b wt/{timestamp} ../worktrees/{branch} main` |
| **3. Persist path** | Write to `.pilot/worktree_active.txt` (path, branch, main branch) |
| **4. Restore context** | Read `.pilot/worktree_active.txt` to restore paths across Bash calls |

---

## Parallel Execution Patterns

### SC Dependency Analysis

**Analysis Process**:
1. Extract all Success Criteria from plan file
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts)
4. Check for dependency keywords ("requires", "depends on", "after", "needs")
5. Group SCs by parallel execution capability

**File Conflict Rules**:

| Condition | Execution Mode | Group Assignment |
|-----------|---------------|------------------|
| 2+ SCs modify same file | Sequential | Different groups |
| SC-2 references SC-1 output | Sequential | SC-2 after SC-1 |
| Different files, no references | Parallel | Same group |

### Parallel Invocation

**Group 1**: Invoke multiple Coder agents concurrently for independent SCs
**Group 2+**: Sequential execution after previous group completes

### Process Results

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | SC met, tests pass, coverage ≥80% | Mark todo as complete |
| `<CODER_BLOCKED>` | Cannot complete | **AUTO-DELEGATE to GPT Architect** |

**After ALL agents return**:
1. Mark all parallel todos as `completed` together
2. Verify no file conflicts
3. Integrate results (files, tests, coverage)
4. Proceed to Group 2 or Verification

### Partial Failure Handling

| Step | Action |
|------|--------|
| 1 | Note failure with agent ID and SC |
| 2 | Continue waiting for other parallel agents |
| 3 | Present all results together |
| 4 | Re-invoke **only failed agent** with error context |
| 5 | Merge successful results once retry succeeds |

**Fallback**: If 2+ retries fail, use `AskUserQuestion`

### Single Coder Pattern

**When to use**:
- Plan has 1-2 SCs only
- No clear file separation between SCs
- Sequential dependencies between all SCs
- Resource constraints

---

## Verification Patterns

### Parallel Verification

Invoke three agents in parallel: **tester** (tests + coverage), **validator** (type check + lint), **code-reviewer** (quality review).

### Success Criteria

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## GPT Delegation

### Auto-Delegation to GPT Architect

**MANDATORY**: When Coder returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect

**Process**: Read prompt template → Build context → Call `codex-sync.sh` → Apply response → Re-invoke Coder

**Fallback**: If Architect fails → `AskUserQuestion` (max 2 auto-delegations)

### GPT Expert Escalation

| Trigger | Expert |
|---------|--------|
| 2+ failed fix attempts | Architect (fresh perspective) |
| Architecture decisions | Architect |
| Security concerns | Security Analyst |

**Pattern**: Read `.claude/rules/delegator/prompts/[expert].md` → Call `codex-sync.sh`

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Parallel Execution**: @.claude/skills/parallel-subagents/SKILL.md
- **Worktree Setup**: @.claude/skills/using-git-worktrees/SKILL.md
- **GPT Delegation**: @.claude/rules/delegator/orchestration.md

---

## E2E Verification: Web Projects

**Purpose**: Browser-based verification using Chrome in Claude MCP tools.

### Chrome Availability Check

```bash
check_chrome_available() {
    if command -v claude &> /dev/null && claude --chrome --help &> /dev/null 2>&1; then
        return 0
    else
        echo "⚠️  Chrome in Claude not available, skipping browser test"
        return 1
    fi
}
```

### Port Detection

```bash
detect_dev_server_port() {
    local package_json="$1"
    # Check for explicit port flags
    if grep -q -- "--port\|-p " "$package_json"; then
        grep -oP "(?<=--port|--port\s|-p\s)\d+" "$package_json" | head -1
    else
        # Framework defaults
        if grep -q "vite" "$package_json"; then echo "5173"
        elif grep -q "next" "$package_json"; then echo "3000"
        elif grep -q "react-scripts" "$package_json"; then echo "3000"
        elif grep -q "vue-cli-service" "$package_json"; then echo "8080"
        elif grep -q "@sveltejs/kit" "$package_json"; then echo "5173"
        elif grep -q "astro" "$package_json"; then echo "4321"
        else echo "3000"  # Common default
        fi
    fi
}
```

### MCP Tool Invocation

```bash
# Prerequisites: Claude in Chrome extension installed, /mcp claude-in-chrome

# Navigate to dev server
browser_navigate("http://localhost:${PORT}")

# Take snapshot for verification
browser_snapshot("/tmp/e2e_snapshot.png")

# Check for expected elements (example: button text)
browser_click("button[data-testid='submit']")

# Verify no console errors
browser_console_read()  # Should be empty or only warnings
```

### Success Criteria

1. No console errors (except allowed warnings)
2. Expected elements present (check SC "Verify" section)
3. User interactions work (clicks, forms)
4. Visual regression (optional: compare screenshots)

### Graceful Fallback

```bash
if ! check_chrome_available; then
    echo "⚠️  Browser test skipped - Chrome in Claude unavailable"
    echo "✓ Manual verification required: Visit http://localhost:${PORT}"
    return 0  # Continue with verification
fi
```

---

## E2E Verification: CLI Projects

**Purpose**: Verify CLI tools produce expected output.

### Verification Pattern

```bash
verify_cli_output() {
    local sc_verify_pattern="$1"  # From SC "Verify" section
    local command="$2"
    local expected_exit_code="${3:-0}"

    # Run command
    output=$($command 2>&1)
    exit_code=$?

    # Check exit code
    if [ $exit_code -ne $expected_exit_code ]; then
        echo "❌ CLI exit code: $exit_code (expected: $expected_exit_code)"
        return 1
    fi

    # Check output pattern
    if ! echo "$output" | grep -q "$sc_verify_pattern"; then
        echo "❌ Output missing pattern: $sc_verify_pattern"
        echo "Actual output: $output"
        return 1
    fi

    echo "✓ CLI verification passed"
    return 0
}
```

### Example Usage

```bash
# SC Verify section: "Output should contain 'Build complete'"
verify_cli_output "Build complete" "npm run build" 0
```

---

## E2E Verification: Library Projects

**Purpose**: Verify libraries work via integration tests.

### Verification Pattern

```bash
verify_library_tests() {
    # Run project's test suite
    if [ -f "package.json" ]; then
        npm test
    elif [ -f "pyproject.toml" ]; then
        pytest
    elif [ -f "Cargo.toml" ]; then
        cargo test
    elif [ -f "go.mod" ]; then
        go test ./...
    else
        echo "❌ Unknown project type for library verification"
        return 1
    fi

    # Check exit code
    if [ $? -eq 0 ]; then
        echo "✓ Library tests passed"
        return 0
    else
        echo "❌ Library tests failed"
        return 1
    fi
}
```

---

## E2E Verification: Retry Loop

**Purpose**: Handle verification failures with fix-and-retry pattern.

### Constants

```bash
MAX_E2E_RETRIES=3
E2E_RETRY_COUNT=0
```

### Retry Trigger

Verification fails when:
- Exit code != 0
- Expected output missing
- Console errors present (web)
- Tests fail (library)

### Retry Flow

```bash
while [ $E2E_RETRY_COUNT -lt $MAX_E2E_RETRIES ]; do
    # Run verification
    if run_e2e_verification; then
        echo "✓ E2E verification passed"
        break
    fi

    # Increment counter
    E2E_RETRY_COUNT=$((E2E_RETRY_COUNT + 1))

    if [ $E2E_RETRY_COUNT -lt $MAX_E2E_RETRIES ]; then
        # Analyze failure and fix
        analyze_failure

        # Delegate to Coder for fix
        Task: subagent_type: coder, prompt: "Fix E2E failure (attempt $E2E_RETRY_COUNT/$MAX_E2E_RETRIES): $FAILURE_OUTPUT"

        # Re-verify after fix
        continue
    fi
done

# Max retries reached
if [ $E2E_RETRY_COUNT -eq $MAX_E2E_RETRIES ]; then
    # Delegate to GPT Architect
    delegate_to_gpt_architect
fi
```

### GPT Architect Delegation Prompt

```
You are a Software Architect helping resolve E2E verification failures.

CONTEXT:
- Task: {SC_DESCRIPTION}
- Project Type: {PROJECT_TYPE}
- Verification Method: {web|cli|library}
- Attempts: {E2E_RETRY_COUNT}/3

FAILURE LOG:
{FAILURE_OUTPUT}

MUST DO:
1. Analyze why verification is failing
2. Identify root cause (code, config, or environment)
3. Provide specific fix with file path and code changes
4. Report modified files

OUTPUT FORMAT:
- Root Cause: [explanation]
- Fix: [specific code change]
- Files: [list of files to modify]
```

### Fallback: Ask User

```bash
# After GPT delegation fails
AskUserQuestion(
    "E2E verification failed after $MAX_E2E_RETRIES attempts and GPT Architect review. Manual intervention required.",
    options: ["Skip verification", "Continue debugging", "Open issue"]
)
```

---

## Project Type Detection

**Purpose**: Auto-detect project type for appropriate E2E verification.

### Detection Function

```bash
detect_project_type() {
    local project_root="$1"

    # Check for web framework indicators
    if [ -f "$project_root/package.json" ]; then
        local package_json="$project_root/package.json"
        if grep -qE "next|react|vue|svelte|astro|vite|webpack" "$package_json"; then
            echo "web"
            return 0
        fi
    fi

    # Check for CLI indicators
    if [ -f "$project_root/Cargo.toml" ] || \
       [ -f "$project_root/go.mod" ] || \
       [ -f "$project_root/pyproject.toml" ] && \
       grep -q "^\[project.scripts\]" "$project_root/pyproject.toml" 2>/dev/null; then
        echo "cli"
        return 0
    fi

    # Default: library
    echo "library"
    return 0
}
```

### Framework Detection Table

| Indicator | Type | Framework |
|-----------|------|-----------|
| package.json + next | Web | Next.js |
| package.json + react | Web | React |
| package.json + vue | Web | Vue |
| package.json + svelte | Web | Svelte |
| package.json + astro | Web | Astro |
| package.json + vite | Web | Vite |
| Cargo.toml | CLI | Rust |
| go.mod | CLI | Go |
| pyproject.toml + scripts | CLI | Python |
| Any with test/ | Library | Generic |

### Precedence Rules

1. **Web** has highest precedence (frameworks detected first)
2. **CLI** checked second (build tools + scripts)
3. **Library** is fallback (default for tests-only projects)

---

## Pre-Execution Confidence Evaluation

**Purpose**: Evaluate confidence before executing complex Success Criteria to determine if GPT consultation is needed.

**Reference**: Confidence Score Rubric defined in @.claude/skills/gpt-delegation/SKILL.md

### Confidence Formula

```
confidence = 1.0 - (architecture_keywords * 0.3) - (multiple_approaches * 0.2) - (uncertainty_markers * 0.2)
```

**Scale**: 0.0 - 1.0

**Thresholds**:
- 0.9-1.0: Proceed autonomously
- 0.5-0.9: Consider consultation
- < 0.5: **MUST consult GPT Architect** before execution

### Detection Patterns

| Pattern Type | Keywords/Markers | Weight |
|--------------|-----------------|--------|
| Architecture | architecture, tradeoff, design, scalability, pattern, choice | 0.3 |
| Multiple Approaches | could, might, option A/B, either, alternative | 0.2 |
| Uncertainty | not sure, unclear, depends, ambiguous, unsure | 0.2 |

### Evaluation Example

**Scenario**: SC requires implementing caching layer

```bash
# Step 1: Extract SC description
sc_description="Implement distributed caching with Redis or Memcached"

# Step 2: Count patterns
architecture_count=1  # "caching", "distributed"
approaches_count=1    # "Redis or Memcached" (multiple options)
uncertainty_count=0   # no uncertainty markers

# Step 3: Calculate confidence
confidence=$(echo "1.0 - (1 * 0.3) - (1 * 0.2) - (0 * 0.2)" | bc)
# Result: 0.5

# Step 4: Evaluate threshold
if (( $(echo "$confidence < 0.5" | bc -l) )); then
    echo "⚠️  Confidence $confidence < 0.5 - MUST consult GPT Architect"
    # Delegate to GPT Architect for recommendation
else
    echo "✓ Confidence $confidence - Proceed with execution"
fi
```

### Integration Pattern

```bash
# Before executing SC
evaluate_pre_execution_confidence() {
    local sc_description="$1"

    # Check for architecture keywords
    local arch_keywords=$(echo "$sc_description" | grep -ocE "architecture|tradeoff|design|scalability|pattern|choice")

    # Check for multiple approaches
    local approaches=$(echo "$sc_description" | grep -ocE "could|might|option|either|alternative|or [A-Z]")

    # Check for uncertainty
    local uncertainty=$(echo "$sc_description" | grep -ocE "not sure|unclear|depends|ambiguous|unsure")

    # Calculate confidence
    local confidence=$(echo "1.0 - ($arch_keywords * 0.3) - ($approaches * 0.2) - ($uncertainty * 0.2)" | bc)

    # Return confidence
    echo "$confidence"
}

# Usage
confidence=$(evaluate_pre_execution_confidence "$sc_description")
if (( $(echo "$confidence < 0.5" | bc -l) )); then
    # Consult GPT Architect before execution
    delegate_to_gpt_architect "Low confidence ($confidence) for: $sc_description"
fi
```

---

## Per-SC TODO Verification

**Purpose**: Verify TODO completion immediately after each SC execution (BLOCKING).

### Verification Function

```bash
verify_sc_todos() {
    local plan_file="$1"
    local sc_number="$2"

    # Extract SC section (supports both formats)
    local sc_content=$(sed -n "/^### SC-${sc_number}:/,/^### /p" "$plan_file" | tail -n +2 | head -n -1 2>/dev/null)
    if [ -z "$sc_content" ]; then
        sc_content=$(sed -n "/\*\*SC-${sc_number}\*\*/,/^\- \[ \]/p" "$plan_file" | tail -n +2 | head -n -1 2>/dev/null)
    fi

    # Count unchecked TODOs in this SC
    local unchecked=$(echo "$sc_content" | grep -c "^- \[ \]" || echo "0")

    if [ "$unchecked" -gt 0 ]; then
        echo "❌ BLOCKING: SC-${sc_number} has $unchecked unchecked TODOs"
        echo "$sc_content" | grep "^- \[ \]"
        return 1
    fi

    echo "✓ All TODOs complete for SC-${sc_number}"
    return 0
}
```

### Integration Pattern

```bash
# After Coder returns <CODER_COMPLETE>
if ! verify_sc_todos "$PLAN_PATH" "$SC_NUM"; then
    echo "⚠️ Re-invoking coder to complete remaining TODOs"
    # Re-invoke coder with context
fi
```

---

## Final TODO Sweep

**Purpose**: Comprehensive sweep of all TODOs across entire plan before E2E verification (BLOCKING).

**Trigger**: After all SCs execute (Step 3.9), before E2E verification (Step 4)

**Scope**: Entire plan file (all SC sections)

### Sweep Function

```bash
final_todo_sweep() {
    local plan_file="$1"
    local retry_count=0
    local max_retries=50

    while [ $retry_count -lt $max_retries ]; do
        # Count ALL unchecked TODOs in plan (skip code blocks)
        unchecked=$(awk '/^```/ { in_code=!in_code; next } !in_code && /^- \[ \]/ { count++ } END { print count+0 }' "$plan_file")

        if [ "$unchecked" -eq 0 ]; then
            echo "✓ Final TODO sweep complete - all items checked"
            return 0
        fi

        retry_count=$((retry_count + 1))

        # Progressive escalation
        if [ $retry_count -eq 10 ]; then
            echo "⚠️  Escalating to GPT Architect (retry $retry_count/50)"
            delegate_to_gpt_architect "$plan_file" "ALL_SCS"
        elif [ $retry_count -eq 50 ]; then
            echo "❌ BLOCKING: Max retries reached - user intervention required"
            echo "Unchecked TODOs: $unchecked"
            grep "^- \[ \]" "$plan_file"
            exit 1
        else
            echo "⚠️  $unchecked unchecked TODOs (retry $retry_count/50)"
            invoke_coder_agent "$plan_file" "final_sweep"
        fi
    done
}
```

**Integration**: Called automatically in Step 3.9 before E2E verification begins

---

## TODO Verification Algorithm

**Purpose**: Ensure complete TODO execution with BLOCKING enforcement and progressive escalation.

### Checkbox Parsing

| Pattern | Meaning | Regex | Usage |
|---------|---------|-------|-------|
| `- [ ]` | Unchecked | `^- \[ \]` | Incomplete TODO item |
| `- [x]` | Checked | `^- \[x\]` | Completed TODO item |

**Parsing Function**:

```bash
count_unchecked_todos() {
    local plan_file="$1"
    local sc_section="${2:-}"  # Optional: specific SC section

    if [ -n "$sc_section" ]; then
        # Count within specific SC section
        awk "/^### $sc_section:/,/^### /" "$plan_file" | grep -c "^- \[ \]" || echo "0"
    else
        # Count all unchecked TODOs in plan
        grep -c "^- \[ \]" "$plan_file" || echo "0"
    fi
}
```

### Escalation Table

| Retry Count | Action | Responsibility | Timeout |
|-------------|--------|----------------|---------|
| 1-9 | Coder retry with context | Coder agent | 2 min/retry |
| 10-49 | GPT Architect consultation | GPT Architect | 5 min |
| 50 | User escalation (BLOCKING) | Human user | Indefinite |

**Escalation Logic**:

```bash
retry_todo_completion() {
    local plan_file="$1"
    local sc_name="$2"
    local retry_count=0
    local max_retries=50

    while [ $retry_count -lt $max_retries ]; do
        unchecked=$(count_unchecked_todos "$plan_file" "$sc_name")

        if [ "$unchecked" -eq 0 ]; then
            echo "✓ All TODOs complete for $sc_name"
            return 0
        fi

        retry_count=$((retry_count + 1))

        # Progressive escalation
        if [ $retry_count -eq 10 ]; then
            echo "⚠️  Escalating to GPT Architect (retry $retry_count)"
            delegate_to_gpt_architect "$plan_file" "$sc_name"
        elif [ $retry_count -eq 50 ]; then
            echo "❌ BLOCKING: Max retries reached - user intervention required"
            ask_user_question "$plan_file" "$sc_name" "$unchecked"
            exit 1
        else
            echo "⚠️  $unchecked unchecked TODOs (retry $retry_count/$max_retries)"
            invoke_coder_agent "$plan_file" "$sc_name"
        fi
    done
}
```

### Edge Cases

**1. Code Blocks**: Skip lines inside fenced code blocks to avoid false positives

```bash
parse_todos_skip_code_blocks() {
    local plan_file="$1"
    awk '
        /^```/ { in_code_block = !in_code_block; next }
        !in_code_block && /^- \[ \]/ { print }
    ' "$plan_file"
}
```

**2. Nested Lists**: Only count top-level TODO items (avoid double-counting sub-items)

```bash
parse_top_level_todos() {
    local plan_file="$1"
    grep "^- \[ \]" "$plan_file"  # ^ ensures line start (top-level)
}
```

**3. Plan Format Variations**: Support both section header and list formats

```bash
# Format 1: Section headers
### SC-1: Feature Name
- [ ] TODO-1.1: Task description

# Format 2: List items
- [ ] **SC-1**: Feature Name
  - [ ] TODO-1.1: Task description

# Parser handles both
extract_sc_todos() {
    local plan_file="$1"
    local sc_number="$2"

    # Try section header format
    awk "/^### SC-$sc_number:/,/^### /" "$plan_file" | grep "^- \[ \]"

    # Fallback: list format
    if [ $? -ne 0 ]; then
        awk "/^- \[ \] \*\*SC-$sc_number\*\*/,/^- \[ \] \*\*SC-/" "$plan_file" | grep "  - \[ \]"
    fi
}
```

**4. Cosmetic TODOs**: Only parse TODOs within SC sections (ignore general notes)

```bash
# Valid: Under SC section
### SC-1: Auth Implementation
- [ ] TODO-1.1: Add login endpoint

# Invalid (ignored): Outside SC sections
## Notes
- [ ] Remember to update docs
```

### Verification Checkpoints

| Checkpoint | Location | Trigger | Scope |
|-----------|----------|---------|-------|
| **Per-SC** | Step 3.5 | After each SC execution | Current SC only |
| **Final Sweep** | Step 3.9 | Before E2E verification | Entire plan |
| **Pre-Close** | close-plan Step 1 | Before archival | Entire plan |
| **Quality Gate** | Ralph Loop | Before `<CODER_COMPLETE>` | Current SC |

### Integration Examples

**Per-SC Verification (Step 3.5)**:

```bash
# After Coder returns <CODER_COMPLETE>
echo "▶ Verifying SC-$SC_NUM TODO completion"
unchecked=$(count_unchecked_todos "$PLAN_FILE" "SC-$SC_NUM")

if [ "$unchecked" -gt 0 ]; then
    echo "❌ BLOCKING: $unchecked unchecked TODOs in SC-$SC_NUM"
    retry_todo_completion "$PLAN_FILE" "SC-$SC_NUM"
fi
```

**Final Sweep (Step 3.9)**:

```bash
# Before E2E verification
echo "▶ Final TODO sweep"
unchecked=$(count_unchecked_todos "$PLAN_FILE")

if [ "$unchecked" -gt 0 ]; then
    echo "❌ BLOCKING: $unchecked unchecked TODOs across all SCs"
    retry_todo_completion "$PLAN_FILE" "ALL"
fi
```

**Pre-Close Gate**:

```bash
# In close-plan/SKILL.md Step 1
echo "▶ TODO Completion Check"
unchecked=$(count_unchecked_todos "$PLAN_FILE")

if [ "$unchecked" -gt 0 ]; then
    echo "❌ BLOCKING: $unchecked unchecked TODOs in plan"

    if [ "$FORCE_FLAG" != "true" ]; then
        echo "Use --force to bypass (NOT recommended)"
        exit 1
    else
        echo "⚠️ WARNING: Proceeding despite unchecked TODOs (--force)"
    fi
fi
```

### Backward Compatibility

**Graceful Handling**: Plans without checkboxes (legacy format)

```bash
# Check if plan uses checkbox format
if ! grep -q "^- \[ \]" "$PLAN_FILE" && ! grep -q "^- \[x\]" "$PLAN_FILE"; then
    echo "ℹ️  Legacy plan format detected (no checkboxes) - skipping TODO verification"
    return 0
fi
```
