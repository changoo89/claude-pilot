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
