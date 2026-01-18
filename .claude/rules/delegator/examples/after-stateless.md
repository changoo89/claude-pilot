# After Stateless Design

**Solution**: Full iteration history included in every delegation call.

## Example Prompt (Improved Pattern)

```markdown
TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq command that updates plugin versions

CONTEXT:
- File: marketplace.json
- Current content: (shows JSON structure)
- Error: jq syntax error

PREVIOUS ATTEMPTS:
- **Attempt 1**: Tried `jq '.plugins[] |= .version = "$VERSION"' marketplace.json`
  - Error: `jq: syntax error, unexpected INVALID_CHARACTER`
  - Issue: Dollar sign needs escaping or different approach
  
- **Attempt 2**: Tried `jq '.plugins[] |= .version = "'"$VERSION"'"' marketplace.json`
  - Error: `jq: syntax error, unexpected $end`
  - Issue: Shell variable expansion inside single quotes
  
- **Attempt 3**: Tried `jq --arg v "$VERSION" '.plugins[] |= .version = $v' marketplace.json`
  - Error: `jq: error: $v is not defined`
  - Issue: Variable scope in jq update assignment

REQUIREMENTS:
- Fix the jq syntax error from previous attempts
- Update all plugin versions to $VERSION environment variable
- Command must work in bash shell
- Report all files modified
```

## Improvements

### 1. Full Iteration History
- **Added**: "PREVIOUS ATTEMPTS" section with 3 attempts
- **Benefit**: GPT sees what failed before
- **Result**: Avoids repeating same mistakes

### 2. Detailed Error Context
- **Added**: Exact error messages from each attempt
- **Benefit**: GPT can diagnose root cause
- **Result**: Targeted solutions, not guesses

### 3. Analysis of Why Each Attempt Failed
- **Added**: "Issue:" field explaining the problem
- **Benefit**: GPT understands the nature of failures
- **Result**: Solutions that address actual issues

### 4. Current State Information
- **Added**: Current file content
- **Benefit**: GPT knows what we're working with
- **Result**: Accurate solutions for actual data

### 5. Clear Requirements
- **Added**: "REQUIREMENTS" section
- **Benefit**: GPT knows success criteria
- **Result**: Solutions that meet actual needs

## Real-World Success Example

**Single call with full history**:
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq command that updates plugin versions

CONTEXT:
- File: .claude-plugin/marketplace.json
- Goal: Update all plugin versions to $VERSION

PREVIOUS ATTEMPTS:
- **Attempt 1**: `jq '.plugins[] |= .version = \"$VERSION\"' marketplace.json`
  - Error: `jq: syntax error, unexpected INVALID_CHARACTER`
  - Issue: Dollar sign interpreted as jq variable, not shell variable
  
- **Attempt 2**: `jq '.plugins[] |= .version = \"'\"$VERSION\"'\"' marketplace.json`
  - Error: `jq: syntax error, unexpected $end`
  - Issue: Quote escaping confusion
  
- **Attempt 3**: `jq --arg v \"$VERSION\" '.plugins[] |= .version = $v' marketplace.json`
  - Error: `jq: error: $v is not defined at <top-level>`
  - Issue: Variable scoping in update assignment context

REQUIREMENTS:
- Fix the jq syntax for updating all plugin versions
- Use environment variable $VERSION
- Command must work in bash shell
- Preserve JSON structure
"
```

**GPT Response** (with full history):
```
The issue is that `--arg` variables don't work directly in update assignment
contexts. You need to use a different approach:

**Solution**:
```bash
VERSION="1.2.3" jq '.plugins[].version = env.VERSION' marketplace.json
```

**Why this works**:
- `env.VERSION` accesses environment variables directly in jq
- No shell variable expansion needed
- Works in update assignment context
- Preserves JSON structure

**Files modified**:
- marketplace.json (all plugin versions updated)
```

**User tests** → Success on first try with full history!

## Comparison Table

| Aspect | Before | After |
|--------|--------|-------|
| **Iteration History** | None | All attempts documented |
| **Error Context** | Generic error | Exact error messages |
| **Failure Analysis** | None | "Issue:" explains why |
| **Current State** | Assumed | Shown explicitly |
| **Attempts to Success** | 3+ failures | 1 success |
| **Token Usage** | 3000+ (repeated) | 1500 (single call) |

## Retry Flow Pattern

### Standard Retry Template

```markdown
TASK: [Original task]

PREVIOUS ATTEMPTS:
- **Attempt [N]**: [What was tried]
  - Error: [Exact error message]
  - Issue: [Why it failed]

- **Attempt [N+1]**: [What was tried]
  - Error: [Exact error message]
  - Issue: [Why it failed]

CONTEXT:
- [Full original context]

REQUIREMENTS:
- Fix the error from the previous attempts
- [Original requirements]
```

### Progressive Escalation Example

**Attempt 1-2**: Use Claude (local retry)
```bash
# No delegation yet, just retry with Claude
echo "Retrying with different approach..."
```

**Attempt 3+**: Delegate to GPT Architect with full history
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a software architect...

TASK: Fix the authentication flow issue

PREVIOUS ATTEMPTS:
- **Attempt 1 (Claude)**: Added JWT validation middleware
  - Error: `TypeError: Cannot read property 'token' of undefined`
  - Issue: Middleware runs before body parser
  
- **Attempt 2 (Claude)**: Moved middleware after body parser
  - Error: `401 Unauthorized on all requests`
  - Issue: Token extraction logic has edge cases
  
CONTEXT:
- Express 4.x application
- JWT-based authentication
- Middleware order: body-parser → auth-middleware → routes

REQUIREMENTS:
- Fix JWT authentication edge cases
- Handle missing tokens gracefully
- Public routes should work without token
- Report all files modified
"
```

## Token Efficiency Analysis

### Without History (Bad Pattern)
```
Iteration 1: 1000 tokens → Fail
Iteration 2: 1000 tokens → Fail (same mistake)
Iteration 3: 1000 tokens → Fail (same mistake)
...
Total: N × 1000 tokens for N attempts
```

### With History (Good Pattern)
```
Single call: 1500 tokens → Success
- Base prompt: 500 tokens
- History: +500 tokens
- Solution: +500 tokens
Total: 1500 tokens (solved in 1 attempt)
```

### Break-Even Analysis
- **Cost per iteration**: ~1000 tokens
- **Cost with history**: ~1500 tokens (single call)
- **Break-even**: 2 attempts (1500 < 2000)
- **Net savings at 3 attempts**: 1500 tokens (50% reduction)

## Key Learning

**Stateless design = Full context in every call**:
- Each delegation has no memory of previous calls
- Must include ALL relevant context in prompt
- Previous attempts, errors, and current state
- Current iteration count and attempt number

**Best Practices**:
1. **After 2nd Claude failure**: Delegate to GPT with full history
2. **Include 3-5 previous attempts**: Show progression
3. **Exact error messages**: Not generic descriptions
4. **Analysis of failures**: Why each attempt failed
5. **Current state**: What the code looks like now

**Result**: Fewer iterations, lower token cost, faster resolution.

## Progressive Escalation Pattern

```
Attempt 1 (Claude) → Fail
     ↓
Attempt 2 (Claude) → Fail
     ↓
Attempt 3 (GPT with full history) → Success
```

**Key**: Include both Claude and GPT attempts in history when escalating.
