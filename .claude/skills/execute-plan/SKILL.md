---
name: execute-plan
description: Plan execution workflow - continuation system, parallel SC implementation, worktree mode, verification patterns, GPT delegation. Use for executing plans with TDD + Ralph Loop.
---

# SKILL: Execute Plan (Plan Execution Workflow)

> **Purpose**: Execute plans using TDD + Ralph Loop with continuation system and parallel execution
> **Target**: Coder Agent implementing Success Criteria from plans

---

## Quick Start

### When to Use This Skill
- Execute plans from `/01_confirm`
- Implement Success Criteria with TDD
- Parallel execution of independent SCs
- Worktree mode for isolated development

### Quick Reference
```bash
# Plan detection (MANDATORY FIRST ACTION)
ls -la .pilot/plan/pending/*.md .pilot/plan/in_progress/*.md 2>/dev/null

# Continuation state check
STATE_FILE=".pilot/state/continuation.json"
[ -f "$STATE_FILE" ] && echo "🔄 Resuming from state"

# Parallel Coder invocation (Group 1 - Independent SCs)
Task: subagent_type: coder, prompt: "Execute SC-1: {DESCRIPTION}..."

# Verification (parallel)
Task: subagent_type: tester, prompt: "Run tests for {PLAN_PATH}"
Task: subagent_type: validator, prompt: "Type check + lint"
Task: subagent_type: code-reviewer, prompt: "Review code"
```

---

## What This Skill Covers

### In Scope
- Continuation state system (Sisyphus)
- Plan detection and state transition
- SC dependency analysis and parallel execution
- Worktree mode setup and management
- Parallel verification (tester + validator + code-reviewer)
- GPT delegation triggers and auto-escalation

### Out of Scope
- TDD methodology → @.claude/skills/tdd/SKILL.md
- Ralph Loop iteration → @.claude/skills/ralph-loop/SKILL.md
- Code quality standards → @.claude/skills/vibe-coding/SKILL.md

---

## Core Concepts

### Continuation State System (Sisyphus)

**State file**: `.pilot/state/continuation.json`

**Principle**: "The boulder never stops" - agents continue until all todos complete or max iterations (7) reached

**Agent behavior**:
1. Complete current task
2. Check continuation state BEFORE stopping
3. If incomplete todos exist → Continue to next todo
4. Else if all todos complete → Return completion marker

### Parallel Execution Patterns

**SC Dependency Analysis** (Step 2.1):
1. Extract all Success Criteria from plan
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts)
4. Check for dependency keywords ("requires", "depends on")
5. Group SCs by parallel execution capability

**Rules**:
- **Sequential**: One `in_progress` at a time
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously
- **File conflicts**: If 2+ SCs modify same file → Different groups

### Worktree Mode

**Purpose**: Create isolated worktree for parallel plan execution

**Workflow**: Parse `--wt` flag → Create worktree branch (`wt/{timestamp}`) → Store metadata → Restore context across Bash calls

### GPT Delegation

**Auto-delegation**: When Coder returns `<CODER_BLOCKED>` → Automatically delegate to GPT Architect

**Escalation triggers**:
- 2+ failed fix attempts → Architect
- Architecture decisions → Architect
- Security concerns → Security Analyst

---

## Further Reading

**Internal**: @.claude/skills/execute-plan/REFERENCE.md - Full implementation details, state management, worktree setup, verification patterns | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop | @.claude/skills/parallel-subagents/SKILL.md - Parallel execution orchestration

**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) | [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
