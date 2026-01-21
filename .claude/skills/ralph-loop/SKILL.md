---
name: ralph-loop
description: Use after first code change. Autonomous iteration until all quality gates pass (max 7 iterations).
---

# SKILL: Ralph Loop

> **Purpose**: Autonomous completion loop - iterate until all tests pass, coverage met, type-check clean
> **Target**: Coder, Tester, Validator agents

---

## Quick Start

### When to Use This Skill
- After first code change (Entry point)
- Tests failing or coverage low
- Type-check errors present
- Lint violations found

### Quick Reference
```bash
# Ralph Loop: Autonomous iteration
iteration=0
max_iterations=7

while [ $iteration -lt $max_iterations ]; do
  echo "Iteration $((iteration + 1))/$max_iterations"

  # Run verification
  if run_all_checks; then
    echo "✓ All quality gates passed"
    break
  fi

  # Fix failures
  fix_failures

  # Update state
  update_state "$SC" "in_progress" $((iteration + 1))
  ((iteration++))
done

# Complete or escalate
if [ $iteration -eq $max_iterations ]; then
  echo "<CODER_BLOCKED>"  # Escalate to GPT Architect
else
  echo "<CODER_COMPLETE>"  # All checks pass
fi
```

---

## Core Concepts

### Entry Point

**Trigger**: Immediately after first code change

**Detection**:
- Coder agent makes first edit/write
- Tests run and fail
- Ralph Loop begins automatically

### Quality Gates

**All must pass** before completion:
1. **Tests**: `npm test` - All tests pass
2. **Coverage**: ≥80% overall, ≥90% core modules
3. **Type-check**: `npm run type-check` or `tsc --noEmit`
4. **Lint**: `npm run lint` - Zero violations

### Iteration Pattern

```
┌─────────────────────────────────────────────────────┐
│  Make Code Change                                   │
└─────────────────┬───────────────────────────────────┘
                  ▼
         ┌────────────────┐
         │ Run All Checks │
         └───────┬────────┘
                 │
         ┌───────┴────────┐
         │                │
    All Pass         Any Fail
         │                │
         ▼                ▼
  ┌──────────┐   ┌──────────────────┐
  │ Complete │   │ Fix Failures     │
  │ Exit     │   │ iteration++      │
  └──────────┘   └────────┬─────────┘
                          │
                  ┌───────▼────────┐
                  │ iteration < 7? │
                  └───────┬────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
            Yes                      No
              │                       │
              ▼                       ▼
      ┌──────────────┐       ┌──────────────┐
      │ Re-run Checks│       │ <BLOCKED>    │
      └──────────────┘       │ Escalate to  │
                             │ GPT Architect│
                             └──────────────┘
```

---

## Implementation

### Verification Function
```bash
run_all_checks() {
  local project_root="$1"

  # Run tests
  if ! npm test > /tmp/test.log 2>&1; then
    echo "❌ Tests failed"
    cat /tmp/test.log
    return 1
  fi

  # Check coverage
  local coverage=$(npm test -- --coverage 2>&1 | grep -oP 'Lines\s+:\s+\K[\d.]+')
  if (( $(echo "$coverage < 80" | bc -l) )); then
    echo "⚠️  Coverage ${coverage}% < 80%"
    return 1
  fi

  # Type-check
  if ! npm run type-check > /tmp/typecheck.log 2>&1; then
    echo "❌ Type-check failed"
    cat /tmp/typecheck.log
    return 1
  fi

  # Lint
  if ! npm run lint > /tmp/lint.log 2>&1; then
    echo "⚠️  Lint violations found"
    cat /tmp/lint.log
    return 1
  fi

  echo "✓ All quality gates passed"
  return 0
}
```

### Fix Function
```bash
fix_failures() {
  local project_root="$1"

  # Fix test failures
  if ! npm test; then
    echo "Fixing test failures..."
    # Coder applies fixes
  fi

  # Fix type errors
  if ! npm run type-check; then
    echo "Fixing type errors..."
    # Coder applies fixes
  fi

  # Fix lint violations
  if ! npm run lint; then
    echo "Fixing lint violations..."
    # Coder applies fixes
  fi
}
```

---

## Escalation

### When Blocked

**Condition**: 7 iterations reached, still failing

**Action**: Delegate to GPT Architect
```bash
echo "<CODER_BLOCKED>"
echo "Iterations: $iteration"
echo "Last error: $(last_error)"
```

**Orchestrator handles escalation**:
- Reads `.claude/rules/delegator/prompts/architect.md`
- Builds delegation prompt with full history
- Calls `codex-sync.sh` with workspace-write mode
- Applies GPT recommendations
- Re-invokes Coder with fresh perspective

---

## State Management

### Update Loop State
```bash
update_ralph_state() {
  local sc="$1"
  local iteration="$2"

  jq --arg sc "$sc" --argjson iter "$iteration" \
    '.todos |= map(if .id == $sc then .iteration = $iter else . end) | .iteration_count += 1' \
    .pilot/state/continuation.json > .pilot/state/continuation.json.tmp
  mv .pilot/state/continuation.json.tmp .pilot/state/continuation.json
}
```

### Check Loop State
```bash
should_continue_loop() {
  local incomplete=$(jq '[.todos[] | select(.status != "completed")] | length' .pilot/state/continuation.json)
  local iterations=$(jq '.iteration_count' .pilot/state/continuation.json)
  [ "$incomplete" -gt 0 ] && [ "$iterations" -lt 7 ]
}
```

---

## Verification

### Test Ralph Loop
```bash
# Simulate Ralph Loop
iteration=0
max_iterations=7

while [ $iteration -lt $max_iterations ]; do
  echo "Iteration $((iteration + 1))"

  # Run checks (will fail initially)
  if run_all_checks; then
    echo "✓ All gates passed"
    break
  fi

  # Fix and retry
  fix_failures
  ((iteration++))
done

# Verify exit condition
if [ $iteration -lt $max_iterations ]; then
  echo "<CODER_COMPLETE>"
else
  echo "<CODER_BLOCKED>"
fi
```

---

## Related Skills

- **test-driven-development**: Red-Green-Refactor cycle
- **gpt-delegation`: Escalation when blocked

---

**Version**: claude-pilot 4.2.0
