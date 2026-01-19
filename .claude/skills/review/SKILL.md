# SKILL: Multi-Angle Code Review

> **Purpose**: Comprehensive plan review with gap detection, extended reviews, and GPT expert delegation
> **Target**: plan-reviewer Agent reviewing plans before execution

---

## Quick Start

### When to Use This Skill
- Review plan before execution (/01_confirm, /review)
- Detect gaps in external service integration
- Validate test plan completeness
- Apply findings to improve plan quality

### Quick Reference
```bash
# Load plan → Detect type → Run reviews → Apply findings
/review .pilot/plan/pending/plan.md
```

## What This Skill Covers

### In Scope
- 8 mandatory reviews (principles, structure, requirements, logic, reuse, alternatives, alignment, impact)
- Type-specific extended reviews (API, types, tests, docs, coverage, deployment, migration, prompts)
- Gap detection (external API, DB, async, file ops, env vars, error handling, test plan)
- Autonomous perspectives (security, performance, UX, maintainability, concurrency, error recovery)
- Findings application to plan

### Out of Scope
- Plan creation → @.claude/guides/prp-framework.md
- Test execution → @.claude/skills/tdd/SKILL.md
- GPT delegation → @.claude/rules/delegator/orchestration.md

## Core Concepts

### Review Workflow

**Step 0**: Load plan → Extract success criteria count
**Step 1**: Proactive investigation (search existing code/patterns)
**Step 2**: Type detection (code/config/docs/scenario/infra/db/ai)
**Step 3**: 8 mandatory reviews
**Step 5**: Extended reviews (type-activated)
**Step 6**: Autonomous perspectives (6 angles)
**Step 7**: Gap detection (BLOCKING triggers Interactive Recovery)
**Step 9**: Apply findings to plan
**Step 9.5**: Parallel multi-angle review (5+ SCs)
**Step 10**: GPT expert review (optional)

### Gap Detection Severity Levels

| Level | Symbol | Action |
|-------|--------|--------|
| **BLOCKING** | 🛑 | Interactive Recovery |
| **Critical** | 🚨 | Must fix |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

### Test Plan Verification (BLOCKING)

For code/scenario/infra/db/ai types:
- Test file path: **Required**
- Test scenarios: **Required**
- Coverage command: **Required**

For config/documentation types:
- Test file path: **Optional** (N/A allowed)

### Parallel Multi-Angle Review

**Trigger**: 5+ SCs, high-stakes features, system-wide changes

**Implementation**: Invoke 3 plan-reviewer agents concurrently (security, quality, architecture angles)

**Cost**: 3x token cost - use only for complex plans

## Further Reading

**Internal**: @.claude/skills/review/REFERENCE.md - Detailed review criteria, gap detection, GPT delegation | @.claude/guides/review-checklist.md - Full review checklist | @.claude/guides/gap-detection.md - External service integration gaps | @.claude/rules/delegator/orchestration.md - GPT expert delegation

**External**: [Code Review by Jason Cohen](https://blog.smartbear.com/code-review/best-practices-for-code-review/) | [The Art of Readable Code](https://www.amazon.com/Art-Readable-Code-Simple/dp/1593272740)
