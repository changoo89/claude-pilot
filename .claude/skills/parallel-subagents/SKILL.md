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
# Launch 3 parallel agents
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

---

## Core Concepts

### Parallel Execution Patterns

**Pattern 1: Independent SCs** (Exploration, Implementation)
```markdown
# Group: Independent exploration (no file conflicts)
Task: subagent_type: explorer, prompt: Search for auth patterns
Task: subagent_type: explorer, prompt: Search for database patterns
Task: subagent_type: explorer, prompt: Search for API patterns
```

**Pattern 2: Parallel Verification** (Testing, Type-check, Review)
```markdown
# Group: Verification (run concurrently)
Task: subagent_type: tester, prompt: Run tests and verify coverage
Task: subagent_type: validator, prompt: Run type check and lint
Task: subagent_type: code-reviewer, prompt: Review for async bugs
```

**Pattern 3: Multi-Angle Review** (Quality checks)
```markdown
# Group: Parallel review (different perspectives)
Task: subagent_type: plan-reviewer, prompt: Review plan completeness
Task: subagent_type: code-reviewer, prompt: Review code quality
Task: subagent_type: security-analyst, prompt: Review security issues
```

### Dependency Analysis

**Before launching parallel agents**, check for conflicts:

1. **File Overlap Check**:
   ```bash
   # Extract files from SC descriptions
   sc_1_files=$(echo "$SC_1" | grep -oE 'src/[^ ]+' | sort -u)
   sc_2_files=$(echo "$SC_2" | grep -oE 'src/[^ ]+' | sort -u)

   # Check for overlap
   if [ -n "$(comm -12 <(echo "$sc_1_files") <(echo "$sc_2_files"))" ]; then
     echo "⚠️  SC-1 and SC-2 share files - execute sequentially"
   fi
   ```

2. **Dependency Keyword Check**:
   ```bash
   # Look for dependency indicators
   if echo "$SC_2" | grep -qiE "after|depends|requires|follows"; then
     echo "⚠️  SC-2 has dependencies - execute after SC-1"
   fi
   ```

3. **ParallelGroup Annotation** (in plan):
   ```markdown
   ## Execution Plan
   **ParallelGroup-1**: SC-1, SC-2, SC-3 (independent)
   **SequentialGroup-1**: SC-4 (depends on SC-1)
   **ParallelGroup-2**: SC-5, SC-6 (independent)
   ```

---

## Coordination

### Result Integration

**Wait for all parallel agents to complete**:
```bash
# Collect all Task outputs
agent_1_result=$(wait_for_task "task-1-id")
agent_2_result=$(wait_for_task "task-2-id")
agent_3_result=$(wait_for_task "task-3-id")

# Process results together
echo "Agent 1: $agent_1_result"
echo "Agent 2: $agent_2_result"
echo "Agent 3: $agent_3_result"
```

**Check for conflicts**:
```bash
# Check if multiple agents modified same file
modified_files=$(comm -12 \
  <(echo "$agent_1_result" | grep modified | sort) \
  <(echo "$agent_2_result" | grep modified | sort))

if [ -n "$modified_files" ]; then
  echo "⚠️  Conflict: Both agents modified $modified_files"
  # Resolve conflict (prefer agent_2, or ask user)
fi
```

### Todo State Management

**Update todos atomically** (all parallel items together):
```bash
# When launching parallel group
update_state "SC-1" "in_progress" 1
update_state "SC-2" "in_progress" 1
update_state "SC-3" "in_progress" 1

# After all complete
update_state "SC-1" "completed" 1
update_state "SC-2" "completed" 1
update_state "SC-3" "completed" 1
```

---

## Performance

### Expected Speedup

- **Independent tasks**: 50-70% faster (3 tasks in ~1.5x time, not 3x)
- **Verification tasks**: 60-70% faster (test + type-check + lint concurrently)
- **Review tasks**: 50-60% faster (multiple perspectives in parallel)

### Overhead Considerations

- **State management**: Additional ~5-10% overhead for coordination
- **Conflict resolution**: Rare if dependency analysis done correctly
- **Token usage**: Higher concurrent usage but faster wall-clock time

---

## Verification

### Test Parallel Execution
```bash
# Launch 3 independent tasks in parallel
Task:
  subagent_type: explorer
  prompt: Find all TypeScript files in src/

Task:
  subagent_type: explorer
  prompt: Find all test files in tests/

Task:
  subagent_type: explorer
  prompt: Find all config files in root

# Verify all complete
# Verify no file conflicts
# Verify results integrated
```

---

## Anti-Patterns

**Don't parallelize**:
- Tasks with shared file modifications (causes merge conflicts)
- Tasks with dependencies (later task will fail)
- Sequential workflows (e.g., build then test)

**Example of BAD parallelization**:
```markdown
# ❌ WRONG: These conflict
Task: Implement authentication in src/auth.ts
Task: Add tests to src/auth.test.ts
# Both modify src/auth.ts - execute sequentially instead
```

**Example of GOOD parallelization**:
```markdown
# ✅ CORRECT: Independent files
Task: Implement auth service src/auth/auth.service.ts
Task: Implement user service src/users/user.service.ts
Task: Implement data service src/data/data.service.ts
# All different files - safe to parallelize
```

---

## Related Skills

- **using-git-worktrees**: Parallel development in isolated workspaces
- **ralph-loop**: Autonomous iteration with parallel execution support

---

**Version**: claude-pilot 4.2.0
