# Parallel Execution Guide - Deep Reference

> **Purpose**: Detailed reference for parallel execution patterns in claude-pilot
> **Companion**: @.claude/guides/parallel-execution.md (Quick Reference)

---

## Pattern 1: Parallel Exploration (/00_plan)

**Architecture**:
```
Main Orchestrator
    ↓ (Parallel Task calls)
Explorer (Haiku) + Researcher (Haiku)
    ↓
Result Merge → Plan Creation
```

**Implementation**:
```markdown
Task:
  subagent_type: explorer
  prompt: |
    Explore codebase for {FEATURE}:
    - Find related files using Glob
    - Search patterns using Grep
    - Return structured summary

Task:
  subagent_type: researcher
  prompt: |
    Research {TOPIC}:
    - Use query-docs for library docs
    - Use WebSearch for best practices
    - Return structured summary
```

**Result Merge**:
1. Explorer Summary → "Explored Files" table
2. Researcher Summary → "Research Findings" table
3. Test Environment → "Test Environment (Detected)"
4. Integration → Merge findings

---

## Pattern 2: Parallel SC Implementation (/02_execute)

**Architecture**:
```
Main Orchestrator
    ↓ (Parallel per SC)
Coder-SC1 + Coder-SC2 + Coder-SC3
    ↓
Result Integration
    ↓ (Parallel verification)
Tester + Validator + Code-Reviewer
    ↓
Ralph Loop Verification
```

**Implementation**:
```markdown
# SC Dependency Analysis
Group 1 (Independent): SC-1, SC-2, SC-3
Group 2 (Dependent): SC-4, SC-5 (require Group 1)

# Parallel execution for Group 1
Task:
  subagent_type: coder
  prompt: Execute SC-1: {DESCRIPTION}

Task:
  subagent_type: coder
  prompt: Execute SC-2: {DESCRIPTION}

# After all parallel coders complete:
Task:
  subagent_type: tester
  prompt: Run tests and verify coverage

Task:
  subagent_type: validator
  prompt: Run type check and lint

Task:
  subagent_type: code-reviewer
  prompt: Review for async bugs, memory leaks
```

**File Conflict Prevention**:
- Each parallel Coder works on different files
- Clear file ownership per SC
- Merge results after parallel phase

---

## Pattern 3: Parallel Multi-Angle Review (/review)

**Use Case**: Comprehensive plan review from multiple perspectives

**Architecture**:
```
Main Orchestrator
    ↓ (Parallel 6 angles)
Security + Quality + Testing + Architecture Reviewers
    ↓
Comprehensive Report Merge
```

**When to Use**:
- Large, complex plans
- High-stakes features (security, payments)
- System-wide architectural changes

**When NOT to Use**:
- Small, straightforward changes
- Resource constraints
- Time-sensitive reviews

---

## Task Tool Syntax

### Basic Invocation
```markdown
Task:
  subagent_type: {agent_name}
  prompt: |
    {task_description}
```

### Parallel Invocation
```markdown
# Multiple Task calls = parallel execution
Task:
  subagent_type: agent1
  prompt: |

Task:
  subagent_type: agent2
  prompt: |

Task:
  subagent_type: agent3
  prompt: |
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
| code-reviewer | opus | Read, Glob, Grep, Bash | Deep code review (async, memory) |
| documenter | haiku | Read, Write | Documentation generation |

---

## Best Practices

### 1. Dependency Analysis
Before parallel execution, analyze:
- **File dependencies**: Which files are affected?
- **SC dependencies**: Do SCs depend on each other?
- **Integration points**: Shared components or interfaces?

### 2. File Conflict Prevention
- Each parallel agent works on different files
- Use clear file ownership per task
- Coordinate shared interfaces in advance
- Merge results after parallel phase

### 3. Result Integration
- Wait for all parallel agents to complete
- Merge results in predictable order
- Verify no conflicts in merged output
- Run integration tests after merge

### 4. Error Handling

> **🚨 CRITICAL - TaskOutput Anti-Pattern**
> **DO NOT** use `TaskOutput` after Task tool completion. Results are returned inline automatically.

✅ **CORRECT**: Process inline result directly, look for `<CODER_COMPLETE>` or `<CODER_BLOCKED>` markers

❌ **WRONG**: `TaskOutput: {task_id}` - ID already consumed, will fail

**Error Recovery**:
If one parallel agent fails:
1. Note the failure
2. Continue waiting for other agents
3. Present all results together
4. Use `AskUserQuestion` for recovery options

### 5. Resource Management
- Parallel execution increases API costs
- Use Haiku for cost-sensitive tasks
- Reserve Opus for critical review only
- Monitor token usage

---

## Todo Management

### Default Rule (Sequential Work)
- **Exactly one `in_progress` at a time**
- Mark complete immediately after finishing

### Parallel Group Rule (Parallel Work)
- **Mark ALL parallel items as `in_progress` simultaneously**
- Complete them together when ALL agents return

**Example**:
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
Task: Edit src/auth.ts to add login
Task: Edit src/auth.ts to add logout
# Result: Conflict, lost changes
```

### Example Good Parallelization:
```markdown
# GOOD: Agents edit different files
Task: Edit src/auth/login.ts
Task: Edit src/auth/logout.ts
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

| Issue | Solution |
|-------|----------|
| Parallel agents have conflicts | Run sequentially, reorganize file ownership |
| One agent failed, others succeeded | Re-run only failed agent, preserve successful results |
| Integration tests fail | Check for missed integration points, add integration SC |
| Token costs too high | Reduce parallelization, use Haiku more |

---

## Examples

### Example 1: Simple Feature (Sequential)
```
Plan: Add simple utility function
→ Single Coder agent (no parallelization needed)
```

### Example 2: Medium Feature (Some Parallel)
```
Plan: Add auth + logout
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3
→ Sequential: Integration (if needed)
```

### Example 3: Complex Feature (Full Parallel)
```
Plan: Payment system integration
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3, Coder-SC4
→ Parallel: Tester, Validator, Code-Reviewer
→ Sequential: Integration, docs
```

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Gap Detection**: @.claude/guides/gap-detection.md

---

**Version**: 1.0.0
**Last Updated**: 2026-01-17
