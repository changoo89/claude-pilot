# Parallel Execution Guide

> **Purpose**: Parallel agent execution for workflow efficiency
> **Full Reference**: @.claude/guides/parallel-execution-REFERENCE.md
> **Last Updated**: 2026-01-19

---

## Quick Reference

| Pattern | Agents | Purpose |
|---------|--------|---------|
| **Parallel Exploration** | Explorer + Researcher | Codebase + external docs |
| **Parallel Coder** | Multiple Coders | Independent SCs |
| **Parallel Verify** | Tester + Validator + Code-Reviewer | Multi-angle verification |
| **Parallel Review** | Multiple Plan-Reviewers | Complex plan analysis |

**Benefits**: 50-70% faster, 8x token efficiency, specialized agents

---

## Model Allocation

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient |
| **Sonnet** | coder, tester, plan-reviewer | Quality + speed balance |
| **Opus** | code-reviewer | Deep reasoning |

---

## Parallel Patterns

### Pattern 1: Parallel Exploration (`/00_plan`)

**Use**: Explore codebase + research docs concurrently

**Architecture**: Explorer + Researcher → Result merge

**Full details**: @.claude/guides/parallel-execution-REFERENCE.md#pattern-1

### Pattern 2: Parallel SC Implementation (`/02_execute`)

**Use**: Execute independent SCs concurrently

**Architecture**: Coders (parallel) → Integration → Verification (parallel)

**Requirements**: File isolation, SC dependency analysis, result merge

**Full details**: @.claude/guides/parallel-execution-REFERENCE.md#pattern-2

### Pattern 3: Parallel Review (`/90_review`)

**Use**: Multi-angle plan review

**When to use**: Large plans, high-stakes features, system-wide changes

**When NOT to use**: Small changes, resource constraints, time-sensitive reviews

**Full details**: @.claude/guides/parallel-execution-REFERENCE.md#pattern-3

---

## Task Tool Syntax

**Basic invocation**:
```markdown
Task:
  subagent_type: {agent_name}
  prompt: {task_description}
```

**Parallel invocation**: Send multiple Task calls in same message

**Agent names** (case-sensitive): `explorer`, `researcher`, `coder`, `tester`, `validator`, `plan-reviewer`, `code-reviewer`, `documenter`

---

## Best Practices

1. **Dependency Analysis**: File/SC dependencies before parallel execution
2. **File Conflict Prevention**: Each agent works on different files
3. **Result Integration**: Wait for all agents, merge in order, run integration tests
4. **Error Handling**: Process inline results (NOT TaskOutput), use `AskUserQuestion` for recovery
5. **Resource Management**: Use Haiku for cost-sensitive, Opus for critical review

**Full details**: @.claude/guides/parallel-execution-REFERENCE.md#best-practices

---

## Todo Management

| Type | Rule | Example |
|------|------|---------|
| **Sequential** | One `in_progress` at a time | Single Coder for all SCs |
| **Parallel** | Multiple `in_progress` simultaneously | Multiple Coders for independent SCs |

---

## Anti-Patterns

Don't parallelize when:
- Tasks share same files (conflict risk)
- Tasks have dependencies (ordering matters)
- Tasks are trivial (overhead > benefit)
- Resource constraints exist

---

## Verification Checklist

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
| Conflicts | Run sequentially, reorganize file ownership |
| One agent failed | Re-run only failed agent |
| Integration tests fail | Check missed integration points |
| Token costs too high | Reduce parallelization, use Haiku more |

---

## Examples

| Complexity | Pattern |
|------------|----------|
| Simple feature | Single Coder (sequential) |
| Medium feature | Parallel Coders + Sequential integration |
| Complex feature | Parallel Coders + Parallel verification + Sequential integration |

**Full details**: @.claude/guides/parallel-execution-REFERENCE.md#examples

---

## Related Guides

- **TDD**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Gap Detection**: @.claude/guides/gap-detection.md
- **Review Checklist**: @.claude/guides/review-checklist.md

---

**Version**: 1.0.0 (Parallel Execution)
**Last Updated**: 2026-01-19
