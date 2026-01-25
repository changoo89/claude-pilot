# Execute Plan - Detailed Reference

> **Purpose**: Extended details for plan execution workflow
> **Main Skill**: @.claude/skills/execute-plan/SKILL.md
> **Last Updated**: 2026-01-22

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
