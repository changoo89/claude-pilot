# Parallel Execution Guide

> **Last Updated**: 2026-01-15
> **Version**: 1.0.0

## Overview

This guide documents all parallel execution patterns used in claude-pilot for maximizing workflow efficiency through context isolation and concurrent agent execution.

## Benefits of Parallel Execution

| Benefit | Description | Impact |
|---------|-------------|--------|
| **Speed** | 50-70% execution time reduction | Faster delivery |
| **Context Isolation** | 8x token efficiency | Lower costs |
| **Quality** | Specialized agents per task | Better outcomes |
| **Scalability** | Independent tasks run concurrently | Handles complexity |

## Model Allocation Strategy

| Model | Agents | Rationale |
|-------|--------|-----------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient for repetitive/structured tasks |
| **Sonnet** | coder, tester, plan-reviewer | Balance of quality and speed for complex tasks |
| **Opus** | code-reviewer | Deep reasoning for critical review (async bugs, memory leaks, subtle logic errors) |

## Parallel Patterns

### Pattern 1: Parallel Exploration (/00_plan)

**Use Case**: Planning phase - explore codebase and research external docs concurrently

**Architecture**:
```
┌─────────────────────────────────────────────────┐
│              Main Orchestrator                  │
└────────┬────────────────────────────────────────┘
         │ Parallel Task calls
         ▼
┌────────────────┐  ┌────────────────┐
│   Explorer     │  │   Researcher   │
│   (Haiku)      │  │   (Haiku)      │
│ Glob/Grep/Read │  │ WebSearch/Docs │
└────────┬───────┘  └────────┬───────┘
         │                   │
         └───────┬───────────┘
                 ▼
         [Result Merge → Plan Creation]
```

**Implementation**:
```markdown
# Parallel invocation in /00_plan
Task:
  subagent_type: explorer
  prompt: |
    Explore the codebase for {FEATURE}:
    - Find related files using Glob
    - Search for patterns using Grep
    - Read key files to understand architecture
    - Return structured summary

Task:
  subagent_type: researcher
  prompt: |
    Research {TOPIC/TECHNOLOGY}:
    - Use query-docs for library-specific documentation
    - Use WebSearch for best practices
    - Return structured summary with sources
```

**Result Merge**:
1. Explorer Summary → "Explored Files" table
2. Researcher Summary → "Research Findings" table
3. Test Environment (main thread) → "Test Environment (Detected)" section
4. Integration → Merge findings, identify conflicts

---

### Pattern 2: Parallel SC Implementation (/02_execute)

**Use Case**: Execute independent Success Criteria concurrently

**Architecture**:
```
┌─────────────────────────────────────────────────┐
│              Main Orchestrator                  │
└────────┬────────────────────────────────────────┘
         │ Parallel Task calls (per SC)
         ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Coder-SC1   │ │  Coder-SC2   │ │  Coder-SC3   │
│  (Sonnet)    │ │  (Sonnet)    │ │  (Sonnet)    │
│  TDD Cycle   │ │  TDD Cycle   │ │  TDD Cycle   │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       └────────┬───────┴────────────────┘
                ▼
         [Result Integration]
                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   Tester     │ │  Validator   │ │ Code-Reviewer│
│  (Sonnet)    │ │  (Haiku)     │ │  (Opus)      │
│  Tests Run   │ │ Type+Lint+Cov│ │  Deep Review │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       └────────┬───────┴────────────────┘
                ▼
         [Ralph Loop Verification]
```

**Implementation**:
```markdown
# SC Dependency Analysis
Group 1 (Independent): SC-1, SC-2, SC-3
Group 2 (Dependent): SC-4, SC-5 (require Group 1)

# Parallel execution for Group 1
Task:
  subagent_type: coder
  prompt: |
    Execute SC-1: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}
    Implement using TDD + Ralph Loop

Task:
  subagent_type: coder
  prompt: |
    Execute SC-2: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}
    Implement using TDD + Ralph Loop

# After all parallel coders complete:
Task:
  subagent_type: tester
  prompt: |
    Run tests and verify coverage
    Test Command: {TEST_CMD}
    Coverage Command: {COVERAGE_CMD}

Task:
  subagent_type: validator
  prompt: |
    Run type check and lint
    Type Check: {TYPE_CMD}
    Lint: {LINT_CMD}

Task:
  subagent_type: code-reviewer
  prompt: |
    Review implemented code for:
    - Async bugs, memory leaks, race conditions
    - Security vulnerabilities
    - Code quality and Vibe Coding compliance
    Files: {FILE_LIST}
```

**Dependency Analysis**:
| SC | Files Affected | Dependencies | Parallel Group |
|----|----------------|--------------|----------------|
| SC-1 | `src/auth/login.ts` | None | Group 1 |
| SC-2 | `src/auth/logout.ts` | None | Group 1 |
| SC-3 | `tests/auth.test.ts` | None | Group 1 |
| SC-4 | `src/auth/middleware.ts` | SC-1 | Group 2 |
| SC-5 | `src/auth/session.ts` | SC-1, SC-2 | Group 2 |

**File Conflict Prevention**:
- Each parallel Coder instance works on different files
- Clear file ownership per SC
- Coordinate integration points in advance
- Merge results after parallel phase

---

### Pattern 3: Parallel Multi-Angle Review (/90_review)

**Use Case**: Comprehensive plan review from multiple perspectives

**Architecture**:
```
┌─────────────────────────────────────────────────┐
│              Main Orchestrator                  │
└────────┬────────────────────────────────────────┘
         │ Parallel Task calls (6 angles)
         ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│Security │ │Quality  │ │Testing  │ │Architecture│
│Reviewer │ │Reviewer │ │Reviewer │ │Reviewer │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
     │           │           │           │
     └───────────┴─────┬─────┴───────────┘
                        ▼
               [Comprehensive Report Merge]
```

**Implementation**:
```markdown
# Parallel review angles (for complex plans)
Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from SECURITY angle:
    - External API security
    - Input validation
    - Authentication/authorization
    - Secret management

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from QUALITY angle:
    - Vibe Coding compliance
    - Code quality standards
    - Testing coverage
    - Documentation completeness

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from ARCHITECTURE angle:
    - System design
    - Component relationships
    - Scalability considerations
    - Integration points
```

**When to Use**:
- Large, complex plans
- High-stakes features (security, payments, auth)
- System-wide architectural changes
- When multiple independent perspectives are valuable

**When NOT to Use**:
- Small, straightforward changes
- Resource constraints (parallel review is expensive)
- Time-sensitive reviews (sequential is faster for simple plans)

---

## Task Tool Syntax

### Basic Invocation
```markdown
Task:
  subagent_type: {agent_name}
  prompt: |
    {task_description}
    {context}
    {expected_output}
```

### Parallel Invocation
```markdown
# Invoke multiple agents concurrently
Task:
  subagent_type: agent1
  prompt: |

Task:
  subagent_type: agent2
  prompt: |

Task:
  subagent_type: agent3
  prompt: |

# Results arrive when all complete
```

### Agent Reference

| Agent | Model | Tools | Use Case |
|-------|-------|-------|----------|
| explorer | haiku | Glob, Grep, Read | Fast codebase exploration |
| researcher | haiku | WebSearch, WebFetch, query-docs | External docs research |
| coder | sonnet | Read, Write, Edit, Bash | TDD implementation |
| tester | sonnet | Read, Write, Bash | Test writing and execution |
| validator | haiku | Bash, Read | Type check, lint, coverage |
| plan-reviewer | sonnet | Read, Glob, Grep | Plan analysis and gap detection |
| code-reviewer | opus | Read, Glob, Grep, Bash | Deep code review (async, memory, security) |
| documenter | haiku | Read, Write | Documentation generation |

---

## Best Practices

### 1. Dependency Analysis
Before parallel execution, always analyze:
- **File dependencies**: Which files are affected?
- **SC dependencies**: Do SCs depend on each other?
- **Integration points**: Shared components or interfaces?

### 2. File Conflict Prevention
- Each parallel agent should work on different files
- Use clear file ownership per task
- Coordinate shared interfaces in advance
- Merge results after parallel phase

### 3. Result Integration
- Wait for all parallel agents to complete
- Merge results in predictable order
- Verify no conflicts in merged output
- Run integration tests after merge

### 4. Error Handling
- If one parallel agent fails, note the failure
- Continue waiting for other agents
- Present all results together
- Re-run only failed agents

### 5. Resource Management
- Parallel execution increases API costs
- Use Haiku for cost-sensitive tasks
- Reserve Opus for critical review only
- Monitor token usage

---

## Todo Management

### Default Rule (Sequential Work)

For sequential execution (one task at a time):
- **Exactly one `in_progress` at a time**
- Mark complete immediately after finishing
- No batching multiple todos together

**Example Todo Display**:
```markdown
[Sequential]
- ✅ Read plan file
- 🔄 SC-1: Add login  ← in_progress (alone)
- ⏳ SC-2: Add logout
- ⏳ Run tests
```

### Parallel Group Rule (Parallel Work)

When executing parallel tasks (multiple Task calls in same message):
- **Mark ALL parallel items as `in_progress` simultaneously**
- Use `[Parallel Group N]` prefix to indicate parallel execution
- Complete them together when ALL agents return

**Example Todo Display**:
```markdown
[Parallel Group 1]
- 🔄 SC-1: Add login      ← in_progress (together)
- 🔄 SC-2: Add logout     ← in_progress (together)
- 🔄 SC-3: Add middleware ← in_progress (together)

[After all return]
- ✅ SC-1: Add login      ← completed together
- ✅ SC-2: Add logout     ← completed together
- ✅ SC-3: Add middleware ← completed together
```

### When to Use Each Rule

| Execution Type | Todo Rule | Example |
|----------------|-----------|---------|
| **Sequential** | Default (one `in_progress`) | Single Coder agent for all SCs |
| **Parallel** | Parallel Group (multiple `in_progress`) | Multiple Coder agents for independent SCs |

### Visual Indicators

**Sequential Todo Display**:
```markdown
[Sequential]
- ✅ SC-1: Read plan file
- 🔄 SC-2: Implement feature X
- ⏳ SC-3: Implement feature Y
- ⏳ SC-4: Run tests
```

**Parallel Todo Display**:
```markdown
[Parallel Group 1]
- 🔄 SC-1: Implement feature X    (Coder Agent 1)
- 🔄 SC-2: Implement feature Y    (Coder Agent 2)
- 🔄 SC-3: Implement feature Z    (Coder Agent 3)

[Parallel Group 2 - Verification]
- 🔄 Run tests                    (Tester Agent)
- 🔄 Run type check + lint        (Validator Agent)
- 🔄 Code review                  (Code-Reviewer Agent)
```

### Implementation Notes

**Parallel Execution Context**:
- Multiple agents work simultaneously in isolated contexts
- Each agent returns summary when complete
- Main orchestrator updates todos based on completion markers
- All parallel todos marked complete together when ALL agents return

**Rationale**:
- Aligns with general software development practices (CI/CD parallel jobs, Airflow DAG, Kubernetes Pod states)
- Provides accurate progress visibility for users
- Matches documented parallel execution patterns
- Preserves backward compatibility with sequential work

---

## Anti-Patterns

### Don't Parallelize When:
- [ ] Tasks share the same files (conflict risk)
- [ ] Tasks have dependencies (ordering matters)
- [ ] Tasks are trivial (overhead > benefit)
- [ ] Resource constraints exist (cost/speed)

### Example Bad Parallelization:
```markdown
# BAD: Both agents edit same file
Task:
  subagent_type: coder
  prompt: Edit src/auth.ts to add login

Task:
  subagent_type: coder
  prompt: Edit src/auth.ts to add logout

# Result: Conflict, lost changes
```

### Example Good Parallelization:
```markdown
# GOOD: Agents edit different files
Task:
  subagent_type: coder
  prompt: Edit src/auth/login.ts

Task:
  subagent_type: coder
  prompt: Edit src/auth/logout.ts

# Result: No conflicts, faster execution
```

---

## Verification

After parallel execution, verify:
- [ ] All agents completed successfully
- [ ] No file conflicts in output
- [ ] Integration tests pass
- [ ] Coverage targets met
- [ ] Type check clean
- [ ] Lint clean

---

## Troubleshooting

### Issue: Parallel agents have conflicts
**Solution**: Run sequentially instead, or reorganize file ownership

### Issue: One agent failed, others succeeded
**Solution**: Re-run only failed agent, preserve successful results

### Issue: Integration tests fail after parallel execution
**Solution**: Check for missed integration points, add integration SC

### Issue: Token costs too high
**Solution**: Reduce parallelization, use Haiku more, reserve Opus for critical tasks

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Gap Detection**: @.claude/guides/gap-detection.md
- **Review Checklist**: @.claude/guides/review-checklist.md

---

## Examples

### Example 1: Simple Feature (Sequential)
```
Plan: Add simple utility function
SC-1: Create util function
→ Single Coder agent (no parallelization needed)
```

### Example 2: Medium Feature (Some Parallel)
```
Plan: Add auth + logout
SC-1: Add login (src/auth/login.ts)
SC-2: Add logout (src/auth/logout.ts)
SC-3: Add tests (tests/auth.test.ts)
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3
→ Sequential: Integration (if needed)
```

### Example 3: Complex Feature (Full Parallel)
```
Plan: Payment system integration
SC-1: Stripe client (src/payment/stripe.ts)
SC-2: PayPal client (src/payment/paypal.ts)
SC-3: Payment API (src/api/payment.ts)
SC-4: Tests (tests/payment.test.ts)
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3, Coder-SC4
→ Parallel: Tester, Validator, Code-Reviewer
→ Sequential: Integration, docs
```

---

**Version**: 1.0.0
**Last Updated**: 2026-01-15
