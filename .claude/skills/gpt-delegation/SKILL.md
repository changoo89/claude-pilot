---
name: gpt-delegation
description: Use when blocked, stuck, or needing fresh perspective. Consults GPT experts via Codex CLI with graceful fallback.
---

# SKILL: GPT Delegation

> **Purpose**: Intelligent Codex/GPT consultation for complex problems, escalation when stuck
> **Target**: Orchestrators detecting delegation triggers

---

## Quick Start

### When to Use This Skill
- After 2+ failed attempts on same issue
- Architecture decisions needed
- Security concerns
- Ambiguous requirements
- Plan review for large plans (5+ SCs)

### Quick Reference
```bash
# Check Codex CLI availability
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0
fi

# Delegate to GPT Architect
.claude/scripts/codex-sync.sh "workspace-write" "You are a software architect...

TASK: [One sentence atomic goal]

EXPECTED OUTCOME: [What success looks like]

CONTEXT:
- Previous attempts: [what was tried]
- Errors: [exact error messages]
- Current iteration: [N]

CONSTRAINTS:
- Must work with existing codebase
- Cannot break existing functionality

MUST DO:
- Analyze why previous attempts failed
- Provide fresh approach
- Report all files modified

MUST NOT DO:
- Repeat same approaches that failed

OUTPUT FORMAT:
Summary → Issues identified → Fresh approach → Files modified → Verification"
```

---

## Core Concepts

### Graceful Fallback (CRITICAL)

**MANDATORY**: All GPT delegation points MUST include graceful fallback.

```bash
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0  # NOT an error, continue with Claude
fi
```

**Key Points**:
- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

### Delegation Triggers

| Trigger | Expert | Mode | When to Delegate |
|---------|--------|------|------------------|
| 2+ failed attempts | Architect | workspace-write | Progressive escalation |
| Stuck on task | Architect | workspace-write | Fresh perspective |
| Architecture decision | Architect | read-only | Design guidance |
| Security concern | Security Analyst | read-only | Vulnerability assessment |
| Ambiguous plan | Scope Analyst | read-only | Requirements clarification |
| Large plan (5+ SCs) | Plan Reviewer | read-only | Plan validation |

### Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure, not first

```
Attempt 1 (Claude) → Fail
     ↓
Attempt 2 (Claude) → Fail
     ↓
Attempt 3 (GPT Architect) → Success
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

## Capability Detection Steps

**Step 1: Check Codex CLI installation**
```bash
command -v codex &> /dev/null || {
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0
}
```

**Step 2: Verify Codex CLI version**
```bash
codex --version | head -1
# Expected: codex version X.Y.Z
```

**Step 3: Check authentication**
```bash
codex auth status
# Expected: "Authenticated as user@example.com"
# or: "Not authenticated" → Run: codex auth login
```

**Step 4: Test basic execution**
```bash
codex exec -s read-only "Say 'test'"
# Expected: Outputs "test"
```

---

## Preferred Command Format

**Basic Syntax**:
```bash
codex-sync.sh <mode> <prompt> [working_dir]
```

**Arguments**:
- `mode`: "read-only" (advisory) or "workspace-write" (implementation)
- `prompt`: Full delegation prompt (can be multi-line)
- `working_dir`: Optional working directory (defaults to current dir)

**Examples**:
```bash
# Advisory delegation
codex-sync.sh read-only "Analyze tradeoffs between Redis and in-memory caching"

# Implementation delegation
codex-sync.sh workspace-write "Fix the SQL injection in user.ts"

# With specific working directory
codex-sync.sh workspace-write "Update login flow" src/auth/
```

**Environment Variables**:
```bash
export CODEX_MODEL="gpt-5.2"           # Override model
export CODEX_TIMEOUT="300"              # Timeout in seconds
export CODEX_REASONING_EFFORT="medium"  # low|medium|high|xhigh
export DEBUG=1                          # Enable diagnostic output
```

---

## Fallback Order

**Primary**: Codex CLI (GPT experts)
**Fallback**: Claude-only analysis (continue without Codex)

**Detection Flow**:
```
1. Check codex in PATH
   ├─ Found → Use Codex CLI
   └─ Not found → Continue to step 2

2. Check common installation paths
   ├─ /opt/homebrew/bin (macOS ARM)
   ├─ /usr/local/bin (macOS Intel/Linux)
   ├─ $HOME/.local/bin
   └─ $HOME/bin
   ├─ Found → Add to PATH, use Codex CLI
   └─ Not found → Continue to step 3

3. Source shell rc file (~/.zshrc or ~/.bashrc)
   ├─ Codex now available → Use Codex CLI
   └─ Still not available → Fallback to Claude

4. Log warning, return success (exit 0)
   → Continue with Claude-only analysis
```

**Key Point**: Fallback is NOT an error. It allows Claude to continue without external tool.

---

## Environment Requirements

**Required Dependencies**:
```bash
# Codex CLI
npm install -g @openai/codex

# jq (JSON parsing)
brew install jq  # macOS
# or: apt-get install jq  # Linux
```

**Optional Dependencies**:
```bash
# timeout command (for execution timeout)
brew install coreutils  # macOS (installs gtimeout)
# Most Linux distros include 'timeout' by default
```

**Shell Configuration**:
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"  # macOS ARM
```

**Authentication**:
```bash
# Authenticate with Codex
codex auth login

# Verify authentication
codex auth status
```

---

## Expected Outputs

### Successful Delegation (read-only mode)

**Output Format**:
```
Bottom line: [One-line summary]

Action plan:
1. [First step]
2. [Second step]
3. [Third step]

Effort estimate: [Time estimation]

Tradeoffs:
- [Option A]: [Pros/cons]
- [Option B]: [Pros/cons]

Recommendation: [Option A/B with rationale]
```

### Successful Delegation (workspace-write mode)

**Output Format**:
```
Summary: [What was done]

Issues identified:
- [Issue 1]: [Description]
- [Issue 2]: [Description]

Fresh approach:
[New strategy that differs from failed attempts]

Files modified:
- src/file1.ts: [Change made]
- src/file2.ts: [Change made]

Verification:
- Tests pass: ✓
- Type-check clean: ✓
- Lint clean: ✓
```

### Graceful Fallback Output

```bash
Warning: Codex CLI not installed - falling back to Claude-only analysis
To enable GPT delegation, install: npm install -g @openai/codex
If already installed, ensure it's in your PATH or ~/.zshrc
```

**Key Point**: Exit code is 0 (success), allowing continuation.

---

## Error Handling

### Codex CLI Not Found

**Error**: `codex: command not found`
**Handling**: Graceful fallback (see above)
**Exit Code**: 0 (continue with Claude)

### Authentication Failed

**Error**: `Not authenticated. Please run: codex auth login`
**Handling**: Log error, return exit code 1
**Recovery**: User runs `codex auth login`, retries delegation

### Timeout

**Error**: `Codex execution timed out after 300s`
**Handling**: Log error with temp output path, return exit code 124
**Recovery**: Increase `CODEX_TIMEOUT`, retry with simpler prompt

### JSON Parsing Error

**Error**: `Error: No response extracted from Codex output`
**Handling**: Log raw output for debugging, return exit code 1
**Recovery**: Check Codex CLI version, verify `codex exec --json` works

### Invalid Mode

**Error**: `Error: Invalid mode 'invalid'. Use 'read-only' or 'workspace-write'`
**Handling**: Log usage message, return exit code 1
**Recovery**: Use correct mode value

---

## Expert Specialties

### Architect

**Specialty**: System design, tradeoffs, complex debugging

**When to use**:
- System design decisions
- After 2+ failed fix attempts
- Tradeoff analysis
- Complex debugging

**Output format**:
- Advisory: Bottom line → Action plan → Effort estimate
- Implementation: Summary → Files modified → Verification

### Plan Reviewer

**Specialty**: Plan validation, gap detection

**When to use**:
- Before starting significant work (5+ SCs)
- After creating work plan

**Output format**: APPROVE/REJECT with justification

### Security Analyst

**Specialty**: Vulnerabilities, threat modeling

**When to use**:
- Authentication/authorization changes
- Security-sensitive code

**Output format**: Threat summary → Vulnerabilities → Risk rating

---

## Configuration

### Reasoning Effort

```bash
export CODEX_REASONING_EFFORT="medium"  # low | medium | high | xhigh
```

- **low**: Fast response (~30s), simple questions
- **medium** (default): Balanced (~1-2min)
- **high**: Deep analysis (~3-5min), complex problems
- **xhigh**: Maximum reasoning (~5-10min)

### Model Configuration

```bash
export CODEX_MODEL="gpt-5.2"  # Override model
export CODEX_TIMEOUT="300"    # Timeout in seconds
```

---

## Verification

### Test GPT Delegation
```bash
# Test graceful fallback
command -v codex &> /dev/null || echo "Fallback works"

# Test delegation (if Codex installed)
if command -v codex &> /dev/null; then
  .claude/scripts/codex-sync.sh "read-only" "Test prompt"
fi
```

---

## Related Skills

- **managing-continuation**: State persistence during delegation
- **ralph-loop**: Escalation when blocked (7 iterations)
- **parallel-subagents**: Coordination during parallel execution

---

**Version**: claude-pilot 4.3.0
