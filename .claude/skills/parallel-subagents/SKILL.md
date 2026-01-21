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

## Command-Specific Patterns

### /00_plan: Parallel Exploration (Explorer + Researcher)

**Use Case**: Initial exploration phase to gather context and research

**Pattern**:
```markdown
## Step 1.1: Parallel Exploration

### Task 1.1a: Codebase Exploration
Task:
  subagent_type: explorer
  prompt: |
    Find relevant files for {task}
    - Search for TypeScript/JavaScript files in src/
    - Look for existing patterns related to {domain}
    - Identify config files and test files
    - Output: File list with brief descriptions

### Task 1.1b: External Research
Task:
  subagent_type: researcher
  prompt: |
    Research external documentation for {task}
    - Search for official docs, best practices
    - Find similar implementations/examples
    - Identify security considerations
    - Output: Research summary with links
```

**Integration Point**: Add after Step 1 in `/00_plan`

**Result**: 50-60% faster exploration (codebase + external research in parallel)

---

### /02_execute: Multi-Coder SC Execution

**Use Case**: Multiple independent SCs that can be implemented simultaneously

**Dependency Analysis Script**:
```bash
#!/bin/bash
# Analyze SC dependencies for parallel execution

analyze_sc_dependencies() {
    local plan_file="$1"
    local sc_list=$(grep -E "^- \[ \] \*\*SC-" "$plan_file" | sed 's/.*\*\*SC-\([0-9]*\)\*\*.*/SC-\1/')

    echo "# Dependency Analysis Results"
    echo ""

    for sc in $sc_list; do
        sc_content=$(sed -n "/\*\*${sc}\*\*/,/^\*- \[ \]/p" "$plan_file" | head -n -1)

        # Extract file mentions
        files=$(echo "$sc_content" | grep -oE 'src/[^ [:space:]]+' | sort -u | tr '\n' ' ')

        # Check for dependency keywords
        deps=$(echo "$sc_content" | grep -iE 'after|depends|requires|follows' || true)

        if [ -n "$deps" ]; then
            echo "**Sequential**: $sc (has dependencies)"
        elif [ -n "$files" ]; then
            echo "**ParallelGroup**: $sc (files: $files)"
        else
            echo "**ParallelGroup**: $sc (no file conflicts detected)"
        fi
    done
}
```

**Parallel Execution Pattern**:
```markdown
## Step 3.1: Dependency Analysis
[Bash script to analyze SC dependencies]

## Step 3.2a: Parallel Execution (Independent SCs)
### Task 3.2a-1: Coder for SC-1
Task:
  subagent_type: coder
  prompt: |
    Execute SC-1 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-1: {SC-1 description}

### Task 3.2a-2: Coder for SC-2
Task:
  subagent_type: coder
  prompt: |
    Execute SC-2 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-2: {SC-2 description}

### Task 3.2a-3: Coder for SC-3
Task:
  subagent_type: coder
  prompt: |
    Execute SC-3 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-3: {SC-3 description}

### Task 3.2a-4: Coder for SC-4
Task:
  subagent_type: coder
  prompt: |
    Execute SC-4 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-4: {SC-4 description}

## Step 3.2b: Sequential Execution (Dependent SCs)
[For SCs with dependencies, execute sequentially]

## Step 3.3: Process Results
[Wait for all parallel agents, verify completion markers]
```

**Integration Point**: Replace Step 3 in `/02_execute`

**Result**: 50-70% speedup for independent SCs (4 SCs in ~1.5x time, not 4x)

---

### /review: Multi-Angle Parallel Verification

**Use Case**: Comprehensive review from multiple perspectives simultaneously

**Pattern**:
```markdown
## Step 2: Multi-Angle Parallel Review

### Task 2.1: Test Coverage Review
Task:
  subagent_type: tester
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate test coverage and verification:
    - Are all SCs verifiable?
    - Do verify commands exist?
    - Is coverage threshold ≥80%?
    Output: TEST_PASS or TEST_FAIL with findings

### Task 2.2: Type Safety & Lint Review
Task:
  subagent_type: validator
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate type safety and code quality:
    - Are types specified?
    - Is lint check included?
    - Any potential issues?
    Output: VALIDATE_PASS or VALIDATE_FAIL with findings

### Task 2.3: Code Quality Review
Task:
  subagent_type: code-reviewer
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate code quality and design:
    - SRP, DRY, KISS compliance?
    - Function/file size limits?
    - Early return pattern?
    Output: REVIEW_PASS or REVIEW_FAIL with findings

## Step 3: Aggregate Results
[Combine all 3 reviews, BLOCKING if any FAIL]
```

**Integration Point**: Replace Step 2 in `/review`

**Result**: 60-70% faster review (test + type + quality in parallel)

---

### /03_close: Parallel Verification

**Use Case**: Final verification before closing plan

**Pattern**:
```markdown
## Step 3: Parallel Verification

### Task 3.1: Verify SC Completion
Task:
  subagent_type: validator
  prompt: |
    Verify all SCs marked complete in $PLAN_PATH
    - Check all checkboxes: [x]
    - Verify evidence exists
    Output: VERIFY_PASS or VERIFY_FAIL

### Task 3.2: Verify Test Results
Task:
  subagent_type: tester
  prompt: |
    Run verify commands from $PLAN_PATH
    - Execute all verify: commands
    - Check test coverage ≥80%
    Output: TEST_PASS or TEST_FAIL with details
```

**Integration Point**: Add after Step 2 in `/03_close`

---

### /05_cleanup: Parallel File Scanning

**Use Case**: Scan multiple directories simultaneously for cleanup candidates

**Pattern**:
```markdown
## Step 1: Parallel Detection

### Task 1.1: Scan Source Files
Task:
  subagent_type: explorer
  prompt: |
    Find dead files in src/
    - Check for unused imports
    - Find unreferenced files
    Output: List of candidates

### Task 1.2: Scan Test Files
Task:
  subagent_type: explorer
  prompt: |
    Find dead files in tests/
    - Check for orphaned test files
    - Find unreferenced fixtures
    Output: List of candidates

### Task 1.3: Scan Config Files
Task:
  subagent_type: explorer
  prompt: |
    Find dead config files
    - Unused .env files
    - Stale config files
    Output: List of candidates

## Step 2: Aggregate Results
[Merge all candidate lists, classify by risk]
```

**Integration Point**: Replace Step 1 in `/05_cleanup`

**Result**: 60-70% faster scanning (3 parallel directory scans)

---

## Coordination Patterns

### File Conflict Prevention

**Each parallel agent works on different files**:

```markdown
# Coder-1: src/auth/*
Task: subagent_type: coder
prompt: Implement SC-1 (auth service)

# Coder-2: src/users/*
Task: subagent_type: coder
prompt: Implement SC-2 (user service)

# Coder-3: src/data/*
Task: subagent_type: coder
prompt: Implement SC-3 (data service)
```

**Overlap Detection**:
```bash
# Before parallel execution, verify no file overlap
sc_1_files=$(grep -oE 'src/[^ ]+' sc1.txt | sort -u)
sc_2_files=$(grep -oE 'src/[^ ]+' sc2.txt | sort -u)

overlap=$(comm -12 <(echo "$sc_1_files") <(echo "$sc_2_files"))
if [ -n "$overlap" ]; then
    echo "⚠️  File overlap detected: $overlap"
    echo "Execute SC-1 and SC-2 sequentially"
fi
```

### Result Integration

**Wait for all agents, then integrate**:

```markdown
# After parallel execution completes
## Step 4: Integrate Results

1. Check for <CODER_COMPLETE> markers
2. Run tests: npm test
3. If tests pass: Mark all SCs as complete
4. If tests fail: Sequential retry of failed SCs
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
