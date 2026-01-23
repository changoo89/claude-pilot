# SKILL: Multi-Angle Code Review

> **Purpose**: Comprehensive plan review with gap detection, extended reviews, and GPT expert delegation
> **Target**: plan-reviewer Agent reviewing plans before execution

---

## Quick Start

### When to Use This Skill
- Review plan before execution (/01_confirm, /review)
- Detect gaps in external service integration
- Validate test plan completeness
- Apply findings to improve plan quality

### Quick Reference
```bash
# Load plan → Detect type → Run reviews → Apply findings
/review .pilot/plan/pending/plan.md
```

## What This Skill Covers

### In Scope
- 8 mandatory reviews (principles, structure, requirements, logic, reuse, alternatives, alignment, impact)
- Type-specific extended reviews (API, types, tests, docs, coverage, deployment, migration, prompts)
- Gap detection (external API, DB, async, file ops, env vars, error handling, test plan)
- Autonomous perspectives (security, performance, UX, maintainability, concurrency, error recovery)
- Findings application to plan

### Out of Scope
- Plan creation → @.claude/skills/spec-driven-workflow/SKILL.md
- Test execution → @.claude/skills/tdd/SKILL.md
- GPT delegation → @.claude/rules/delegator/orchestration.md

---

## Execution Steps

### ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 in sequence
- Only stop for BLOCKING findings that require Interactive Recovery

---

### Core Philosophy

**Comprehensive**: Multi-angle review | **Actionable**: Findings map to plan sections | **Severity-based**: BLOCKING → Interactive Recovery

---

### Step 1: Load Plan

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code execution directory (absolute path required)
PROJECT_ROOT="$(pwd)"

PLAN_PATH="${1:-$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | head -1)}"
[ -f "$PLAN_PATH" ] || { echo "❌ No plan found"; exit 1; }

echo "📋 Loaded plan: $PLAN_PATH"
```

---

### Step 2: Multi-Angle Parallel Review

Launch 3 parallel agents for comprehensive review from different perspectives:

#### Task 2.1: Test Coverage Review

```markdown
Task:
  subagent_type: tester
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate test coverage and verification:
    - Are all SCs verifiable with test commands?
    - Do verify: commands exist and executable?
    - Is coverage threshold specified (≥80%)?
    - Are test scenarios comprehensive?
    Output: TEST_PASS or TEST_FAIL with findings
```

#### Task 2.2: Type Safety & Lint Review

```markdown
Task:
  subagent_type: validator
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate type safety and code quality:
    - Are types specified for APIs/functions?
    - Is lint check included in verification?
    - Any potential type-related issues?
    - Code quality standards (SRP, DRY, KISS)?
    Output: VALIDATE_PASS or VALIDATE_FAIL with findings
```

#### Task 2.3: Code Quality Review

```markdown
Task:
  subagent_type: code-reviewer
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate code quality and design:
    - Architecture and design patterns?
    - Function/file size limits (≤50/≤200 lines)?
    - Early return pattern applied?
    - Nesting level (≤3)?
    - Potential bugs or edge cases?
    Output: REVIEW_PASS or REVIEW_FAIL with findings
```

**Expected Speedup**: 60-70% faster review (test + type + quality in parallel)

---

### Step 3: Process Findings

**BLOCKING**: Interactive Recovery with AskUserQuestion
**Critical/Warning/Suggestion**: Auto-apply improvements

#### Severity Level Processing

| Level | Symbol | Action |
|-------|--------|--------|
| **BLOCKING** | 🛑 | Interactive Recovery |
| **Critical** | 🚨 | Must fix |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

```bash
# Process findings by severity
process_findings() {
  local findings="$1"

  # Check for BLOCKING issues
  if echo "$findings" | grep -q "🛑.*BLOCKING"; then
    echo "🛑 BLOCKING issues found - triggering Interactive Recovery"
    # Trigger Interactive Recovery via AskUserQuestion
    return 1
  fi

  # Auto-apply Critical/Warning/Suggestion improvements
  echo "$findings" | while IFS= read -r line; do
    if echo "$line" | grep -qE "🚨|⚠️|💡"; then
      echo "Applying: $line"
    fi
  done
}
```

---

### Step 4: Update Plan

```bash
if [ "$FINDINGS" != "APPROVE" ]; then
    # Edit plan with improvements
    echo "✓ Plan updated with review findings"
fi
```

#### Apply Findings to Plan

```bash
apply_findings_to_plan() {
  local plan_path="$1"
  local findings="$2"

  # Read current plan
  local plan_content
  plan_content=$(cat "$plan_path")

  # Apply modifications to appropriate sections
  # Issue Type Mapping:
  # - Missing step → Execution Plan (add checkbox)
  # - Unclear requirement → User Requirements (clarify wording)
  # - Test gap → Test Plan (add scenario)
  # - Risk identified → Risks (add item)
  # - Missing dependency → Scope (add requirement)

  # Write updated plan
  echo "$plan_content" > "$plan_path"

  # Append findings to Review History
  echo "" >> "$plan_path"
  echo "## Review History" >> "$plan_path"
  echo "" >> "$plan_path"
  echo "**$(date '+%Y-%m-%d %H:%M:%S')** - Multi-Angle Review" >> "$plan_path"
  echo "$findings" >> "$plan_path"
}
```

---

## Review Workflow

### Step 0: Load plan → Extract success criteria count

```bash
sc_count=$(grep -c "^- \[.\] \*\*SC-" "$PLAN_PATH" || echo "0")
echo "📊 Success Criteria Count: $sc_count"
```

### Step 1: Proactive investigation (search existing code/patterns)

```bash
# Search for "needs investigation/confirmation/review" keywords
investigation_keywords=("need to investigate" "confirm" "TODO" "check" "verify" "unclear" "TBD")

for keyword in "${investigation_keywords[@]}"; do
  if grep -qi "$keyword" "$PLAN_PATH"; then
    echo "🔍 Found investigation keyword: $keyword"
    # Investigate using Glob, Grep, Read
  fi
done
```

### Step 2: Type detection (code/config/docs/scenario/infra/db/ai)

```bash
detect_plan_type() {
  local plan_path="$1"
  local plan_content
  plan_content=$(cat "$plan_path")

  # Type Detection Matrix
  if echo "$plan_content" | grep -qiE "function|component|API|bug fix|src/|lib/"; then
    echo "code"
  elif echo "$plan_content" | grep -qiE "\.claude/|settings|rules|template|workflow"; then
    echo "config"
  elif echo "$plan_content" | grep -qiE "CLAUDE\.md|README|guide|docs/|CONTEXT\.md"; then
    echo "documentation"
  elif echo "$plan_content" | grep -qiE "test|validation|edge cases"; then
    echo "scenario"
  elif echo "$plan_content" | grep -qiE "Vercel|env|deploy|CI/CD"; then
    echo "infra"
  elif echo "$plan_content" | grep -qiE "migration|table|schema"; then
    echo "db"
  elif echo "$plan_content" | grep -qiE "LLM|prompts|AI"; then
    echo "ai"
  else
    echo "unknown"
  fi
}

PLAN_TYPE=$(detect_plan_type "$PLAN_PATH")
echo "📂 Plan Type: $PLAN_TYPE"
```

### Step 3: 8 mandatory reviews

```bash
run_mandatory_reviews() {
  echo "🔍 Running 8 Mandatory Reviews..."

  # 1. Development Principles: SOLID, DRY, KISS, YAGNI compliance
  # 2. Project Structure: File locations, naming, module boundaries
  # 3. Requirement Completeness: Explicit + implicit requirements coverage
  # 4. Logic Errors: Order of operations, dependencies, edge cases
  # 5. Existing Code Reuse: Search existing utilities, hooks, common patterns
  # 6. Better Alternatives: Simpler/scalable/testable approaches
  # 7. Project Alignment: Type-check compliance, API docs consistency
  # 8. Long-term Impact: Future consequences, technical debt, scalability

  # Assessment Levels: ✅ Pass / ⚠️ Warning / ❌ Fail
}
```

### Step 5: Extended reviews (type-activated)

```bash
run_extended_reviews() {
  local plan_type="$1"

  case "$plan_type" in
    code)
      echo "🔍 Extended Review A: API Compatibility"
      echo "🔍 Extended Review B: Type Safety"
      echo "🔍 Extended Review D: Test Coverage"
      ;;
    documentation)
      echo "🔍 Extended Review C: Documentation Consistency"
      ;;
    scenario)
      echo "🔍 Extended Review H: Coverage Scenarios"
      ;;
    infra)
      echo "🔍 Extended Review F: Deployment"
      ;;
    db)
      echo "🔍 Extended Review E: Migration Strategy"
      ;;
    ai)
      echo "🔍 Extended Review G: Prompt Engineering"
      ;;
  esac
}
```

### Step 6: Autonomous perspectives (6 angles)

```bash
run_autonomous_reviews() {
  echo "🔍 Running Autonomous Review Perspectives..."

  # - [ ] Security: Input validation, auth/authz, secret management, OWASP Top 10
  # - [ ] Performance: Expectations defined, bottlenecks identified, optimization strategy
  # - [ ] UX: User experience, error messages, edge case handling
  # - [ ] Maintainability: Code organization, documentation, future maintenance
  # - [ ] Concurrency: Race conditions, parallel operations, locking strategy
  # - [ ] Error Recovery: Error handling, recovery strategies, graceful degradation

  # Assessment: ✅ Pass / ⚠️ Improvements / ❌ Risks
}
```

### Step 7: Gap detection (BLOCKING triggers Interactive Recovery)

```bash
run_gap_detection() {
  echo "🔍 Running Gap Detection..."

  # Gap Categories:
  # - 9.1 External API: SDK vs HTTP, endpoint verification, error handling, rate limiting
  # - 9.2 Database Operations: Migration files, rollback strategy, connection management
  # - 9.3 Async Operations: Timeout config, concurrent limits, race conditions
  # - 9.4 File Operations: Path resolution, existence checks, cleanup strategy
  # - 9.5 Environment Variables: Documentation, existence verification, no secrets in plan
  # - 9.6 Error Handling: No silent catches, user notification, graceful degradation
  # - 9.7 Test Plan Verification (BLOCKING): Scenarios defined, test files specified (or N/A), test commands, coverage command, test environment

  # Severity Levels: 🛑 BLOCKING | 🚨 Critical | ⚠️ Warning | 💡 Suggestion
}
```

### Step 9.5: Parallel multi-angle review (5+ SCs)

```bash
if [ "$sc_count" -ge 5 ]; then
  echo "🚀 Triggering parallel multi-angle review (5+ SCs)"
  # Invoke 3 plan-reviewer agents concurrently with different angles:
  # - Security angle: External API security, input validation, auth/authz, secret management
  # - Quality angle: Vibe Coding, code quality, testing coverage, documentation
  # - Architecture angle: System design, component relationships, scalability, integration points
fi
```

### Step 10: GPT expert review (optional)

```bash
if [ "$sc_count" -ge 5 ] || echo "$PLAN_PATH" | grep -qiE "architecture|security|auth"; then
  echo "🤖 Triggering GPT expert review"
  # See @.claude/skills/gpt-delegation/SKILL.md for direct codex CLI format
fi
```

---

## Further Reading

**Internal**: @.claude/skills/review/REFERENCE.md - Detailed review criteria, gap detection, GPT delegation | @.claude/rules/delegator/orchestration.md - GPT expert delegation | @.claude/skills/parallel-subagents/SKILL.md - Multi-angle parallel review

**External**: [Code Review by Jason Cohen](https://blog.smartbear.com/code-review/best-practices-for-code-review/) | [The Art of Readable Code](https://www.amazon.com/Art-Readable-Code-Simple/dp/1593272740)
