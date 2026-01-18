---
name: ralph-loop
description: Autonomous completion loop that iterates until all quality gates pass. Tests, type-check, lint, coverage - iterate until complete or max 7 iterations reached. Use after any code change.
---

# SKILL: Ralph Loop (Autonomous Completion)

> **Purpose**: Iterate autonomously until all quality gates pass (tests, type-check, lint, coverage)
> **Target**: Coder Agent after implementing features

---

## Quick Start

### When to Use This Skill
- Iterate until all tests pass
- Verify type checking and linting
- Achieve coverage thresholds (80%+ overall, 90%+ core)

### Quick Reference
```bash
MAX_ITERATIONS=7; ITERATION=1
while [ $ITERATION -le $MAX_ITERATIONS ]; do
    $TEST_CMD && npx tsc --noEmit && npm run lint
    if [ $? -eq 0 ] && [ $COVERAGE -ge 80 ]; then
        echo "<RALPH_COMPLETE>"; break
    fi
    ITERATION=$((ITERATION + 1))
done
```

## What This Skill Covers

### In Scope
- Autonomous iteration until quality gates pass
- Test command auto-detection (pytest, npm test, go test, cargo test)
- Verification: tests, type-check, lint, coverage

### Out of Scope
- Test writing methodology → @.claude/skills/tdd/SKILL.md
- Code quality standards → @.claude/skills/vibe-coding/SKILL.md

## Core Concepts

### Ralph Loop Entry Condition (CRITICAL)

**Ralph Loop starts IMMEDIATELY after the FIRST code change.**

**Correct Entry Points**: After implementing first feature/function, fixing bug, any Edit/Write tool call
**❌ WRONG**: After completing all todos, at very end

### Completion Promise

Output `<RALPH_COMPLETE>` marker **ONLY when** ALL conditions are met:
- [ ] All tests pass
- [ ] Coverage 80%+ (core modules 90%+)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed
- [ ] Continuation state verified (if exists)

### Continuation State Integration (Sisyphus System)

**CRITICAL**: Ralph Loop now integrates with the Sisyphus Continuation System for persistent iteration tracking.

#### State File Check

Before entering Ralph Loop, check for continuation state:

```bash
STATE_FILE=".pilot/state/continuation.json"

if [ -f "$STATE_FILE" ]; then
    # Load existing iteration count
    ITERATION=$(jq -r '.iteration_count // 0' "$STATE_FILE")
    MAX_ITERATIONS=$(jq -r '.max_iterations // 7' "$STATE_FILE")

    # Resume from last checkpoint
    echo "🔄 Resuming Ralph Loop from iteration $ITERATION"
else
    # Start fresh
    ITERATION=1
    MAX_ITERATIONS=7
fi
```

#### State Update After Each Iteration

After each iteration, update continuation state:

```bash
# Update state with current iteration
UPDATED_STATE=$(jq \
    --argjson iteration "$ITERATION" \
    '.iteration_count = $iteration | .last_checkpoint = now | todate' \
    "$STATE_FILE")

echo "$UPDATED_STATE" > "$STATE_FILE"
```

#### Continuation on Blocked Status

If Ralph Loop reaches max iterations without completion:

```bash
if [ $ITERATION -gt $MAX_ITERATIONS ]; then
    echo "<RALPH_BLOCKED>"

    # Update state with blocked status
    jq '.status = "blocked"' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    # Notify user of continuation options
    echo ""
    echo "⚠️ MAX ITERATIONS REACHED"
    echo "→ Use /99_continue to resume after manual review"
    echo "→ Or fix issues manually and reset iteration count"
fi
```

#### Continuation Check Before Completion

Before outputting `<RALPH_COMPLETE>`, verify no incomplete todos:

```bash
if [ -f "$STATE_FILE" ]; then
    INCOMPLETE=$(jq '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE")

    if [ "$INCOMPLETE" -gt 0 ]; then
        echo "⚠️ Incomplete todos: $INCOMPLETE remaining"
        echo "→ Continuing with next todo (Sisyphus mode)"
        # Don't output <RALPH_COMPLETE>, continue loop
    else
        echo "<RALPH_COMPLETE>"
        # Clean up state file
        rm -f "$STATE_FILE"
    fi
fi
```

### Loop Structure
```
MAX_ITERATIONS=7
WHILE ITERATION <= MAX_ITERATIONS:
    1. Run: tests, type-check, lint, coverage
    2. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    3. ELSE: Fix (priority: errors > coverage > lint); ITERATION++
    4. IF ITERATION > MAX_ITERATIONS: Output: <RALPH_BLOCKED>
```

## Further Reading

**Internal**: @.claude/skills/ralph-loop/REFERENCE.md - Deep dive on loop mechanics, fix strategies, patterns | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/vibe-coding/SKILL.md - Code quality standards | @.claude/guides/test-environment.md - Test framework detection

**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) | [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
