# Instruction Clarity Guide

> **Purpose**: Ensure LLMs can reliably understand conditional logic without misinterpretation
> **Target**: Command file authors, `.claude/commands/*.md` maintainers
> **Last Updated**: 2026-01-16

---

## Problem Statement

### Current Issue: Confusing Negative Patterns

```markdown
# Current (Confusing Pattern)
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**Why This Fails**:
- **Double negative**: "DO NOT SKIP unless" = confusing logic
- **LLM cannot determine**: "Should I execute or skip?"
- **Default behavior and exception mixed in one sentence**
- **Negation processing**: LLMs struggle with negation, especially with "unless" clauses

### Research Findings

| Source | Key Insight |
|--------|-------------|
| [Why Positive Prompts Outperform Negative Ones](https://gadlet.com/posts/negative-prompting/) | Positive framing reduces LLM error rate by 30-40% |
| [LLMs Don't Understand Negation - HackerNoon](https://hackernoon.com/llms-dont-understand-negation) | Negation requires 2x more tokens to process correctly |
| [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) | "State what to do, not what not to do" |

---

## Solution: Default Behavior Declaration Pattern

### Improved Pattern

```markdown
# Improved (Clear Pattern)
### Default Behavior
Always invoke Documenter Agent after plan completion.

### Exception: --no-docs flag
Skip documentation step only when `--no-docs` flag is explicitly provided.
```

**Benefits**:
- **Default behavior stated first** (positive framing)
- **Exception in separate section** with explicit condition
- **Flag name and action match intuitively**
- **No negation processing required**

---

## Transformation Rules

### Rule 1: Default Behavior First

**Before** (Bad):
```markdown
Do X (unless flag specified)
```

**After** (Good):
```markdown
### Default Behavior
Always do X.

### Exception: --flag
Skip X when --flag is provided.
```

### Rule 2: Positive Framing

**Before** (Bad):
```markdown
DO NOT SKIP this step
```

**After** (Good):
```markdown
EXECUTE this step
```

### Rule 3: Separate Sections

**Before** (Bad):
```markdown
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**After** (Good):
```markdown
### Default Behavior
Always execute this step.

### Exception: --no-docs flag
Skip when --no-docs flag is explicitly provided.
```

---

## Examples

### Example 1: 03_close.md Step 5 (Documenter Agent)

**Before** (Current):
```markdown
## Step 5: Delegate to Documenter Agent (Context Isolation)

### MANDATORY ACTION: Documenter Agent Invocation

**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**After** (Proposed):
```markdown
## Step 5: Documenter Agent (Context Isolation)

### Default Behavior
Always invoke Documenter Agent after plan completion.

### MANDATORY ACTION: Documenter Agent Invocation

**EXECUTE IMMEDIATELY**:
[Task call content...]

### Exception: --no-docs flag
When `--no-docs` flag is provided, skip this step entirely.
Note in commit message: "Documentation skipped (--no-docs)"
```

### Example 2: 03_close.md Step 7 (Git Commit)

**Before** (Current):
```markdown
## Step 7: Git Commit (Default)

> **Skip only if `no-commit` specified - commit is default behavior**
```

**After** (Proposed):
```markdown
## Step 7: Git Commit

### Default Behavior
Always create git commit after closing plan.

### Exception: no-commit flag
Skip commit only when `no-commit` argument is explicitly provided.
```

### Example 3: MANDATORY ACTION Sections

**Before** (Current):
```markdown
**EXECUTE IMMEDIATELY - DO NOT SKIP**:
```

**After** (Proposed):
```markdown
### Default Behavior
This step is mandatory for all plans.

**EXECUTE IMMEDIATELY**:
```

---

## Pattern Catalog

| Pattern | Before (Bad) | After (Good) |
|---------|--------------|--------------|
| **Conditional execution** | `Skip only if X` | `Default: Execute. Skip when X flag provided` |
| **Negative instruction** | `Don't do X` | `Avoid X` or rewrite positively |
| **Unless clause** | `unless specified` | `Exception: when [flag] provided` |
| **Double negative** | `DO NOT SKIP (unless X)` | `Default: Execute. Exception: Skip when X` |

---

## Testing & Verification

### Automated Checks

```bash
# Check for "unless" pattern (should be minimized)
grep -c "unless" .claude/commands/*.md

# Check for "DO NOT SKIP.*unless" pattern (should be eliminated)
grep "DO NOT SKIP.*unless" .claude/commands/*.md

# Verify "Default Behavior" sections exist
grep -c "### Default Behavior" .claude/commands/*.md
```

### Manual Review Checklist

For each conditional section:
- [ ] Default behavior stated first (positive framing)
- [ ] Exception in separate "Exception: --flag" section
- [ ] No "unless" in conditional logic (OK in explanatory text)
- [ ] No "DO NOT SKIP" pattern
- [ ] Flag name and action match intuitively

---

## Common Pitfalls

### Pitfall 1: "unless" in Natural Language

**OK**: "This process continues indefinitely unless interrupted by user"
**Reason**: Explanatory text, not conditional logic

**NOT OK**: "Execute step unless flag provided"
**Reason**: Conditional logic, use Default/Exception pattern

### Pitfall 2: Necessary "DO NOT" Warnings

**OK**: "DO NOT start implementation during /00_plan"
**Reason**: Phase boundary protection (not conditional execution)

**NOT OK**: "DO NOT SKIP this step (unless flag)"
**Reason**: Conditional execution, use positive framing

### Pitfall 3: Complex Negation Chains

**Before**: "Don't forget to not skip unless you have the flag"
**After**: "Default: Execute step. Exception: Skip when --skip flag provided"

---

## Quick Reference Card

```
PATTERN: Conditional Execution
┌─────────────────────────────────────────┐
│ BEFORE (Bad):                           │
│ DO NOT SKIP (unless --flag specified)   │
├─────────────────────────────────────────┤
│ AFTER (Good):                           │
│ ### Default Behavior                    │
│ Always execute this step.               │
│                                         │
│ ### Exception: --flag                   │
│ Skip when --flag is provided.           │
└─────────────────────────────────────────┘

KEY RULES:
1. Default behavior first (positive framing)
2. Exception in separate section
3. No "unless" in conditional logic
4. No "DO NOT SKIP" pattern
5. Flag name and action match intuitively
```

---

## Related Guides

- **PRP Framework**: @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- **3-Tier Documentation**: @.claude/guides/3tier-documentation.md - Documentation system
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md - Code quality standards

---

## References

- [Prompting best practices - Claude Docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Why Positive Prompts Outperform Negative Ones](https://gadlet.com/posts/negative-prompting/)
- [LLMs Don't Understand Negation - HackerNoon](https://hackernoon.com/llms-dont-understand-negation)
