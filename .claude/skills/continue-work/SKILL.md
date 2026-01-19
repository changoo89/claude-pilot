# SKILL: Continue Work (Continuation System)

> **Purpose**: Resume work from continuation state (Sisyphus system) - agents persist across sessions until completion
> **Target**: All agents (coder, tester, validator, documenter) when resuming incomplete work

---

## Quick Start

### When to Use This Skill
- Resume interrupted `/02_execute` sessions
- Continue work after system crash or timeout
- Resume work next day with preserved state
- Continue after manual intervention during execution

### Quick Reference
```bash
# Check continuation state exists
STATE_FILE=".pilot/state/continuation.json"
[ -f "$STATE_FILE" ] && echo "🔄 Resuming from state"

# Load and validate state
STATE=$(cat "$STATE_FILE")
ITERATION_COUNT=$(echo "$STATE" | jq -r '.iteration_count // 0')
NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status != "complete") | .id' | head -1)

# Continue work
/99_continue  # Automatically loads state and continues
```

---

## What This Skill Covers

### In Scope
- State file validation and recovery
- Branch mismatch detection and handling
- Todo extraction and prioritization
- State update after each iteration
- Continuation level configuration (aggressive/normal/polite)

### Out of Scope
- TDD methodology → @.claude/skills/tdd/SKILL.md
- Ralph Loop iteration → @.claude/skills/ralph-loop/SKILL.md
- Plan execution workflow → @.claude/skills/execute-plan/SKILL.md

---

## Core Concepts

### Sisyphus Continuation System

**Philosophy**: "The boulder never stops" - agents continue until all todos complete or max iterations (7) reached

**State file**: `.pilot/state/continuation.json`

**Agent behavior**:
1. Complete current task
2. **Check continuation state BEFORE stopping**
3. If incomplete todos exist → Continue to next todo
4. Else if all todos complete → Return completion marker

**Escape hatch**: User can type `/cancel`, `/stop`, or `/done` to stop immediately

### Continuation State Format

```json
{
  "version": "1.0",
  "session_id": "uuid-v4",
  "branch": "main",
  "plan_file": ".claude-pilot/.pilot/plan/in_progress/plan.md",
  "todos": [
    {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
    {"id": "SC-2", "status": "in_progress", "iteration": 0, "owner": "coder"}
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-18T10:30:00Z",
  "continuation_level": "normal"
}
```

### Continuation Levels

| Level | Behavior | Use For |
|-------|----------|---------|
| `aggressive` | Maximum continuation, minimal pauses | Automated workflows |
| `normal` (default) | Balanced continuation with visibility | Standard workflows |
| `polite` | Frequent checkpoints, user control | Manual review needed |

**Configuration**:
```bash
export CONTINUATION_LEVEL="normal"
export MAX_ITERATIONS=7
```

### State Recovery

**Automatic backup recovery**:
1. Corrupted JSON detected
2. Attempt restore from `.backup` file
3. If backup fails → Manual intervention required

**Branch mismatch handling**:
- State branch != Current branch
- Prompt user to switch branch or clear state
- Continue with warning if user confirms

---

## Further Reading

**Internal**: @.claude/skills/continue-work/REFERENCE.md - Full implementation details, state management, error recovery, testing procedures | @.claude/guides/continuation-system.md - Sisyphus system architecture | @.claude/guides/todo-granularity.md - Granular todo breakdown for reliable continuation | @.claude/skills/execute-plan/SKILL.md - Plan execution workflow

**External**: [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052) - Chapter on "The Golden Master" test pattern for continuation
