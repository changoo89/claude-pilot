# Instruction Clarity Guide

> **Purpose**: LLM instruction clarity for conditional logic
> **Full Reference**: @.claude/guides/instruction-clarity-REFERENCE.md
> **Last Updated**: 2026-01-19

---

## Problem

**Current Issue**: Double negatives ("DO NOT SKIP unless") confuse LLMs

**Research**: Positive framing reduces LLM error rate by 30-40%

---

## Solution: Default/Exception Pattern

```markdown
### Default Behavior
Always execute this step.

### Exception: --flag
Skip when --flag is provided.
```

---

## Transformation Rules

| Rule | Before (Bad) | After (Good) |
|------|--------------|--------------|
| **Default first** | `Do X (unless flag)` | `Default: Always do X. Exception: Skip when --flag` |
| **Positive framing** | `DO NOT SKIP` | `EXECUTE this step` |
| **Separate sections** | Mixed in one line | `Default` section + `Exception` section |

---

## Pattern Catalog

| Pattern | After (Good) |
|---------|--------------|
| Conditional execution | `Default: Execute. Exception: Skip when --flag provided` |
| Negative instruction | `Avoid X` or rewrite positively |
| Unless clause | `Exception: when [flag] provided` |
| Double negative | `Default: Execute. Exception: Skip when X` |

---

## Testing

```bash
# Check for "unless" pattern (should be minimized)
grep -c "unless" .claude/commands/*.md

# Verify "Default Behavior" sections exist
grep -c "### Default Behavior" .claude/commands/*.md
```

**Checklist**:
- Default behavior stated first (positive framing)
- Exception in separate section
- No "unless" in conditional logic (OK in explanatory text)
- No "DO NOT SKIP" pattern in conditionals

---

## Common Pitfalls

| Pattern | OK | NOT OK |
|---------|-----|--------|
| **"unless" in natural language** | Explanatory text | Conditional logic |
| **"DO NOT" warnings** | Phase boundaries | Conditional execution |
| **Complex negation** | N/A | Use Default/Exception pattern |

**Examples**:
- ✅ OK: "This process continues indefinitely unless interrupted by user"
- ❌ NOT OK: "Execute step unless flag provided"
- ✅ OK: "DO NOT start implementation during /00_plan"
- ❌ NOT OK: "DO NOT SKIP this step (unless flag)"

---

## Quick Reference

**PATTERN**: Conditional Execution
```
BEFORE (Bad): DO NOT SKIP (unless --flag specified)
AFTER (Good):  Default: Always execute. Exception: Skip when --flag
```

**KEY RULES**:
1. Default behavior first (positive framing)
2. Exception in separate section
3. No "unless" in conditional logic
4. No "DO NOT SKIP" pattern in conditionals

---

## Related Guides

- **PRP Framework**: @.claude/guides/prp-framework.md
- **3-Tier Documentation**: @.claude/guides/3tier-documentation.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

## Full Reference

**Detailed examples, bash code, verification**: @.claude/guides/instruction-clarity-REFERENCE.md

---

**Version**: claude-pilot 4.2.0 (Instruction Clarity)
**Last Updated**: 2026-01-19
