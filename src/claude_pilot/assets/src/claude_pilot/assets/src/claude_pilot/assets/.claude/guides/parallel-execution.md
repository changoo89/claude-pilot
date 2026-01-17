# Parallel Execution Guide

> **Last Updated**: 2026-01-17
> **Version**: 1.0.0
> **Full Reference**: @.claude/guides/parallel-execution-REFERENCE.md

---

## Quick Reference

| Pattern | Command | Agents | Purpose |
|---------|---------|--------|---------|
| **Parallel Exploration** | `/00_plan` Step 0 | Explorer + Researcher | Codebase + external docs |
| **Parallel Coder** | `/02_execute` Step 2.3 | Multiple Coders | Independent SCs |
| **Parallel Verify** | `/02_execute` Step 2.4 | Tester + Validator + Code-Reviewer | Multi-angle verification |
| **Parallel Review** | `/90_review` (optional) | Multiple Plan-Reviewers | Complex plan analysis |

**Key Benefits**: 50-70% faster, 8x token efficiency, specialized agents per task

**See Also**: @docs/ai-context/system-integration.md - Agent coordination patterns

---

## Overview

This guide documents parallel execution patterns for maximizing workflow efficiency through context isolation and concurrent agent execution.

## Benefits

| Benefit | Impact |
|---------|--------|
| **Speed** | 50-70% execution time reduction |
| **Context Isolation** | 8x token efficiency |
| **Quality** | Specialized agents per task |
| **Scalability** | Independent tasks run concurrently |

## Model Allocation

| Model | Agents | Rationale |
|-------|--------|-----------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient |
| **Sonnet** | coder, tester, plan-reviewer | Quality + speed balance |
| **Opus** | code-reviewer | Deep reasoning (async, memory, security) |

---

## Parallel Patterns

### Pattern 1: Parallel Exploration (/00_plan)

**Use Case**: Explore codebase + research external docs concurrently

**Architecture**: Explorer (Glob/Grep/Read) + Researcher (WebSearch/Docs) → Result Merge

**Summary**: Launch both agents in parallel, merge findings into plan

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#pattern-1

---

### Pattern 2: Parallel SC Implementation (/02_execute)

**Use Case**: Execute independent Success Criteria concurrently

**Architecture**: Multiple Coders (parallel) → Integration → Tester + Validator + Code-Reviewer (parallel)

**Key Requirements**:
- **File isolation**: Each agent works on different files
- **SC dependency analysis**: Group independent SCs together
- **Result merge**: Combine after all agents complete

**Summary**: Analyze dependencies, group independent SCs, execute in parallel, verify results

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#pattern-2

---

### Pattern 3: Parallel Multi-Angle Review (/90_review)

**Use Case**: Comprehensive plan review from multiple perspectives

**Architecture**: Multiple Plan-Reviewers (Security, Quality, Testing, Architecture) → Report Merge

**When to Use**:
- Large, complex plans
- High-stakes features (security, payments, auth)
- System-wide architectural changes

**When NOT to Use**:
- Small, straightforward changes
- Resource constraints
- Time-sensitive reviews

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#pattern-3

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
| code-reviewer | opus | Read, Glob, Grep, Bash | Deep code review |
| documenter | haiku | Read, Write | Documentation generation |

> **⚠️ CRITICAL**: Agent names are case-sensitive. Always use lowercase:
> - `explorer`, `researcher`, `coder`, `tester`, `validator`, `plan-reviewer`, `code-reviewer`, `documenter`

---

## Best Practices Summary

### 1. Dependency Analysis
Before parallel execution: File dependencies, SC dependencies, integration points

### 2. File Conflict Prevention
- Each agent works on different files
- Clear file ownership per task
- Merge results after parallel phase

### 3. Result Integration
- Wait for all agents to complete
- Merge in predictable order
- Run integration tests after merge

### 4. Error Handling

> **🚨 CRITICAL - TaskOutput Anti-Pattern**
> **DO NOT** use `TaskOutput` after Task tool completion. Results are returned inline automatically.

**Correct Pattern**: Process inline result directly, look for `<CODER_COMPLETE>` or `<CODER_BLOCKED>` markers

**Error Recovery**: If agent fails, use `AskUserQuestion` for recovery options

### 5. Resource Management
- Use Haiku for cost-sensitive tasks
- Reserve Opus for critical review only
- Monitor token usage

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#best-practices

---

## Todo Management

### Default Rule (Sequential Work)
- **Exactly one `in_progress` at a time**
- Mark complete immediately after finishing

### Parallel Group Rule (Parallel Work)
- **Mark ALL parallel items as `in_progress` simultaneously**
- Complete together when ALL agents return

| Execution Type | Todo Rule | Example |
|----------------|-----------|---------|
| **Sequential** | One `in_progress` | Single Coder for all SCs |
| **Parallel** | Multiple `in_progress` | Multiple Coders for independent SCs |

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#todo-management

---

## Anti-Patterns

### Don't Parallelize When:
- [ ] Tasks share the same files (conflict risk)
- [ ] Tasks have dependencies (ordering matters)
- [ ] Tasks are trivial (overhead > benefit)
- [ ] Resource constraints exist (cost/speed)

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#anti-patterns

---

## Verification Checklist

After parallel execution:
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
| One agent failed, others succeeded | Re-run only failed agent |
| Integration tests fail | Check missed integration points |
| Token costs too high | Reduce parallelization, use Haiku more |

**Full Details**: See @.claude/guides/parallel-execution-REFERENCE.md#troubleshooting

---

## Examples Summary

### Example 1: Simple Feature (Sequential)
```
Plan: Add simple utility function
→ Single Coder agent (no parallelization needed)
```

### Example 2: Medium Feature (Some Parallel)
```
Plan: Add auth + logout
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3 (different files)
→ Sequential: Integration
```

### Example 3: Complex Feature (Full Parallel)
```
Plan: Payment system integration
→ Parallel: Coder-SC1, Coder-SC2, Coder-SC3, Coder-SC4
→ Parallel: Tester, Validator, Code-Reviewer
→ Sequential: Integration, docs
```

**Full Examples**: See @.claude/guides/parallel-execution-REFERENCE.md#examples

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Gap Detection**: @.claude/guides/gap-detection.md
- **Review Checklist**: @.claude/guides/review-checklist.md

---

**Version**: 1.0.0
**Last Updated**: 2026-01-17
