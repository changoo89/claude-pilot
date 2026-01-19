# GPT Delegation Pattern Standard

> **Last Updated**: 2025-01-17
> **Purpose**: Standardize GPT delegation pattern across all commands
> **Status**: Active Standard

---

## Overview

This document defines the standard pattern for GPT delegation across all claude-pilot commands. It ensures consistent trigger detection, graceful fallback, and unified orchestration.

## Pattern Components

### 1. Trigger Detection Table

> **Note**: Detection methods are conceptual patterns for Claude agents to follow, not executable shell commands.

| Command | Trigger Pattern | Detection Method | GPT Expert | Mode |
|---------|----------------|------------------|------------|------|
| `/00_plan` | Regex: `(tradeoff|design|structure|architecture)` | `grep -qiE` on user input | Architect | Advisory |
| `/01_confirm` | Count: `$(grep -c "^SC-" plan.md) -ge 5` | Count SC items | Plan Reviewer | Advisory |
| `/02_execute` | Marker: `<CODER_BLOCKED>` | Coder agent output | Architect | Implementation |
| `/review` | Count: `$(grep -c "^SC-" plan.md) -ge 5` | Count SC items | Plan Reviewer | Advisory |
| `/document` | Files: `$(find . -name "CONTEXT.md" | wc -l) -ge 3` | Count affected components | Architect | Advisory |
| `/03_close` | Explicit: `grep -qi "review\|validate\|audit"` | User input keywords | Plan Reviewer | Advisory |
| `/999_publish` | Keywords: `grep -qiE "security|auth|credential"` | User input keywords | Security Analyst | Advisory |

### 2. Trigger Detection Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Command Execution                       │
│                  (00_plan, 01_confirm, etc.)                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
              ┌──────────────────────────────┐
              │  GPT Delegation Trigger Check │
              │      (MANDATORY Step)         │
              └──────────────────────────────┘
                           │
                           ├─► Trigger detected?
                           │       │
                           │       ├─► YES: Check Codex CLI
                           │       │       │
                           │       │       ├─► Installed: Delegate to GPT
                           │       │       │
                           │       │       └─► Not installed: Graceful fallback
                           │       │
                           │       └─► NO: Continue with Claude agents
                           │
                           ▼
              ┌──────────────────────────────┐
              │      Claude Agent Execution   │
              │   (plan-reviewer, coder, etc.) │
              └──────────────────────────────┘
```

### 3. Graceful Fallback Pattern

**MANDATORY**: All GPT delegation points MUST include graceful fallback.

```bash
# Check if Codex CLI is installed
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

> **Note**: This is bash code/pseudocode to be used in actual bash function calls. Commands are markdown files that guide Claude agents; the `return 0` applies when implementing shell functions/scripts that call `codex-sync.sh`.

**Key Points**:
- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

### 4. Delegation Execution Pattern

**Standard Delegation Call**:

```bash
# Read expert prompt
EXPERT_PROMPT="$(cat .claude/rules/delegator/prompts/[expert].md)"

# Build delegation prompt with 7-section format
DELEGATION_PROMPT="${EXPERT_PROMPT}

TASK: [One sentence atomic goal]

EXPECTED OUTCOME: [What success looks like]

CONTEXT:
- Current state: [what exists now]
- Relevant code: [paths or snippets]
- Background: [why this is needed]

CONSTRAINTS:
- Technical: [versions, dependencies]
- Patterns: [existing conventions]
- Limitations: [what cannot change]

MUST DO:
- [Requirement 1]
- [Requirement 2]

MUST NOT DO:
- [Forbidden action 1]
- [Forbidden action 2]

OUTPUT FORMAT:
- [How to structure response]"

# Call codex-sync.sh with appropriate mode
MODE="read-only"  # or "workspace-write"
.claude/scripts/codex-sync.sh "$MODE" "$DELEGATION_PROMPT"
```

### 5. Reasoning Effort Configuration

**Default**: `medium` (balanced speed/quality)

**Override**:
```bash
# Set for current session
export CODEX_REASONING_EFFORT="medium"

# Set for single command
CODEX_REASONING_EFFORT="low" .claude/scripts/codex-sync.sh ...

# Set permanently (add to ~/.zshrc or ~/.bashrc)
echo 'export CODEX_REASONING_EFFORT="medium"' >> ~/.zshrc
```

**Available Levels**:
- `low`: Fast response (~30s), good for simple questions
- `medium`: Balanced (~1-2min), default for most tasks
- `high`: Deep analysis (~3-5min), for complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough but slowest

### 6. Command Template: GPT Delegation Trigger Check

**Copy this template into each command**:

```markdown
## Step X.X: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| [Trigger 1] | [Signal description] | Delegate to [Expert] |
| [Trigger 2] | [Signal description] | Delegate to [Expert] |

### Delegation Flow

1. **STOP**: Scan input for trigger signals
2. **MATCH**: Identify expert type from triggers
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/`
4. **CHECK**: Verify Codex CLI is installed (graceful fallback if not)
5. **EXECUTE**: Call `codex-sync.sh` or continue with Claude agents
6. **CONFIRM**: Log delegation decision

### Graceful Fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

```

## Implementation Checklist

For each command (`/00_plan`, `/01_confirm`, `/document`, `/03_close`, `/999_publish`):

- [ ] Add "GPT Delegation Trigger Check (MANDATORY)" section
- [ ] Define trigger patterns in table
- [ ] Include delegation flow (6 steps)
- [ ] Include graceful fallback code block
- [ ] Link to `@.claude/rules/delegator/triggers.md`
- [ ] Specify expert type and mode (Advisory/Implementation)

## Verification

**Verify command has GPT delegation**:
```bash
grep -q "GPT Delegation Trigger Check" .claude/commands/[command].md
```

**Verify graceful fallback**:
```bash
grep -A3 "command -v codex" .claude/commands/[command].md | grep -q "return 0"
```

**Verify all commands updated**:
```bash
grep -r "GPT Delegation Trigger Check" .claude/commands/*.md | wc -l
# Expected: 5 or more (00_plan, 01_confirm, 91_document, 03_close, 999_publish, plus any future commands)
```

---

**Related Documentation**:
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md
- **Codex Script**: @.claude/scripts/codex-sync.sh

**Template Version**: claude-pilot 4.0.5
