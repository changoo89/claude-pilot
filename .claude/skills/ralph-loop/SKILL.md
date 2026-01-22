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

| Iteration | Action | Success | Failure |
|-----------|--------|---------|---------|
| 1-6 | Run checks → Fix → Retry | Exit with `<CODER_COMPLETE>` | Continue to next iteration |
| 7 (max) | Run checks → Fix | Exit with `<CODER_COMPLETE>` | Exit with `<CODER_BLOCKED>`, escalate to GPT Architect |

**Flow**:
1. Make code change
2. Run all checks (tests, coverage, type-check, lint)
3. If all pass → `<CODER_COMPLETE>`
4. If any fail → Fix failures, increment iteration
5. If iteration < 7 → Repeat from step 2
6. If iteration = 7 → `<CODER_BLOCKED>`, delegate to GPT Architect

---

## Implementation

### Verification Function
```bash
run_all_checks() {
  # Tests
  npm test || return 1

  # Coverage (≥80%)
  coverage=$(npm test -- --coverage 2>&1 | grep -oP 'Lines\s+:\s+\K[\d.]+')
  (( $(echo "$coverage < 80" | bc -l) )) && return 1

  # Type-check
  npm run type-check || return 1

  # Lint
  npm run lint || return 1

  return 0
}
```

### Fix Function
```bash
fix_failures() {
  # Priority: tests → type-check → lint → coverage
  npm test || { echo "Fixing test failures..."; }
  npm run type-check || { echo "Fixing type errors..."; }
  npm run lint || { echo "Fixing lint violations..."; }
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
  jq --arg sc "$1" --argjson iter "$2" \
    '.todos |= map(if .id == $sc then .iteration = $iter else . end)' \
    .pilot/state/continuation.json > .pilot/state/continuation.json.tmp
  mv .pilot/state/continuation.json.tmp .pilot/state/continuation.json
}
```

### Check Loop State
```bash
should_continue_loop() {
  incomplete=$(jq '[.todos[] | select(.status != "completed")] | length' .pilot/state/continuation.json)
  iterations=$(jq '.iteration_count' .pilot/state/continuation.json)
  [ "$incomplete" -gt 0 ] && [ "$iterations" -lt 7 ]
}
```

---

## Related Skills

- **test-driven-development**: Red-Green-Refactor cycle
- **gpt-delegation**: Escalation when blocked

---

## Further Reading

**Internal**: @.claude/skills/ralph-loop/REFERENCE.md - Advanced patterns, state machine details | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/gpt-delegation/SKILL.md - GPT escalation patterns

**External**: [The Pragmatic Programmer](https://www.amazon.com/Pragmatic-Programmer-journey-mastery-Anniversary/dp/0135957052) | [Working Effectively with Legacy Code](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Version**: claude-pilot 4.4.11
