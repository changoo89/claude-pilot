# Before Stateless Design

**Problem**: Missing iteration history leads to repeated failed attempts.

## Example Prompt (Current Problematic Pattern)

```markdown
TASK: Fix the jq syntax error.

EXPECTED OUTCOME: Working jq command

CONTEXT:
- File: marketplace.json
- Error: jq syntax error
```

## Issues Identified

### 1. No Iteration History
- **Problem**: No information about previous attempts
- **Impact**: GPT treats each call as fresh request
- **Result**: Repeats same failed solutions

### 2. No Previous Attempt Details
- **Problem**: Missing context about what was tried before
- **Impact**: GPT doesn't know what already failed
- **Result**: Wastes tokens on known failures

### 3. No Error Context
- **Problem**: Missing error messages from attempts
- **Impact**: GPT can't diagnose root cause
- **Result**: Suggests solutions that won't work

### 4. Violates Stateless Design
- **Problem**: Each delegation call is independent
- **Impact**: GPT has no memory of previous calls
- **Result**: Must include full history in every prompt

## Real-World Failure Example

**Iteration 1** (User's first attempt):
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq command

CONTEXT:
- File: marketplace.json
- Error: jq syntax error
"
```

**GPT Response** (Attempt 1):
```
Try this: jq '.plugins[] |= .version = "$VERSION"' marketplace.json
```

**User tests** → Fails with syntax error

**Iteration 2** (User's second attempt, SAME PROMPT):
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq command

CONTEXT:
- File: marketplace.json
- Error: jq syntax error
"
```

**GPT Response** (Attempt 2):
```
Try this: jq '.plugins[] |= .version = "$VERSION"' marketplace.json
```

**User tests** → Same syntax error again!

**Iteration 3** (User's third attempt, SAME PROMPT):
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq command

CONTEXT:
- File: marketplace.json
- Error: jq syntax error
"
```

**GPT Response** (Attempt 3):
```
Try this: jq '.plugins[] |= .version = "$VERSION"' marketplace.json
```

**User tests** → Same error three times!

## Root Cause Analysis

**Stateless Design Violation**:
- Each delegation call is independent
- GPT has no memory of previous attempts
- User didn't include iteration history in context

**Consequences**:
- GPT suggests identical solution each time
- User wastes tokens on repeated failures
- Frustration increases with each iteration
- Problem never gets solved

## Token Waste Calculation

**Without Iteration History**:
- Attempt 1: 1000 tokens (prompt + response)
- Attempt 2: 1000 tokens (same prompt, same response)
- Attempt 3: 1000 tokens (same prompt, same response)
- **Total: 3000 tokens** (0 progress)

**With Iteration History**:
- Single call: 1500 tokens (full history prompt + correct solution)
- **Total: 1500 tokens** (problem solved)

**Savings**: 1500 tokens (50% reduction)

## Key Learning

**Stateless design requires full context in every call**:
- Each delegation is independent (no memory)
- Must include all previous attempts in context
- Must include error messages from each attempt
- Must specify current iteration count

**See**: `after-stateless.md` for the corrected version.
