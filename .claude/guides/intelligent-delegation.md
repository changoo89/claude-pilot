# Intelligent Delegation Guide

> **Last Updated**: 2026-01-17
> **Version**: 4.1.0
> **Purpose**: Guide for intelligent, context-aware Codex delegation

---

## Overview

This guide explains the **Intelligent Delegation System**, which transforms rigid keyword-based delegation into context-aware, autonomous decision-making.

### Evolution: From Keywords to Heuristics

| Aspect | Old System (Keyword-Based) | New System (Intelligent) |
|--------|---------------------------|--------------------------|
| **Trigger detection** | `grep -qiE "(tradeoff\|design)"` | Heuristic evaluation (failure, ambiguity, complexity, risk) |
| **Decision-making** | Binary (match/no-match) | Confidence scoring (0.0-1.0) |
| **Escalation** | Immediate or never | Progressive (after 2nd failure) |
| **Agent autonomy** | Manual trigger only | Self-assessment with confidence |
| **Claude Code integration** | None | Description-based routing |

---

## Core Concepts

### 1. Three Trigger Types (Hybrid Approach)

The system uses **complementary trigger types**:

#### Explicit Triggers (Keyword-Based)
**Legacy pattern**: Direct keyword matching for backward compatibility
- User explicitly requests: "ask GPT", "review architecture"
- Detection: `grep -qiE "(ask GPT|consult GPT)"`

#### Semantic Triggers (Heuristic-Based)
**Intelligent pattern**: Context-aware heuristic evaluation
- Failure-based: `iteration_count >= 2` AND `<CODER_BLOCKED>`
- Ambiguity: Vague phrases, no success criteria
- Complexity: 10+ success criteria
- Risk: Auth/credential keywords

#### Description-Based Triggers (Claude Code Official)
**Official pattern**: Agent description semantic matching
- Claude Code reads agent YAML frontmatter
- Looks for "use proactively" phrase
- Delegates automatically when task matches description

### 2. Confidence Scoring

Agents self-assess using confidence scores:

**Scale**: 0.0 to 1.0
- **0.9-1.0**: High confidence - proceed autonomously
- **0.5-0.9**: Medium confidence - consider delegation
- **0.0-0.5**: Low confidence - MUST delegate

**Formula** (example for Coder):
```
confidence = base_confidence - (failure_penalty * 0.2) - (ambiguity_penalty * 0.3) - (complexity_penalty * 0.1)
```

### 3. Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure, not first

```
Attempt 1 → Fail → Retry with Claude
Attempt 2 → Fail → Delegate to GPT Architect
Attempt 3 → (via GPT) → Success
```

---

## Heuristic Framework

### Heuristic 1: Failure-Based Escalation

**Trigger**: Agent fails 2+ times on same task

**Detection**:
```bash
iteration_count=$(grep "Total Iterations:" coder_output.txt | awk '{print $3}')
grep -q "<CODER_BLOCKED>" agent_output.txt
```

**Action**: Delegate to Architect with:
- Iteration count
- Error messages from each attempt
- Current implementation state

### Heuristic 2: Ambiguity Detection

**Trigger**: Vague or unclear task description

**Detection**:
```bash
# User input patterns
grep -qiE "(unclear|ambiguous|not sure|maybe|TBD)"

# Plan completeness
[ $(grep -c "^SC-" plan.md) -eq 0 ]
```

**Ambiguity Score** (0.0-1.0):
- Base: 0.0
- +0.3 if vague phrases
- +0.3 if no success criteria
- +0.2 if no test plan
- +0.2 if multiple interpretations

**Threshold**: Score >= 0.5 → Delegate to Scope Analyst

### Heuristic 3: Complexity Assessment

**Trigger**: Task has many components or deep dependencies

**Detection**:
```bash
sc_count=$(grep -c "^SC-" plan.md)
dependency_depth=$(grep -c "## Phase" plan.md)
```

**Complexity Score** (0.0-1.0):
- Base: 0.0
- +0.1 per SC (max 0.5 at 5 SCs)
- +0.2 per dependency level (max 0.4)
- +0.1 if 10+ SCs (complex threshold)

**Thresholds**:
- Score >= 0.5 (5+ SCs) → Consider Architect
- Score >= 0.7 (10+ SCs) → MUST delegate to Architect

### Heuristic 4: Risk Evaluation

**Trigger**: Security-sensitive or high-blast-radius code

**Detection**:
```bash
# Keywords
grep -qiE "(auth|credential|password|token|security)"

# File paths
grep -qiE "(routes/auth|src/auth|lib/security)"
```

**Risk Score** (0.0-1.0):
- Base: 0.0
- +0.4 if auth/credential keywords
- +0.3 if security/vulnerability keywords
- +0.2 if modifying auth files
- +0.1 if destructive operations

**Threshold**: Score >= 0.4 → Delegate to Security Analyst

### Heuristic 5: Progress Stagnation

**Trigger**: No meaningful progress in N iterations

**Detection**:
```bash
ralph_iterations=$(grep "Total Iterations:" coder_output.txt | awk '{print $3}')
coverage_delta=$(echo "$coverage_before $coverage_after" | awk '{print $2-$1}')
```

**Indicators**:
- 7 Ralph Loop iterations (max)
- Coverage increase < 5% over 3+ iterations
- Same error recurring 3+ times

---

## Claude Code Official Patterns

### Description-Based Routing

**How it works**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase
4. When task matches, delegates automatically

**Example**:
```yaml
---
name: coder
description: Implementation agent using TDD. Use proactively for implementation tasks.
---
```

**Agents with "use proactively"**:
- **coder**: "Use proactively for implementation tasks"
- **plan-reviewer**: "Use proactively after plan creation"
- **code-reviewer**: "Use proactively after code changes"

### Long-Running Task Templates

**Initializer Pattern**: Templates for complex workflows

#### Feature List JSON
```json
{
  "features": [
    {
      "id": "SC-1",
      "name": "Feature Name",
      "status": "failing",
      "verification": "test -f path/to/file"
    }
  ]
}
```

#### Init Script
```bash
#!/bin/bash
# init.sh - Template for complex workflow initialization
TASK_NAME="{{TASK_NAME}}"
echo "Initializing: $TASK_NAME"
```

#### Progress File
```markdown
# Progress Tracking

## Progress

| ID | Feature | Status |
|----|---------|--------|
| SC-1 | Feature | ✅ Complete |
```

---

## Implementation Examples

### Example 1: Failure-Based Escalation

**Scenario**: Coder agent fails 3 times implementing authentication

**Ralph Loop iteration tracking**:
```
Iteration 1: Tests fail (5 passing, 3 failing)
Iteration 2: Tests fail (5 passing, 3 failing)
Iteration 3: Tests fail (5 passing, 3 failing)
```

**Confidence calculation**:
```
base_confidence = 0.8
failure_penalty = 3
ambiguity_penalty = 0.0
complexity_penalty = 0.3

confidence = 0.8 - (3 * 0.2) - (0.0 * 0.3) - (0.3 * 0.1)
           = 0.8 - 0.6 - 0.0 - 0.03
           = 0.17 < 0.5 → Delegate to Architect
```

**Output**:
```markdown
### Self-Assessment
- **Confidence**: 0.17 (Low) - Recommend delegation
- **Reasoning**:
  - 3 failed attempts at implementation
  - Medium complexity (3 SCs)
- **Action**: Delegate to Architect for fresh perspective
```

### Example 2: Ambiguity Detection

**Scenario**: User says "help me implement something unclear"

**Ambiguity calculation**:
```
Base: 0.0
+0.3: Vague phrase "help me implement something unclear"
+0.3: No success criteria in plan
+0.2: No test plan
+0.2: Multiple interpretations possible

Total: 1.0 >= 0.5 → Delegate to Scope Analyst
```

### Example 3: Complexity Assessment

**Scenario**: Plan with 12 success criteria

**Complexity calculation**:
```
Base: 0.0
+0.5: 5 SCs (max at threshold)
+0.4: 2 dependency levels (max)
+0.1: 12 SCs (complex threshold)

Total: 1.0 >= 0.7 → MUST delegate to Architect
```

---

## Best Practices

### 1. Cost Awareness

- **Don't spam**: One well-structured delegation beats multiple vague ones
- **Include full context**: Saves retry costs from missing information
- **Reserve for high-value tasks**: Architecture, security, complex analysis
- **Progressive escalation**: Try Claude first, delegate after 2nd failure

### 2. Graceful Fallback

**MANDATORY**: All GPT delegation points MUST include graceful fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0  # Continue with Claude
fi
```

### 3. Backward Compatibility

**Maintain existing keyword triggers**:
- Explicit user requests still work: "ask GPT", "review architecture"
- Add heuristic triggers alongside keyword triggers
- Don't break existing workflows

### 4. Confidence Thresholds

**Set appropriate thresholds**:
- **0.5**: Default delegation threshold (balance autonomy vs delegation)
- **0.7**: High stakes threshold (architecture, security)
- **0.3**: Low stakes threshold (simple refactors)

---

## Verification

### Test Coverage

Run test suite:
```bash
bash .pilot/tests/test_delegation.test.sh
```

**Expected**: 11/11 tests passing

### Manual Verification

**Check agent descriptions**:
```bash
grep -r "use proactively" .claude/agents/*.md
```

**Expected**: 3 matches (coder, plan-reviewer, code-reviewer)

**Check templates exist**:
```bash
ls -la .claude/templates/
```

**Expected**: feature-list.json, init.sh, progress.md

**Check heuristic documentation**:
```bash
ls -la .claude/rules/delegator/intelligent-triggers.md
```

**Expected**: File exists with heuristic patterns

---

## Related Documentation

- **Intelligent Triggers**: @.claude/rules/delegator/intelligent-triggers.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md
- **Pattern Standard**: @.claude/rules/delegator/pattern-standard.md

---

## Troubleshooting

### Problem: Delegation not triggering

**Check**:
1. Agent description has "use proactively" phrase
2. Heuristic thresholds are met
3. Graceful fallback is not masking delegation

### Problem: Too many delegations

**Check**:
1. Confidence thresholds are appropriate
2. Progressive escalation is implemented (not delegating on first failure)
3. Heuristic scores are calculated correctly

### Problem: Tests failing

**Check**:
1. Templates exist in `.claude/templates/`
2. Agent descriptions are updated
3. Heuristic documentation is complete

---

**Version**: claude-pilot 4.1.0 (Intelligent Delegation)
**Last Updated**: 2026-01-17
