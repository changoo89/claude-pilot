# Agent Teams Hook Scripts

This directory contains hook scripts for Claude Code Agent Teams quality gates.

## Hook Scripts

### verify-task-completion.sh
**Hook Type**: TaskCompleted
**Purpose**: Verify quality gates before allowing task completion

**Quality Checks**:
1. Tests pass (auto-detect: npm test, pytest, cargo test, go test)
2. Coverage ≥80%
3. Type-check clean (tsc --noEmit if applicable)
4. Lint clean (if applicable)
5. TODO checkboxes checked in plan file

**Exit Codes**:
- `0`: Allow completion (all checks pass)
- `2`: Reject completion with feedback

**Environment Variables**:
- `TASK_DESCRIPTION`: Task description (optional)
- `PLAN_PATH`: Path to plan file (auto-detects from `.pilot/plan/in_progress/*.md`)

### teammate-idle-check.sh
**Hook Type**: TeammateIdle
**Purpose**: Verify work completion before allowing teammate to go idle

**Quality Checks**:
1. Assigned SC is fully complete (all TODOs checked)
2. Basic quality gates pass

**Exit Codes**:
- `0`: Allow idle (work is done)
- `2`: Reject idle (continue working)

**Environment Variables**:
- `PLAN_PATH`: Path to plan file (auto-detects from `.pilot/plan/in_progress/*.md`)

## Settings.json Configuration

To enable these hooks in Claude Code, add the following to your `settings.json`:

```json
{
  "hooks": {
    "TaskCompleted": {
      "command": "${workspaceFolder}/.claude/hooks/verify-task-completion.sh"
    },
    "TeammateIdle": {
      "command": "${workspaceFolder}/.claude/hooks/teammate-idle-check.sh"
    }
  },
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Testing

Run the test suite:
```bash
tests/skills/test_hooks_simple.sh
```

## Features

### Auto-Detection
- Test runner: Automatically detects npm, pytest, cargo, go test
- Plan file: Automatically finds plan in `.pilot/plan/in_progress/`
- Coverage: Extracts coverage percentage from test output

### Error Handling
- Graceful fallback when test runner not found
- Timeout protection (120s default for tests)
- Clear error messages on stderr

### Self-Contained
- No external dependencies beyond standard Unix tools
- Executable shell scripts with `#!/bin/bash`
- Follows vibe-coding standards (functions ≤50 lines)
