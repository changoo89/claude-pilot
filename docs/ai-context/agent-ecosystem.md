# Agent Ecosystem

> **Last Updated**: 2026-01-18
> **Purpose**: Agent model mappings and parallel execution patterns

---

## Agent Model Mapping

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

---

## Parallel Execution Patterns

### Planning Phase

**Agents**: Explorer + Researcher (parallel)

- **Explorer**: Discovers context, finds relevant files
- **Researcher**: Deep dives into specific topics
- **Result**: Comprehensive understanding before planning

### Execution Phase

**Agents**: Parallel Coder agents per SC (independent SCs)

- Each Coder agent works on independent success criteria
- No file conflicts when SCs are properly scoped
- Synchronized integration after parallel phase

### Verification Phase

**Agents**: Tester + Validator + Code-Reviewer (parallel)

- **Tester**: Runs test suite, measures coverage
- **Validator**: Verifies all quality gates pass
- **Code-Reviewer**: Deep code review for issues

### Review Phase (Optional)

**Agents**: Multi-angle parallel review

- Frontend review, backend review, security review
- Each reviewer focuses on specific domain
- Synthesized findings for comprehensive review

---

## Agent Coordination

**Sequential Execution**:
- Single agent with `in_progress` status
- Mark todo as `completed` before moving to next
- Used for dependent SCs that must run sequentially

**Parallel Execution**:
- Multiple agents with `in_progress` status simultaneously
- Main orchestrator marks all parallel todos as `completed` together
- Used for independent SCs with no shared files

---

## Agent Selection Guide

**Use Haiku for**:
- Exploration and discovery tasks
- Research and documentation
- Validation and verification
- Cost-efficient, fast tasks

**Use Sonnet for**:
- Implementation and coding
- Testing and quality assurance
- Planning and review
- Balanced quality/speed tasks

**Use Opus for**:
- Deep code review
- Complex analysis
- Security reviews
- Tasks requiring maximum reasoning

---

## See Also

- **@.claude/guides/parallel-execution.md** - Parallel execution orchestration
- **@.claude/guides/parallel-execution-REFERENCE.md** - Detailed patterns
- **@.claude/guides/intelligent-delegation.md** - GPT delegation triggers
- **@.claude/agents/CONTEXT.md** - Agent-specific rules
- **@CLAUDE.md** - Project standards (Tier 1)
