---
name: parallel-subagents
description: Use when executing independent tasks concurrently. Launch multiple agents simultaneously for 50-70% speedup.
---

# SKILL: Parallel Subagents

> **Purpose**: Concurrent agent execution for independent tasks, 50-70% speedup
> **Target**: Orchestrators executing multiple independent SCs/tasks

---

## Quick Start

### When to Use This Skill
- Multiple independent SCs (no shared files, no dependencies)
- Independent code changes (different files/directories)
- Parallel verification (testing, type-check, linting)
- Multi-angle review (codereviewer, security-analyst in parallel)

### Quick Reference
```markdown
Task:
  subagent_type: coder
  prompt: Implement SC-1: Create authentication service

Task:
  subagent_type: coder
  prompt: Implement SC-2: Create user service

Task:
  subagent_type: coder
  prompt: Implement SC-3: Create database migrations
```

## Core Concepts

### Parallel Execution Patterns

**Pattern 1: Independent SCs**
```markdown
Task: subagent_type: explorer, prompt: Search for auth patterns
Task: subagent_type: explorer, prompt: Search for database patterns
Task: subagent_type: explorer, prompt: Search for API patterns
```

**Pattern 2: Parallel Verification**
```markdown
Task: subagent_type: tester, prompt: Run tests and verify coverage
Task: subagent_type: validator, prompt: Run type check and lint
Task: subagent_type: code-reviewer, prompt: Review for async bugs
```

**Pattern 3: Multi-Angle Review**
```markdown
Task: subagent_type: plan-reviewer, prompt: Review plan completeness
Task: subagent_type: code-reviewer, prompt: Review code quality
Task: subagent_type: security-analyst, prompt: Review security issues
```

### Dependency Analysis

**Before launching parallel agents**, check for conflicts:

1. **File Overlap**: Do SCs mention same files?
2. **Dependency Keywords**: "after", "depends", "requires", "follows"
3. **ParallelGroup Annotation**: Group independent SCs in plan

### Coordination

**Result Integration**:
- Wait for all parallel agents to complete
- Check for file conflicts (rare if analysis correct)
- Update todos atomically (all parallel items together)

**Performance**: 50-70% faster for independent tasks

## Anti-Patterns

**Don't parallelize**:
- Tasks with shared file modifications (causes merge conflicts)
- Tasks with dependencies (later task will fail)
- Sequential workflows (e.g., build then test)

## Verification

```bash
# Launch 3 independent tasks
Task: subagent_type: explorer, prompt: Find TypeScript files
Task: subagent_type: explorer, prompt: Find test files
Task: subagent_type: explorer, prompt: Find config files

# Verify all complete, no conflicts
```

## Further Reading

**Internal**: @.claude/skills/parallel-subagents/REFERENCE.md - Detailed dependency analysis, command-specific patterns, coordination examples | @.claude/skills/using-git-worktrees/SKILL.md - Parallel development in isolated worktrees

**External**: None
