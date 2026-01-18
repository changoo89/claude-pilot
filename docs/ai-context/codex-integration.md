# Codex Integration Guide

> **Purpose**: Intelligent GPT delegation for high-difficulty analysis
> **Last Updated**: 2026-01-18

---

## Overview

**Intelligent GPT Delegation**: Context-aware, autonomous delegation via `codex-sync.sh` for high-difficulty analysis.

---

## Delegation Triggers

### Explicit Triggers (Keyword-Based)

- User explicitly requests: "ask GPT", "review architecture"

### Semantic Triggers (Heuristic-Based)

- **Failure-based**: Agent fails 2+ times on same task
- **Ambiguity**: Vague requirements, no success criteria
- **Complexity**: 10+ success criteria, deep dependencies
- **Risk**: Auth/credential keywords, security-sensitive code
- **Progress stagnation**: No meaningful progress in N iterations

### Description-Based (Claude Code Official)

- Agent descriptions with "use proactively" phrase
- Semantic task matching by Claude Code

---

## GPT Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** (progressive escalation) |
| Coder blocked (automatic) | **Architect** (self-assessment) |

---

## Configuration

### Reasoning Effort

**Default**: `medium` (1-2min response)

**Override**:
```bash
export CODEX_REASONING_EFFORT="low|medium|high|xhigh"
```

**Levels**:
- `low`: Fast response (~30s), good for simple questions
- `medium`: Balanced (~1-2min), default for most tasks
- `high`: Deep analysis (~3-5min), for complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough but slowest

### Graceful Fallback

If Codex CLI is not installed, the system gracefully falls back to Claude-only analysis with a warning message.

---

## Available Experts

| Expert | Specialty | Prompt File |
|--------|-----------|-------------|
| **Architect** | System design, tradeoffs | `.claude/rules/delegator/prompts/architect.md` |
| **Plan Reviewer** | Plan validation | `.claude/rules/delegator/prompts/plan-reviewer.md` |
| **Scope Analyst** | Requirements analysis | `.claude/rules/delegator/prompts/scope-analyst.md` |
| **Code Reviewer** | Code quality, bugs | `.claude/rules/delegator/prompts/code-reviewer.md` |
| **Security Analyst** | Vulnerabilities, threats | `.claude/rules/delegator/prompts/security-analyst.md` |

---

## Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure, not first

**Pattern**:
```
Attempt 1 → Fail → Retry with Claude
Attempt 2 → Fail → Delegate to GPT Architect
Attempt 3 → (via GPT) → Success
```

---

## Intelligent Delegation System (v4.1.0)

**Evolution**: From rigid keyword matching to context-aware heuristics

| Aspect | Old System (v4.0.5) | New System (v4.1.0) |
|--------|---------------------|---------------------|
| **Trigger detection** | `grep -qiE "(tradeoff|design)"` | Heuristic evaluation (failure, ambiguity, complexity, risk) |
| **Decision-making** | Binary (match/no-match) | Confidence scoring (0.0-1.0) |
| **Escalation** | Immediate or never | Progressive (after 2nd failure) |
| **Agent autonomy** | Manual trigger only | Self-assessment with confidence |
| **Claude Code integration** | None | Description-based routing |

### Heuristic Framework

**5 Heuristic Patterns**:
1. **Failure-Based Escalation**: Delegate after 2+ failed attempts
2. **Ambiguity Detection**: Vague requirements, no success criteria
3. **Complexity Assessment**: 10+ SCs, deep dependencies
4. **Risk Evaluation**: Auth/credential keywords, security code
5. **Progress Stagnation**: No progress in N iterations

**Confidence Scoring**:
- Scale: 0.0-1.0
- Threshold: <0.5 → MUST delegate
- Formula: `confidence = base - (failures * 0.2) - (ambiguity * 0.3) - (complexity * 0.1)`

### Description-Based Routing (Claude Code Official)

**How it works**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase
4. When task matches, delegates automatically

**Agents with "use proactively"**:
- **coder**: "Use proactively for implementation tasks"
- **plan-reviewer**: "Use proactively after plan creation"
- **code-reviewer**: "Use proactively after code changes"

---

## Components

| File | Purpose |
|------|---------|
| `codex.py` | Codex CLI detection, auth check, MCP setup |
| `initializer.py` | Calls setup_codex_mcp() during init |
| `updater.py` | Calls setup_codex_mcp() during update |
| `.claude/rules/delegator/*` | 4 orchestration rules (delegation-format, model-selection, orchestration, triggers) |
| `.claude/rules/delegator/prompts/*` | 5 GPT expert prompts (architect, code-reviewer, plan-reviewer, scope-analyst, security-analyst) |

---

## Codex Integration Flow

**IMPORTANT**: The Codex integration uses a **Bash script wrapper** (`codex-sync.sh`), **NOT** an MCP server. The MCP server approach has been deprecated.

```
User Request (Complex Analysis)
      │
      ├─► Trigger Detection (rules/delegator/triggers.md)
      │   ├─► Explicit: "ask GPT", "security review"
      │   └─► Automatic: Security code, 2+ failed fixes, architecture
      │
      ├─► Expert Selection
      │   ├─► Architect: System design, tradeoffs
      │   ├─► Security Analyst: Vulnerabilities, threats
      │   ├─► Code Reviewer: Code quality, bugs
      │   ├─► Plan Reviewer: Plan validation
      │   └─► Scope Analyst: Requirements analysis
      │
      ├─► Delegation (codex-sync.sh)
      │   ├─► Mode: read-only (Advisory) or workspace-write (Implementation)
      │   ├─► Prompt: 7-section format with expert instructions
      │   └─► Command: .claude/scripts/codex-sync.sh "<mode>" "<prompt>"
      │
      └─► Response Handling
          ├─► Synthesize insights
          ├─► Apply judgment
          └─► Verify implementation (if applicable)
```

---

## Delegation Script (codex-sync.sh)

**Location**: `.claude/scripts/codex-sync.sh`

**Usage**:
```bash
.claude/scripts/codex-sync.sh "<mode>" "<delegation_prompt>"

# Parameters:
# - mode: "read-only" (Advisory) or "workspace-write" (Implementation)
# - delegation_prompt: 7-section prompt with expert instructions

# Example (Advisory):
.claude/scripts/codex-sync.sh "read-only" "You are a software architect...
TASK: Analyze tradeoffs between Redis and in-memory caching.
EXPECTED OUTCOME: Clear recommendation with rationale.
CONTEXT: [user's situation, full details]
..."
```

**Configuration**:
- **Model**: `gpt-5.2` (override with `CODEX_MODEL` env var)
- **Timeout**: `300s` (override with `CODEX_TIMEOUT` env var)
- **Reasoning Effort**: `medium` (override with `CODEX_REASONING_EFFORT` env var)

**Reasoning Effort Levels** (Updated 2026-01-17):
- `low`: Fast response (~30s), good for simple questions
- `medium`: Balanced (~1-2min), default for most tasks (overrides global xhigh config)
- `high`: Deep analysis (~3-5min), for complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough but slowest

**Usage**:
```bash
# Set for current session
export CODEX_REASONING_EFFORT="medium"

# Set for single command
CODEX_REASONING_EFFORT="low" .claude/scripts/codex-sync.sh ...

# Set permanently (add to ~/.zshrc or ~/.bashrc)
echo 'export CODEX_REASONING_EFFORT="medium"' >> ~/.zshrc
```

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` | Intelligent Delegation | Heuristic-based Architect delegation |
| `/01_confirm` | Intelligent Delegation | Heuristic-based Plan Reviewer delegation |
| `/02_execute` | Auto-Delegation | CODER_BLOCKED → GPT Architect (automatic) |
| `/02_execute` | Progressive Escalation | 2+ failures → GPT Architect (not first) |
| `/90_review` | Intelligent Delegation | Heuristic-based Code Reviewer delegation |
| `/91_document` | Intelligent Delegation | Heuristic-based Architect delegation |
| `/03_close` | Intelligent Delegation | Heuristic-based Plan Reviewer delegation |
| `/999_publish` | Intelligent Delegation | Heuristic-based Security Analyst delegation |
| `coder` | Self-Assessment | Confidence scoring → delegation recommendation |
| `plan-reviewer` | Self-Assessment | Confidence scoring → delegation recommendation |
| `code-reviewer` | Self-Assessment | Confidence scoring → delegation recommendation |
| `rules/delegator/intelligent-triggers.md` | Heuristic patterns | NEW v4.1.0 |
| `guides/intelligent-delegation.md` | System documentation | NEW v4.1.0 |
| `templates/` | Long-running task templates | feature-list.json, init.sh, progress.md |

**Key Features**:
- **Model**: GPT 5.2 (via Codex CLI)
- **Script**: Bash wrapper for `codex exec` command
- **Fallback**: Graceful skip if Codex CLI not installed (logs warning, returns success)
- **Auto-Delegation**: Automatic GPT Architect call when Coder returns BLOCKED (no user prompt needed)
- **Validation**: Checks Codex authentication status

---

## Delegation Rules (6 Files)

Located in `.claude/rules/delegator/`:

| File | Purpose | Lines | Updated |
|------|---------|-------|---------|
| `delegation-format.md` | 7-section format with phase-specific templates | ~180 | v4.1.2 |
| `delegation-checklist.md` | Validation checklist for delegation prompts | ~90 | v4.1.2 |
| `model-selection.md` | Expert directory, operating modes, codex parameters | ~120 | v4.1.0 |
| `orchestration.md` | Stateless design, retry flow, context engineering | ~450 | v4.1.2 |
| `triggers.md` | PROACTIVE/REACTIVE delegation triggers | ~300 | v4.1.0 |
| `pattern-standard.md` | Standardized GPT delegation pattern across commands | ~200 | v4.0.5 |

---

## Example Files (4 Files)

Located in `.claude/rules/delegator/examples/` (NEW v4.1.2):

| File | Purpose | Lines |
|------|---------|-------|
| `before-phase-detection.md` | Example: Poor prompt without phase context | ~20 |
| `after-phase-detection.md` | Example: Improved prompt with phase detection | ~40 |
| `before-stateless.md` | Example: Missing iteration history | ~15 |
| `after-stateless.md` | Example: Full stateless context with history | ~35 |

---

## Expert Prompts (5 Files)

Located in `.claude/rules/delegator/prompts/`:

| File | Expert | Mode | Output |
|------|--------|------|--------|
| `architect.md` | Architect | Advisory/Implementation | Recommendation + plan / Changes + verification |
| `code-reviewer.md` | Code Reviewer | Advisory/Implementation | Issues + verdict / Fixes + verification |
| `plan-reviewer.md` | Plan Reviewer | Advisory | APPROVE/REJECT + justification |
| `scope-analyst.md` | Scope Analyst | Advisory | Intent + findings + questions + risks |
| `security-analyst.md` | Security Analyst | Advisory/Implementation | Vulnerabilities + risk / Hardening + verification |

---

## User Experience

**New Projects** (`claude-pilot init`):
- Detects Codex CLI if installed
- Checks authentication status
- Creates `.mcp.json` with Codex MCP config
- Copies 6 orchestration rules to `.claude/rules/delegator/`
- Copies 5 expert prompts to `.claude/rules/delegator/prompts/`
- Copies 4 example files to `.claude/rules/delegator/examples/` (v4.1.2)

**Existing Projects** (`claude-pilot update`):
- Same detection and setup process
- Merges Codex config into existing `.mcp.json`
- Updates orchestration rules and prompts if newer version available
- Updates example files if newer version available (v4.1.2)

**No Codex Installed**:
- Silent skip (no errors or warnings)
- Other init/update operations proceed normally

---

## Phase-Specific Delegation (v4.1.2)

**Problem Solved**: GPT Plan Reviewer was checking file system during planning phase, rejecting plans for "missing files" that don't exist yet.

**Solution**: Phase-aware context in delegation prompts

| Phase | Context | File System Behavior | Focus |
|-------|---------|---------------------|-------|
| **Planning** | Files don't exist yet (design document) | DO NOT check file system | Plan clarity, completeness, verifiability |
| **Implementation** | Code should exist now | DO check file system | Implementation verification, quality validation |

**Implementation Components**:

1. **Phase-Specific Templates** (`delegation-format.md`):
   - Planning Phase template: "DO NOT check file system"
   - Implementation Phase template: "DO check file system"
   - Explicit MUST NOT DO items per phase

2. **Phase Detection Logic** (`prompts/plan-reviewer.md`):
   - Automatic detection from context indicators
   - Planning keywords: "plan", "design", "proposed", "will create"
   - Implementation keywords: "implemented", "created", "added", "done"
   - Default to Planning Phase if unclear

3. **Context Engineering** (`orchestration.md`):
   - Dynamic context components (phase, history, iteration count)
   - Context selection strategy (phase detection, history injection)
   - Token budget awareness (8K-16K target)

4. **Validation Checklist** (`delegation-checklist.md`):
   - 48 validation items across 8 categories
   - Phase-specific requirements verification
   - Stateless design compliance checks
   - Expert-specific requirements

5. **Example Files** (`examples/`):
   - Before/after comparisons for phase detection
   - Before/after comparisons for stateless design
   - Demonstrate improvements with concrete examples

---

## Security Considerations

1. **Authentication Check**: Only enables if valid tokens in `~/.codex/auth.json`
2. **Path Safety**: Uses `Path` objects for cross-platform compatibility
3. **Merge Strategy**: Preserves existing MCP servers in `.mcp.json`
4. **Silent Failure**: Returns `True` on skip (not installed) to avoid breaking init/update

---

## Testing

Test file: `tests/test_codex.py` (11 tests, 81% coverage)

| Test | Scenario |
|------|----------|
| `test_detect_codex_installed` | Codex CLI present |
| `test_detect_codex_not_installed` | Codex CLI not found |
| `test_codex_authenticated` | Valid auth.json with tokens |
| `test_codex_not_authenticated` | No/invalid auth.json |
| `test_setup_mcp_fresh` | Create new .mcp.json |
| `test_setup_mcp_merge` | Merge into existing .mcp.json |
| `test_setup_mcp_skip` | Skip when Codex not installed |

---

## See Also

- **@.claude/guides/intelligent-delegation.md** - Full delegation guide
- **@.claude/rules/delegator/orchestration.md** - Orchestration patterns
- **@CLAUDE.md** - Project standards (Tier 1)

---

**Last Updated**: 2026-01-18
**Version**: 4.2.0
