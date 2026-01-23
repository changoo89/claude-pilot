# REFERENCE: Parallel Subagents

> **Detailed patterns, examples, and troubleshooting for parallel agent execution**

---

## Dependency Analysis

### File Overlap Check

```bash
# Extract files from SC descriptions
sc_1_files=$(echo "$SC_1" | grep -oE 'src/[^ ]+' | sort -u)
sc_2_files=$(echo "$SC_2" | grep -oE 'src/[^ ]+' | sort -u)

# Check for overlap
if [ -n "$(comm -12 <(echo "$sc_1_files") <(echo "$sc_2_files"))" ]; then
  echo "⚠️  SC-1 and SC-2 share files - execute sequentially"
fi
```

### Dependency Keyword Check

```bash
# Look for dependency indicators
if echo "$SC_2" | grep -qiE "after|depends|requires|follows"; then
  echo "⚠️  SC-2 has dependencies - execute after SC-1"
fi
```

### ParallelGroup Annotation

```markdown
## Execution Plan
**ParallelGroup-1**: SC-1, SC-2, SC-3 (independent)
**SequentialGroup-1**: SC-4 (depends on SC-1)
**ParallelGroup-2**: SC-5, SC-6 (independent)
```

## Coordination

### Result Integration

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

### Conflict Detection

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

## Command-Specific Patterns

### /00_plan: Parallel Exploration

```markdown
## Step 1.1: Parallel Exploration

### Task 1.1a: Codebase Exploration
Task:
  subagent_type: claude-pilot:explorer
  prompt: |
    Find relevant files for {task}
    - Search for TypeScript/JavaScript files in src/
    - Look for existing patterns related to {domain}
    - Identify config files and test files
    - Output: File list with brief descriptions

### Task 1.1b: External Research
Task:
  subagent_type: claude-pilot:researcher
  prompt: |
    Research external documentation for {task}
    - Search for official docs, best practices
    - Find similar implementations/examples
    - Identify security considerations
    - Output: Research summary with links
```

### /02_execute: Multi-Coder SC Execution

```markdown
## Step 3.1: Dependency Analysis
[Analyze SC dependencies]

## Step 3.2a: Parallel Execution (Independent SCs)
### Task 3.2a-1: Coder for SC-1
Task:
  subagent_type: claude-pilot:coder
  prompt: Execute SC-1 from $PLAN_PATH

### Task 3.2a-2: Coder for SC-2
Task:
  subagent_type: claude-pilot:coder
  prompt: Execute SC-2 from $PLAN_PATH

## Step 3.2b: Sequential Execution (Dependent SCs)
[For SCs with dependencies, execute sequentially]

## Step 3.3: Process Results
[Wait for all parallel agents, verify completion markers]
```

### /review: Multi-Angle Parallel Verification

```markdown
## Step 2: Multi-Angle Parallel Review

### Task 2.1: Test Coverage Review
Task:
  subagent_type: claude-pilot:tester
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate test coverage and verification:
    - Are all SCs verifiable?
    - Do verify commands exist?
    - Is coverage threshold ≥80%?
    Output: TEST_PASS or TEST_FAIL with findings

### Task 2.2: Type Safety & Lint Review
Task:
  subagent_type: claude-pilot:validator
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate type safety and code quality

### Task 2.3: Code Quality Review
Task:
  subagent_type: claude-pilot:code-reviewer
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate code quality and design

## Step 3: Aggregate Results
[Combine all 3 reviews, BLOCKING if any FAIL]
```

## Anti-Patterns

### Bad Parallelization

```markdown
# ❌ WRONG: These conflict
Task: Implement authentication in src/auth.ts
Task: Add tests to src/auth.test.ts
# Both modify src/auth.ts - execute sequentially instead
```

### Good Parallelization

```markdown
# ✅ CORRECT: Independent files
Task: Implement auth service src/auth/auth.service.ts
Task: Implement user service src/users/user.service.ts
Task: Implement data service src/data/data.service.ts
# All different files - safe to parallelize
```

## Performance

- **Independent tasks**: 50-70% faster
- **Verification tasks**: 60-70% faster
- **Review tasks**: 50-60% faster
- **Overhead**: ~5-10% for coordination

## Troubleshooting

**Issue**: Merge conflicts after parallel execution
**Solution**: Improve dependency analysis, check file overlap before launching

**Issue**: Sequential tasks executed in parallel
**Solution**: Check for dependency keywords (after, depends, requires, follows)

**Issue**: Partial results from parallel agents
**Solution**: Wait for all agents to complete before integration
