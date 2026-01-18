# Review Checklist Guide

> **Purpose**: Comprehensive plan review checklist
> **Full Reference**: @.claude/guides/review-checklist-REFERENCE.md
> **Last Updated**: 2026-01-19

---

## Review Structure

| Category | Count | Activation |
|----------|-------|------------|
| **Mandatory** | 8 items | Always run |
| **Extended** | 8 items (A-H) | Activated by keywords |
| **Gap Detection** | 7 items | BLOCKING when triggered |

---

## Mandatory Reviews (8 Items)

Execute all 8 reviews for every plan.

**Review 1: Development Principles**
- SOLID: Single responsibility violations?
- DRY: Duplicate logic potential?
- KISS: Unnecessary complexity?
- YAGNI: Features not currently needed?

**Review 2: Project Structure**
- File locations: Correct locations?
- Naming: Follows conventions?
- Patterns: Matches existing code?

**Review 3: Requirements**
- Explicit: All requirements reflected?
- Implicit: Error handling, loading states considered?

**Review 4: Logic Errors**
- Order: Implementation order correct?
- Dependencies: Ready at point of use?
- Edge cases: Null, empty, failure considered?
- Async: Async handling correct?

**Review 5: Code Reuse**
- Utils: Search utils/, hooks/, common/
- Domain: Check domain-related files

**Review 6: Better Alternatives**
- Simplicity, Scalability, Testability, Best practices?

**Review 7: Project Alignment**
- Type check possible?
- API docs checked?
- Affected areas identified?

**Review 8: Long-term Impact**
- Consequences, Debt, Scalability, Rollback?

**Full details**: @.claude/guides/review-checklist-REFERENCE.md

---

## Extended Reviews (A-H)

### Activation Matrix

| Type | Keywords | Reviews |
|------|----------|---------|
| **Code Mod** | function, API, refactor | A (API), B (Types), D (Tests) |
| **Docs** | CLAUDE.md, README, guide | C (Consistency) |
| **Scenario** | test, validation, scenario | H (Coverage) |
| **Infra** | Docker, env, deploy, CI/CD | F (Deployment) |
| **DB** | migration, table, column | E (Migration) |
| **AI** | GPT, Claude, prompts, LLM | G (Prompts) |

**Full details**: @.claude/guides/review-checklist-REFERENCE.md

---

## Severity Levels

| Level | Symbol | Action |
|-------|--------|--------|
| **BLOCKING** | 🛑 | Cannot proceed (Interactive Recovery) |
| **Critical** | 🚨 | Must fix before execution |
| **Warning** | ⚠️ | Advisory, recommended |
| **Suggestion** | 💡 | Optional improvements |

---

## Quick Reference

```
Code Mod → A (API) + B (Types) + D (Tests)
Docs     → C (Consistency)
Scenario → H (Coverage)
Infra    → F (Deployment)
DB       → E (Migration)
AI       → G (Prompts)
```

---

## See Also

- **Gap Detection**: @.claude/guides/gap-detection.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **PRP Framework**: @.claude/guides/prp-framework.md

---

**Version**: claude-pilot 4.2.0 (Review Checklist)
**Last Updated**: 2026-01-19
