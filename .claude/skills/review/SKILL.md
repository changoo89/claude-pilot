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

**In Scope**: 8 mandatory reviews, extended reviews, gap detection, autonomous perspectives, findings application

**Out of Scope**: Plan creation → @.claude/skills/spec-driven-workflow/SKILL.md | Test execution → @.claude/skills/tdd/SKILL.md | GPT delegation → @.claude/rules/delegator/orchestration.md

---

## Execution Steps

### ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps IMMEDIATELY and AUTOMATICALLY without waiting for user input.

**Core Philosophy**: Comprehensive (multi-angle review) | Actionable (findings map to plan sections) | Severity-based (BLOCKING → Interactive Recovery)

---

## Step 1: Load Plan

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
PROJECT_ROOT="$(pwd)"
PLAN_PATH="${1:-$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | head -1)}"
[ -f "$PLAN_PATH" ] || { echo "❌ No plan found"; exit 1; }
echo "📋 Loaded plan: $PLAN_PATH"
```

---

## Step 2: Multi-Angle Parallel Review

Launch 3 parallel agents for comprehensive review:

### Task 2.1: Test Coverage Review

```markdown
Task: subagent_type: tester, prompt: "Review plan: $PLAN_PATH. Evaluate test coverage: SCs verifiable? verify: commands exist? coverage ≥80%? scenarios comprehensive? Output: TEST_PASS/FAIL with findings"
```

### Task 2.2: Type Safety & Lint Review

```markdown
Task: subagent_type: validator, prompt: "Review plan: $PLAN_PATH. Evaluate type safety: types specified? lint check included? type issues? code quality (SRP, DRY, KISS)? Output: VALIDATE_PASS/FAIL with findings"
```

### Task 2.3: Code Quality Review

```markdown
Task: subagent_type: code-reviewer, prompt: "Review plan: $PLAN_PATH. Evaluate code quality: architecture? size limits (≤50/≤200)? early return? nesting ≤3? bugs/edge cases? Output: REVIEW_PASS/FAIL with findings"
```

**Speedup**: 60-70% faster

---

## Step 3: Process Findings

**BLOCKING**: Interactive Recovery | **Critical/Warning/Suggestion**: Auto-apply

| Level | Symbol | Action |
|-------|--------|--------|
| **BLOCKING** | 🛑 | Interactive Recovery |
| **Critical** | 🚨 | Must fix |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

```bash
if echo "$findings" | grep -q "🛑.*BLOCKING"; then
    echo "🛑 BLOCKING - Interactive Recovery"
    return 1
fi
# Auto-apply Critical/Warning/Suggestion
```

---

## Step 4: Update Plan

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks | Add item |
| Missing dependency | Scope | Add requirement |

---

## Review Workflow Summary

### Step 0: Load plan → Extract SC count

```bash
sc_count=$(grep -c "^- \[.\] \*\*SC-" "$PLAN_PATH" || echo "0")
```

### Step 1: Proactive investigation

Search for "needs investigation/confirmation/review" keywords

### Step 2: Type detection

| Type | Keywords |
|------|----------|
| **code** | function, component, API, bug fix, src/, lib/ |
| **config** | .claude/, settings, rules, template, workflow |
| **documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md |
| **scenario** | test, validation, edge cases |
| **infra** | Vercel, env, deploy, CI/CD |
| **db** | migration, table, schema |
| **ai** | LLM, prompts, AI |

### Step 3: 8 mandatory reviews

1. **Development Principles**: SOLID, DRY, KISS, YAGNI
2. **Project Structure**: File locations, naming, boundaries
3. **Requirement Completeness**: Explicit + implicit requirements
4. **Logic Errors**: Order of operations, dependencies, edge cases
5. **Existing Code Reuse**: Search existing utilities, patterns
6. **Better Alternatives**: Simpler/scalable/testable approaches
7. **Project Alignment**: Type-check, API docs consistency
8. **Long-term Impact**: Future consequences, technical debt

### Step 5: Extended reviews (type-activated)

| Review | Type | Checks |
|--------|------|--------|
| **A: API Compatibility** | Code | Breaking changes, version compatibility |
| **B: Type Safety** | Code | TypeScript types, interfaces |
| **C: Documentation Consistency** | Documentation | Terminology, formatting |
| **D: Test Coverage** | Code, Scenario | Unit tests, integration tests |
| **E: Migration Strategy** | DB Schema | Migration path, rollback plan |
| **F: Deployment** | Infrastructure | Deployment steps, env vars |
| **G: Prompt Engineering** | AI/Prompts | Prompt clarity, context |
| **H: Coverage Scenarios** | Scenario | Happy path, error paths |

### Step 6: Autonomous perspectives (6 angles)

- **Security**: Input validation, auth/authz, secrets
- **Performance**: Expectations, bottlenecks, optimization
- **UX**: User experience, error messages
- **Maintainability**: Code organization, documentation
- **Concurrency**: Race conditions, locking
- **Error Recovery**: Error handling, graceful degradation

### Step 7: Gap detection (BLOCKING triggers Interactive Recovery)

- **9.1 External API**: SDK vs HTTP, endpoint verification, error handling
- **9.2 Database Operations**: Migration files, rollback strategy
- **9.3 Async Operations**: Timeout config, race conditions
- **9.4 File Operations**: Path resolution, existence checks
- **9.5 Environment Variables**: Documentation, existence verification
- **9.6 Error Handling**: No silent catches, user notification
- **9.7 Test Plan Verification** (BLOCKING): Scenarios, test files, commands, coverage

### Step 9.5: Parallel multi-angle review (5+ SCs)

```bash
if [ "$sc_count" -ge 5 ]; then
  echo "🚀 Parallel multi-angle review (Security/Quality/Architecture)"
fi
```

### Step 10: GPT expert review (optional)

```bash
if [ "$sc_count" -ge 5 ] || echo "$PLAN_PATH" | grep -qiE "architecture|security|auth"; then
  echo "🤖 GPT expert review"
fi
```

---

## Further Reading

**Internal**: @.claude/skills/review/REFERENCE.md - Detailed review criteria, gap detection, GPT delegation | @.claude/rules/delegator/orchestration.md - GPT expert delegation | @.claude/skills/parallel-subagents/SKILL.md - Multi-angle parallel review | @.claude/agents/code-reviewer.md - Code reviewer output format

**External**: [Code Review by Jason Cohen](https://blog.smartbear.com/code-review/best-practices-for-code-review/) | [The Art of Readable Code](https://www.amazon.com/Art-Readable-Code-Simple/dp/1593272740)
