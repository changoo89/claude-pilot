# Intelligent Delegation Triggers

> **Last Updated**: 2026-01-17
> **Purpose**: Heuristic-based autonomous delegation decision-making
> **Status**: Active Standard

---

## Overview

This document defines **heuristic evaluation patterns** for intelligent Codex delegation. Unlike rigid keyword matching, heuristics enable context-aware, autonomous decision-making based on task complexity, ambiguity, risk, and progress.

## Philosophy

**From Keyword-Based to Heuristic-Based**:
- **Old**: `grep -qiE "(tradeoff|design|architecture)"` → rigid pattern matching
- **New**: Evaluate context (failures, ambiguity, complexity, risk) → intelligent decision

**Key Principles**:
1. **Context-Aware**: Consider task state, not just keywords
2. **Progressive Escalation**: Delegate only after retries fail
3. **Cost-Conscious**: Avoid unnecessary Codex calls
4. **Graceful Fallback**: Continue with Claude if Codex unavailable

---

## Heuristic Framework

### 1. Failure-Based Escalation

**Trigger**: Agent fails 2+ times on same task

**Detection**:
```bash
# Track Ralph Loop iterations
iteration_count=$(grep "Total Iterations:" coder_output.txt | awk '{print $3}')

# Check for blocked marker
grep -q "<CODER_BLOCKED>" agent_output.txt
```

**Heuristic Logic**:
- If `iteration_count >= 2` AND `<CODER_BLOCKED>` present → Delegate to Architect
- If `iteration_count < 2` → Continue with Claude (progressive escalation)

**Action**: Delegate to Architect with context:
- What was attempted (iteration count)
- Error messages from each attempt
- Current implementation state

**Verification**:
```bash
grep -q "<CODER_BLOCKED>" agent_output.txt && [ $iteration_count -ge 2 ]
```

---

### 2. Ambiguity Detection

**Trigger**: Vague or unclear task description

**Detection Patterns** (grep -qiE):
```bash
# User input patterns
(unclear|ambiguous|not sure|maybe|TBD|help me with|figure out)

# Plan completeness
[ $(grep -c "^SC-" plan.md) -eq 0 ]  # No success criteria
! grep -q "## Test Plan" plan.md      # No test plan
```

**Ambiguity Score** (0.0-1.0):
- Base: 0.0
- +0.3 if vague phrases in user input
- +0.3 if no success criteria
- +0.2 if no test plan
- +0.2 if multiple valid interpretations exist

**Threshold**: Score >= 0.5 → Delegate to Scope Analyst

**Action**: Delegate to Scope Analyst with:
- Original user input (verbatim)
- Ambiguity score calculation
- Specific questions to clarify

**Verification**:
```bash
echo "$USER_INPUT" | grep -qiE "(unclear|ambiguous|not sure|maybe|help me)"
[ $(grep -c "^SC-" plan.md) -eq 0 ]
```

---

### 3. Complexity Assessment

**Trigger**: Task has many components or deep dependencies

**Detection**:
```bash
sc_count=$(grep -c "^SC-" plan.md)
dependency_depth=$(grep -c "## Phase" plan.md)
```

**Complexity Score** (0.0-1.0):
- Base: 0.0
- +0.1 per SC (max 0.5 at 5 SCs)
- +0.2 per dependency level (max 0.4 at 2+ levels)
- +0.1 if 10+ SCs (complex threshold)

**Thresholds**:
- Score >= 0.5 (5+ SCs) → Consider Architect delegation
- Score >= 0.7 (10+ SCs) → MUST delegate to Architect

**Action**: Delegate to Architect with:
- Success criteria list
- Dependency graph (phases)
- Specific architectural questions

**Verification**:
```bash
sc_count=$(grep -c "^SC-" plan.md)
[ $sc_count -ge 10 ] && echo "Complex: Delegate to Architect"
```

---

### 4. Risk Evaluation

**Trigger**: Security-sensitive or high-blast-radius code

**Detection Patterns** (grep -qiE):
```bash
# User input keywords
(auth|credential|password|token|vulnerability|security|encrypt|decrypt)

# File path patterns
(routes/auth|src/auth|lib/security|services/login|handlers/token)

# Destructive operations
(delete_all|drop_table|truncate|rm -rf)
```

**Risk Score** (0.0-1.0):
- Base: 0.0
- +0.4 if auth/credential keywords
- +0.3 if security/vulnerability keywords
- +0.2 if modifying auth-related files
- +0.1 if destructive operations (delete, drop, truncate)

**Threshold**: Score >= 0.4 → Delegate to Security Analyst

**Action**: Delegate to Security Analyst with:
- Risk score calculation
- Specific security concerns
- Code snippets/files for review

**Verification**:
```bash
echo "$USER_INPUT" | grep -qiE "(auth|credential|password|token|security)"
echo "$MODIFIED_FILES" | grep -qiE "(routes/auth|src/auth|lib/security)"
```

---

### 5. Progress Stagnation

**Trigger**: No meaningful progress in N iterations

**Detection**:
```bash
ralph_iterations=$(grep "Total Iterations:" coder_output.txt | awk '{print $3}')
coverage_delta=$(echo "$coverage_before $coverage_after" | awk '{print $2-$1}')
```

**Stagnation Indicators**:
- 7 Ralph Loop iterations reached (max)
- Coverage increase < 5% over 3+ iterations
- Same error recurring 3+ times
- No tests passing after 3+ iterations

**Action**: Delegate to Architect with:
- Ralph Loop iteration count
- Coverage progression (each iteration)
- Recurring errors
- Current implementation state

**Verification**:
```bash
[ $ralph_iterations -ge 7 ]
[ $coverage_delta -lt 5 ] && [ $ralph_iterations -ge 3 ]
```

---

## Confidence Scoring System

**Scale**: 0.0 to 1.0
- **0.9-1.0**: High confidence - proceed autonomously
- **0.5-0.9**: Medium confidence - consider delegation
- **0.0-0.5**: Low confidence - MUST delegate

### Calculation (Example for Coder Agent)

**Formula**:
```
confidence = base_confidence - (failure_penalty * 0.2) - (ambiguity_penalty * 0.3) - (complexity_penalty * 0.1)
```

**Components**:
- **base_confidence**: 0.8 (initial confidence)
- **failure_penalty**: Number of failed Ralph Loop iterations (0-7)
- **ambiguity_penalty**: Ambiguity score from above (0.0-1.0)
- **complexity_penalty**: Complexity score from above (0.0-1.0)

**Example Calculation**:
```
# Scenario: 3 failed attempts, ambiguous task, medium complexity
base_confidence = 0.8
failure_penalty = 3 (3 iterations)
ambiguity_penalty = 0.6 (vague requirements, no test plan)
complexity_penalty = 0.4 (5 SCs)

confidence = 0.8 - (3 * 0.2) - (0.6 * 0.3) - (0.4 * 0.1)
           = 0.8 - 0.6 - 0.18 - 0.04
           = -0.02 → 0.0 (floor at 0.0)
```

**Thresholds**:
- If confidence < 0.5: Return `<CODER_BLOCKED>` with delegation recommendation
- If confidence >= 0.5: Continue with `<CODER_COMPLETE>` or proceed to next iteration

---

## Communication Format

Agents return confidence in summary:

```markdown
### Self-Assessment
- **Confidence**: 0.4 (Low) - Recommend delegation
- **Reasoning**:
  - 3 failed attempts at implementation
  - Ambiguous requirements (no success criteria)
  - Medium complexity (5 SCs)
- **Action**: Delegate to Architect for fresh perspective
```

---

## Progressive Escalation (CRITICAL)

**Principle**: Delegate ONLY after 2nd failure, not first

**Pattern**:
```
Attempt 1 → Fail → Retry with Claude
Attempt 2 → Fail → Delegate to GPT Architect
Attempt 3 → (via GPT) → Success
```

**Implementation**:
```bash
if [ $iteration_count -ge 2 ]; then
    # Delegate to GPT
    .claude/scripts/codex-sync.sh "workspace-write" "..."
else
    # Retry with Claude
    echo "Retrying with Claude (iteration $iteration_count)"
fi
```

---

## Description-Based Routing (Claude Code Official)

**How it works** (Claude Code official pattern):

Claude Code uses agent descriptions for **semantic task matching**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase as delegation signal
4. When task matches agent description, delegates automatically

**Implementation**:
1. Add "use proactively" to agent descriptions
2. Ensure descriptions clearly state when to use the agent
3. Use action verbs: "Implement", "Review", "Analyze", "Test"

**Example**:
```yaml
---
name: coder
description: Implementation agent using TDD. Use proactively for implementation tasks.
---
```

**Verification**:
- Agent description contains "use proactively"
- Description clearly states when to use the agent
- Description includes key capabilities (TDD, Ralph Loop)
- Task → Agent matching is obvious from description

---

## Graceful Fallback (CRITICAL)

**MANDATORY**: All GPT delegation points MUST include graceful fallback.

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

**Key Points**:
- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

---

## Cost Awareness

- **Don't spam** - One well-structured delegation beats multiple vague ones
- **Include full context** - Saves retry costs from missing information
- **Reserve for high-value tasks** - Architecture, security, complex analysis
- **Progressive escalation** - Try Claude first, delegate after 2nd failure

---

## Related Documentation

- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md
- **Pattern Standard**: @.claude/rules/delegator/pattern-standard.md

---

**Template Version**: claude-pilot 4.1.0 (Intelligent Delegation)
**Last Updated**: 2026-01-17
