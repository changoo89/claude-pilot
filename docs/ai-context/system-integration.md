# System Integration Guide

> **Purpose**: Component interactions, data flow, shared patterns, and integration points
> **Last Updated**: 2026-01-17 (Updated: GPT Delegation Auto-Delegation and Reasoning Effort Configuration)

---

## Slash Command Workflow

### Core Commands

```
/00_plan (planning) --> /01_confirm (extraction + review) --> /02_execute (TDD + Ralph) --> /03_close (archive)
                                                                                   |
                                                                                   v
                                                                          /90_review (anytime)
                                                                          /999_publish (deploy)
```

### Phase Boundary Protection (Updated 2026-01-15)

The `/00_plan` command includes **Level 3 (Strong) phase boundary protection** to prevent ambiguous confirmations from triggering execution.

#### Key Features

1. **Pattern-Based Detection**: Language-agnostic approach (no word lists)
2. **MANDATORY AskUserQuestion**: Multi-option confirmation at plan completion
3. **Valid Execution Triggers**: Only explicit commands allow phase transition

#### AskUserQuestion Template

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

#### Valid Execution Triggers

- User explicitly types `/01_confirm` or `/02_execute`
- User explicitly says "start coding now" or "begin implementation"
- User selects option C or D from AskUserQuestion

**All other responses** (including "go ahead", "proceed", "그래 그렇게 해") → Continue planning or re-call AskUserQuestion.

#### Anti-Patterns

- **NEVER** use Yes/No questions at phase boundaries
- **NEVER** try to detect specific words or phrases
- **ALWAYS** provide explicit multi-option choices
- **ALWAYS** call AskUserQuestion when uncertain about user intent

### /02_execute Command Workflow (Updated 2026-01-16)

The `/02_execute` command implements the plan using TDD + Ralph Loop pattern. **Step 1 now includes MANDATORY plan detection** to prevent intermittent "No plan found" errors. **Step 1.1 includes atomic plan state transition** to prevent duplicate work when multiple pending plans are queued. **Worktree mode includes atomic lock mechanism** (v3.3.4) to prevent race conditions in parallel execution.

#### Step 1: Plan Detection (MANDATORY FIRST ACTION) - NEW

**Key Change (2026-01-16)**: Added explicit MANDATORY ACTION section to prevent Claude from skipping plan detection.

**Structure**:
- **MANDATORY ACTION header**: "YOU MUST DO THIS FIRST - NO EXCEPTIONS"
- **Explicit Bash commands**: Direct `ls` commands for pending/ and in_progress/
- **Guard condition**: "DO NOT say 'no plan found' without actually running these commands"

**Problem Fixed**:
- Claude Code reads markdown as prompt, not as executable bash script
- Bash code blocks in Step 1 were documentation, not automatic execution
- Claude may skip Step 1 or misinterpret it, jumping to "no plan" conclusion
- Result: Intermittent false "No plan found" errors even when plans exist

#### Step 1.1: Plan State Transition (ATOMIC)

**Key Change (2026-01-15)**: Plan movement from `pending/` to `in_progress/` is now the **FIRST and ATOMIC operation** before any other work begins.

**Atomic Block Structure**:
1. Select plan (pending or in_progress)
2. Move pending → in_progress (if applicable) with early exit on failure
3. Create active pointer

**Critical Features**:
- **BLOCKING markers**: Clear visual indicators with emoji warnings
- **Early exit guards**: `|| exit 1` after `mv` command prevents partial state
- **Worktree mode**: Atomic lock mechanism to prevent race conditions
- **Progress logging**: Clear messages for plan movement and pointer creation

#### Worktree Lock Lifecycle (v3.3.4)

**Purpose**: Prevent race conditions when multiple executors select plans simultaneously

**Lock Flow**:
```
[Executor 1]           [Executor 2]           [Executor 3]
     |                      |                      |
     v                      v                      v
select_and_lock_pending  select_and_lock_pending  select_and_lock_pending
     |                      |                      |
     +---> mkdir .locks/plan_a.lock (SUCCESS)
     |                      +---> mkdir .locks/plan_a.lock (FAIL)
     |                      |                      +---> mkdir .locks/plan_b.lock (SUCCESS)
     |                      |                      |
     v                      v                      v
Verify plan_a exists    Try plan_b              Verify plan_b exists
(Lock held)             (Lock held)             (Lock held)
     |                      |                      |
     v                      v                      v
mv plan_a → in_progress mv plan_b → in_progress
     |                      |                      |
     v                      v                      v
Execute worktree_a      Execute worktree_b
(Lock released on close) (Lock released on close)
```

**Lock Functions** (in `.claude/scripts/worktree-utils.sh`):

1. **`select_and_lock_pending()`**: Atomic lock with plan verification
   - Uses `mkdir` for atomic lock (POSIX-compliant)
   - Verifies plan still exists AFTER lock acquisition (TOCTOU fix)
   - Falls back to next plan if lock fails

2. **`get_main_pilot_dir()`**: Returns absolute path to main `.pilot/`
   - Enables lock cleanup from worktree context
   - Used in `/03_close` for reliable lock removal

**Lock Lifecycle**:
- **Created**: In `/02_execute` Step 1 (worktree mode only)
- **Held**: During execution (NOT deleted after selection)
- **Released**: In `/03_close` after cleanup completes
- **Error trap**: Auto-releases lock on any failure

**Key Fix (v3.3.4)**: Lock held until `mv` completes prevents TOCTOU gap where plan could be deleted between lock acquisition and move.

#### Step Sequence

1. **Step 1: Plan Detection (MANDATORY FIRST ACTION)** - NEW (2026-01-16)
   - Execute Bash commands to find plans in pending/ and in_progress/
   - MANDATORY ACTION pattern prevents skipping plan detection
   - Guard condition prevents false "no plan found" errors

2. **Step 1.1: Plan State Transition (ATOMIC)**
   - 1.1.1 Worktree Mode (--wt): Atomic move before worktree setup
   - 1.1.2 Select and Move Plan (ATOMIC BLOCK): Select + Move + Pointer
   - Exit immediately if move fails

3. **Step 2: Convert Plan to Todo List**
   - Extract deliverables, phases, tasks, acceptance criteria
   - Map SC dependencies for parallel execution

4. **Step 2.5: SC Dependency Analysis (For Parallel Execution)**
   - Analyze SC dependencies
   - Group independent SCs
   - Parallel execution pattern with MANDATORY ACTION sections

5. **Step 3: Delegate to Coder Agent (Context Isolation)**
   - MANDATORY ACTION: Invoke Coder Agent via Task tool
   - Token-efficient context isolation (5K vs 110K+ tokens)

6. **Step 3.5: Parallel Verification (Multi-Angle Quality Check)**
   - MANDATORY ACTION: Invoke Tester + Validator + Code-Reviewer in parallel
   - Tester: Test execution and coverage analysis
   - Validator: Type check, lint, coverage thresholds
   - Code-Reviewer: Deep review for async bugs, memory leaks, security issues

7. **Step 3.6: Review Feedback Loop (Optional Iteration)**
   - IF critical issues found: Re-invoke Coder or ask user
   - ELSE: Continue to next step
   - Max 3 iterations to prevent infinite loops

8. **Step 4: Execute with TDD (Legacy)**
   - Red-Green-Refactor cycle
   - Ralph Loop integration

9. **Step 5: Ralph Loop (Autonomous Completion)**
   - Max 7 iterations
   - Verification: tests, type-check, lint, coverage

10. **Step 6: Todo Continuation Enforcement**
    - Never quit halfway
    - One `in_progress` at a time

11. **Step 7: Verification**
    - Type check, tests, lint

12. **Step 8: Update Plan Artifacts**
    - Add Execution Summary

13. **Step 9: Auto-Chain to Documentation**
    - Trigger `/91_document` if all criteria met

### /03_close Command Workflow (Updated 2026-01-17)

The `/03_close` command archives completed plans and creates git commits. **Worktree mode includes complete cleanup** (v3.3.4) with error trap for lock cleanup. **v4.0.4 adds context restoration from plan file** for multi-worktree concurrent execution.

#### Worktree Cleanup Flow (v3.3.4)

**Purpose**: Remove worktree, branch, directory, and lock after completion

**Cleanup Steps**:
```bash
if is_in_worktree; then
    # 1. Read worktree metadata from plan
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN <<< "$WORKTREE_META"

    # 2. Get main project directory and lock file
    MAIN_PROJECT_DIR="$(get_main_project_dir)"
    LOCK_FILE=".pilot/plan/.locks/$(basename "$ACTIVE_PLAN_PATH").lock"

    # 3. Set error trap for lock cleanup
    trap "cd \"$MAIN_PROJECT_DIR\" && rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

    # 4. Change to main project
    cd "$MAIN_PROJECT_DIR" || exit 1

    # 5. Squash merge worktree branch to main
    do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MSG"

    # 6. Cleanup worktree, branch, directory
    cleanup_worktree "$WT_PATH" "$WT_BRANCH"

    # 7. Remove lock file (explicit cleanup, trap handles errors)
    rm -rf "$LOCK_FILE"

    # 8. Clear trap on success
    trap - EXIT ERR
fi
```

**Key Features**:
- **Error trap**: Lock auto-released on any failure (EXIT or ERR signal)
- **Absolute lock path**: Ensures reliable cleanup from worktree context
- **Complete cleanup**: Worktree, branch, directory, lock all removed
- **Squash merge**: Changes merged to main branch before cleanup

**Cleanup Functions** (in `.claude/scripts/worktree-utils.sh`):

1. **`cleanup_worktree()`**: Remove worktree, branch, and directory
   - Removes worktree via `git worktree remove`
   - Deletes branch via `git branch -D`
   - Removes directory if it still exists

2. **`get_main_project_dir()`**: Get main project path from worktree
   - Uses `git rev-parse --git-common-dir`
   - Returns parent of git common directory

3. **`get_main_pilot_dir()`**: Get main `.pilot/` path
   - Combines main project dir with `.pilot/`
   - Used for lock file path resolution

**Error Handling**:
- Trap set before any cleanup operations
- Trap fires on EXIT (success) or ERR (failure)
- Lock removed even if cleanup fails partially
- Trap cleared on success to prevent double-cleanup

#### Worktree Context Restoration (v4.0.4)

**Purpose**: Enable `/03_close` to work regardless of Bash cwd (which resets to project root on each call)

**Problem Fixed**:
- Claude Code Bash environment resets cwd to project root on each call
- `/02_execute --wt` stored active pointer using worktree branch key (after cd to worktree)
- `/03_close` runs from main project (due to cwd reset), looked for main branch key
- Active pointer mismatch: stored as `feature_xxx.txt`, searched as `main.txt`
- Worktree path stored as relative path (`../xxx`), breaks when cwd differs

**Solution Components**:

1. **Absolute Path Conversion** (worktree-utils.sh):
   ```bash
   create_worktree() {
       # ...
       worktree_dir="$(cd "$worktree_dir" && pwd)"  # Convert to absolute path
       printf "%s" "$worktree_dir"
   }
   ```

2. **Dual Active Pointer Storage** (02_execute.md):
   ```bash
   # BEFORE cd to worktree:
   MAIN_KEY="$(printf "%s" "$MAIN_BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
   printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${MAIN_KEY}.txt"

   # ALSO store with worktree branch key:
   WT_KEY="$(printf "%s" "$BRANCH_NAME" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
   printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${WT_KEY}.txt"
   ```

3. **Context Restoration in Close** (03_close.md):
   ```bash
   # Step 1.5: Worktree Context Restoration
   if grep -q "## Worktree Info" "$PLAN_PATH"; then
       WT_PATH="$(grep 'Worktree Path:' "$PLAN_PATH" | sed 's/.*: //')"
       MAIN_PROJECT="$(grep 'Main Project:' "$PLAN_PATH" | sed 's/.*: //')"

       if [ -d "$WT_PATH" ]; then
           cd "$WT_PATH"
           # ... squash merge, cleanup
       fi
   fi
   ```

4. **Enhanced Metadata Format**:
   ```markdown
   ## Worktree Info
   - Branch: feature/20260117-xxx
   - Worktree Path: /absolute/path/to/worktree
   - Main Branch: main
   - Main Project: /absolute/path/to/main/project
   - Lock File: /absolute/path/to/.locks/xxx.lock
   - Created At: 2026-01-17T06:31:16
   ```

5. **Force Cleanup for Dirty Worktrees**:
   ```bash
   cleanup_worktree() {
       # Try normal remove first
       if ! git worktree remove "$WT_PATH" 2>/dev/null; then
           # Force remove for dirty worktrees
           git worktree remove --force "$WT_PATH"
       fi
   }
   ```

**Updated Functions** (worktree-utils.sh):

| Function | Change |
|----------|--------|
| `create_worktree()` | Returns absolute path (was relative) |
| `add_worktree_metadata()` | Accepts 6 parameters (added main_project and lock_file) |
| `read_worktree_metadata()` | Parses 5 fields using multi-line extraction (was 3 fields with grep -A1) |
| `cleanup_worktree()` | Supports --force option for dirty worktrees |

**Integration Points**:

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/02_execute` Step 1.1 | Stores dual-key pointers BEFORE cd | `.pilot/plan/active/{main}.txt` + `.pilot/plan/active/{feature}.txt` |
| `/02_execute` Step 1.1.1 | Calls create_worktree (returns absolute) | Absolute path to worktree |
| `/02_execute` Step 1.1.1 | Calls add_worktree_metadata (6 params) | Plan file with all 5 metadata fields |
| `/03_close` Step 1.5 | Reads context from plan file | Restores WT_PATH, MAIN_PROJECT, LOCK_FILE |
| `/03_close` cleanup | Force removes dirty worktrees | Graceful cleanup without manual intervention |

#### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/02_execute` | Creates lock | `.pilot/plan/.locks/{plan}.lock` |
| `/03_close` | Releases lock | Lock file removed (or trap auto-removes) |
| `worktree-utils.sh` | Lock/cleanup functions | Shared utilities |

---

## External Skills Sync (v3.3.6)

### Overview

The external skills sync feature automatically downloads and updates Vercel agent-skills from GitHub, providing frontend developers with production-grade React optimization guidelines.

### Components

| File | Purpose |
|------|---------|
| `config.py` | EXTERNAL_SKILLS dict with Vercel configuration |
| `updater.py` | sync_external_skills(), get_github_latest_sha(), download_github_tarball(), extract_skills_from_tarball() |
| `initializer.py` | Calls sync_external_skills() during init |
| `cli.py` | `--skip-external-skills` flag for init/update |

### Sync Workflow

```
User runs: claude-pilot init/update
      │
      ├─► Check skip flag
      │   └─► skip=True → Return "skipped"
      │
      ├─► Read existing version
      │   └─► .claude/.external-skills-version
      │
      ├─► Fetch latest commit SHA
      │   └─► GitHub API: GET /repos/{owner}/{repo}/commits/{branch}
      │
      ├─► Compare versions
      │   └─► Same → Return "already_current"
      │
      ├─► Download tarball
      │   └─► GET /repos/{owner}/{repo}/tarball/{ref}
      │
      ├─► Extract skills
      │   ├─► Validate paths (no traversal)
      │   ├─► Reject symlinks
      │   └─► Copy to .claude/skills/external/
      │
      ├─► Save new version
      │   └─► Write SHA to .external-skills-version
      │
      └─► Return "success"
```

### Security Features

1. **Path Traversal Prevention**: Validates all extracted paths don't contain `..`
2. **Symlink Rejection**: Rejects all symlinks to prevent arbitrary file writes
3. **Streaming Download**: Uses chunked download for large tarballs
4. **Temp Directory**: Downloads to temp directory before atomic move

### Configuration

```python
EXTERNAL_SKILLS = {
    "vercel-agent-skills": {
        "repo": "vercel-labs/agent-skills",
        "branch": "main",
        "skills_path": "skills",
    }
}
EXTERNAL_SKILLS_DIR = ".claude/skills/external"
EXTERNAL_SKILLS_VERSION_FILE = ".claude/.external-skills-version"
```

### CLI Integration

| Command | Flag | Behavior |
|---------|------|----------|
| `claude-pilot init` | `--skip-external-skills` | Skip downloading external skills |
| `claude-pilot update` | `--skip-external-skills` | Skip syncing external skills |

### Error Handling

| Scenario | Behavior |
|----------|----------|
| Network failure | Warning message, continues with other operations |
| Rate limit (403) | Warning message, returns "failed" |
| Invalid tarball | Warning message, returns "failed" |
| Already current | Info message, returns "already_current" |

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `initializer.py` | Calls sync_external_skills() | → `.claude/skills/external/` |
| `updater.py` | GitHub API calls | → Latest commit SHA, tarball download |
| `config.py` | EXTERNAL_SKILLS config | → Repository metadata |
| `cli.py` | `--skip-external-skills` flag | → Skip conditional |

---

## Codex Delegator Integration (v4.0.4)

### Overview

The Codex delegator integration provides optional GPT expert delegation via `codex-sync.sh` Bash script, enabling multi-LLM orchestration (Claude + GPT 5.2) for specialized tasks like architecture, security review, and code review.

### Components

| File | Purpose |
|------|---------|
| `codex.py` | Codex CLI detection, auth check, MCP setup |
| `initializer.py` | Calls setup_codex_mcp() during init |
| `updater.py` | Calls setup_codex_mcp() during update |
| `.claude/rules/delegator/*` | 4 orchestration rules (delegation-format, model-selection, orchestration, triggers) |
| `.claude/rules/delegator/prompts/*` | 5 GPT expert prompts (architect, code-reviewer, plan-reviewer, scope-analyst, security-analyst) |

### Codex Integration Flow

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

### Delegation Script (codex-sync.sh)

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

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/90_review` | GPT Expert Review (Step 10) | Architecture review → GPT Architect |
| `/02_execute` | Auto-Delegation (Step 3.1.1) | CODER_BLOCKED → GPT Architect (automatic) |
| `/02_execute` | GPT Escalation (Step 4) | 2+ Coder failures → GPT Architect |
| `code-reviewer` | GPT Security Analyst Delegation | Security code → GPT Security Analyst |
| `plan-reviewer` | GPT Plan Reviewer Delegation | Large plans (5+ SCs) → GPT Plan Reviewer |
| `rules/delegator/*` | Orchestration rules | Delegation flow, triggers, format |
| `rules/delegator/prompts/*` | GPT expert prompts | 5 expert system instructions |

**Key Features**:
- **Model**: GPT 5.2 (via Codex CLI)
- **Script**: Bash wrapper for `codex exec` command
- **Fallback**: Graceful skip if Codex CLI not installed (logs warning, returns success)
- **Auto-Delegation**: Automatic GPT Architect call when Coder returns BLOCKED (no user prompt needed)
- **Validation**: Checks Codex authentication status

### GPT Expert Delegation

Available experts via Codex CLI:

| Expert | Specialty | Use For |
|--------|-----------|---------|
| Architect | System design, tradeoffs | Architecture decisions, complex debugging |
| Code Reviewer | Code quality, bugs | Code review, finding issues |
| Plan Reviewer | Plan validation | Reviewing work plans before execution |
| Scope Analyst | Requirements analysis | Catching ambiguities before work starts |
| Security Analyst | Vulnerabilities, threats | Security audits, hardening |

### Delegation Rules (4 Files)

Located in `.claude/rules/delegator/`:

| File | Purpose |
|------|---------|
| `delegation-format.md` | 7-section format for delegation prompts |
| `model-selection.md` | Expert directory, operating modes, codex parameters |
| `orchestration.md` | Stateless design, retry flow, cost awareness |
| `triggers.md` | PROACTIVE/REACTIVE delegation triggers |

### Expert Prompts (5 Files)

Located in `.claude/rules/delegator/prompts/`:

| File | Expert | Mode | Output |
|------|--------|------|--------|
| `architect.md` | Architect | Advisory/Implementation | Recommendation + plan / Changes + verification |
| `code-reviewer.md` | Code Reviewer | Advisory/Implementation | Issues + verdict / Fixes + verification |
| `plan-reviewer.md` | Plan Reviewer | Advisory | APPROVE/REJECT + justification |
| `scope-analyst.md` | Scope Analyst | Advisory | Intent + findings + questions + risks |
| `security-analyst.md` | Security Analyst | Advisory/Implementation | Vulnerabilities + risk / Hardening + verification |

### User Experience

**New Projects** (`claude-pilot init`):
- Detects Codex CLI if installed
- Checks authentication status
- Creates `.mcp.json` with Codex MCP config
- Copies 4 orchestration rules to `.claude/rules/delegator/`
- Copies 5 expert prompts to `.claude/rules/delegator/prompts/`

**Existing Projects** (`claude-pilot update`):
- Same detection and setup process
- Merges Codex config into existing `.mcp.json`
- Updates orchestration rules and prompts if newer version available

**No Codex Installed**:
- Silent skip (no errors or warnings)
- Other init/update operations proceed normally

### Security Considerations

1. **Authentication Check**: Only enables if valid tokens in `~/.codex/auth.json`
2. **Path Safety**: Uses `Path` objects for cross-platform compatibility
3. **Merge Strategy**: Preserves existing MCP servers in `.mcp.json`
4. **Silent Failure**: Returns `True` on skip (not installed) to avoid breaking init/update

### Testing

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

## /00_plan Command Workflow (Updated 2026-01-16)

The `/00_plan` command generates SPEC-First plans with **User Requirements Collection (Step 0)** to prevent omissions.

### Step Sequence

1. **Step 0: User Requirements Collection** (NEW)
   - Collect verbatim input (original language, exact wording)
   - Assign UR-IDs (UR-1, UR-2, UR-3, ...)
   - Build User Requirements (Verbatim) table
   - Update during conversation as new requirements emerge
   - Requirements Coverage Check table for 100% tracking

2. **Step 1: Parallel Exploration**
   - Explorer Agent (Haiku): Codebase exploration
   - Researcher Agent (Haiku): External docs research
   - Send in same message for true parallelism

3. **Step 2: Compile Execution Context**
   - Explored Files table
   - Key Decisions Made table
   - Implementation Patterns (FROM CONVERSATION)

4. **Step 3: Requirements Elicitation**
   - PRP Analysis (What, Why, How, Success Criteria, Constraints)
   - Map user requirements to success criteria

5. **Step 4: PRP Definition**
   - Define scope, architecture, execution plan
   - Acceptance criteria, test plan

6. **Step 5: External Service Integration** (if applicable)
   - API Calls Required table
   - Environment Variables Required table
   - Error Handling Strategy

7. **Step 6: Architecture & Design**
   - Architecture diagrams
   - Vibe Coding compliance check

8. **Step 7: Present Plan Summary**
   - Include User Requirements (Verbatim) section
   - Requirements Coverage Check table
   - AskUserQuestion for next action

### User Requirements (Verbatim) Template

```markdown
## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "00_plan 이 바로 시작되는 이슈" | Phase boundary violation prevention |
| UR-2 | "03_close에 git push" | Add git push to 03_close |
| UR-3 | "검증 단계 추가해줘" | Add verification step |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| UR-3 | ✅ | SC-4 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |
```

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` Step 0 | Creates UR table | → Plan file |
| `/00_plan` Step 7 | Presents summary | → User review |
| `/01_confirm` Step 2.7 | Verifies coverage | → BLOCKING if missing |

---

## /01_confirm Command Workflow (Updated 2026-01-16)

The `/01_confirm` command extracts the plan from the `/00_plan` conversation, creates a plan file, and **verifies 100% requirements coverage**.

#### Step Sequence

1. **Step 1: Extract Plan from Conversation**
   - Review context for requirements, scope, architecture, execution plan
   - Validate completeness (User Requirements, Execution Plan, Acceptance Criteria, Test Plan)

2. **Step 1.5: Conversation Highlights Extraction**
   - Extract code examples (fenced code blocks)
   - Extract syntax patterns (CLI commands, API patterns)
   - Extract architecture diagrams (ASCII art, Mermaid charts)
   - Mark with `> **FROM CONVERSATION:**` prefix
   - Add to plan under "Execution Context → Implementation Patterns"

3. **Step 2: Generate Plan File Name**
   - Create timestamped filename: `YYYYMMDD_HHMMSS_{work_name}.md`

4. **Step 2.7: Requirements Verification** (NEW)
   - Extract User Requirements (Verbatim) table
   - Extract Success Criteria from PRP Analysis
   - Verify 1:1 mapping (UR → SC)
   - BLOCKING if any requirement missing
   - Update plan with Requirements Coverage Check

5. **Step 3: Create Plan File**
   - Use plan template structure
   - Include Execution Context with Implementation Patterns
   - Include User Requirements (Verbatim) section
   - Add External Service Integration (if applicable)

6. **Step 4: Auto-Review**
   - Run Gap Detection Review (unless `--no-review`)
   - Interactive Recovery for BLOCKING findings
   - Support `--lenient` flag to bypass BLOCKING

#### Plan File Structure

```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements (Verbatim)  <-- Step 0 output
| ID | User Input (Original) | Summary |
|----|----------------------|---------|

### Requirements Coverage Check  <-- Step 2.7 output
| Requirement | In Scope? | Success Criteria | Status |

## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff)
### Explored Files
### Key Decisions Made
### Implementation Patterns (FROM CONVERSATION)  <-- Step 1.5 output
## External Service Integration [if applicable]
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
## Review History
## Execution Summary
```

#### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` Step 0 | Creates UR table | → Plan User Requirements (Verbatim) |
| `/00_plan` Step 7 | Presents summary | → `/01_confirm` extracts |
| `/01_confirm` Step 2.7 | Verifies coverage | → Requirements Coverage Check (BLOCKING if missing) |
| `/01_confirm` | Creates plan file | → `.pilot/plan/pending/` |
| `/01_confirm` Step 1.5 | Extracts highlights | → Plan Implementation Patterns |
| Gap Detection | Reviews external services | → Interactive Recovery |
| `/02_execute` Step 1 | Atomic plan move (pending → in_progress) | → `.pilot/plan/in_progress/` |
| `/02_execute` Step 2+ | Reads plan file | ← `.pilot/plan/in_progress/` |
| `/02_execute` worktree | Creates lock file | `.pilot/plan/.locks/{plan}.lock` → `/03_close` removes |
| `/03_close` worktree | Releases lock file | Lock removed (or trap auto-removes on error) |
| `claude-pilot update --apply-statusline` | Adds statusLine to settings | Updates `.claude/settings.json` with backup |
| `claude-pilot init` | Syncs external skills | Downloads Vercel agent-skills to `.claude/skills/external/` |
| `claude-pilot init` | Sets up Codex MCP | Creates `.mcp.json` with GPT 5.2 config (if Codex installed) |
| `claude-pilot update` | Syncs external skills | Updates external skills from GitHub (skips if current) |
| `claude-pilot update` | Updates Codex MCP | Merges Codex config into `.mcp.json` (if Codex installed) |
| `/999_publish` Step 0.5 | Syncs templates (deprecated in v4.0.4) | `.claude/` → `src/claude_pilot/templates/.claude/` (replaced by build hook) |
| `/999_publish` Step 3-5 | Updates all 6 version files | pyproject.toml, __init__.py, config.py, install.sh, .pilot-version files |

---

## /999_publish Command Workflow

The `/999_publish` command prepares and deploys claude-pilot to PyPI. **Updated with Step 0.5 (2026-01-15)** to automatically sync templates before version bump. **Updated with Build Hook Pipeline (2026-01-17)** to generate assets at build time.

### Build-Time Asset Generation (v4.0.4)

**Architecture Overview**:
```
.claude/** (Development SoT)
      ↓
Hatchling Build Hook
      ↓
src/claude_pilot/assets/.claude/** (Packaged Assets)
      ↓
Wheel (contains only generated assets)
```

**Key Changes** (v4.0.4):
- **No committed templates mirror**: Assets generated at build time
- **AssetManifest**: Single Source of Truth for curated subset
- **sdist**: Contains `.claude/**` inputs for build hook
- **Wheel**: Contains only `src/claude_pilot/assets/.claude/**` (generated)
- **Verification**: Required/forbidden path checks

**Build Hook Configuration** (pyproject.toml):
```toml
[tool.hatch.build.targets.wheel.hooks.custom]
path = "src/claude_pilot/build_hook.py"

[tool.hatch.build.targets.wheel]
exclude = [".claude/**"]  # Build hook generates assets instead

[tool.hatch.build.targets.sdist]
include = [
  "src/claude_pilot/**/*.py",
  ".claude/**",  # Source files for build hook
  "pyproject.toml",
  "README.md",
  "LICENSE",
]
exclude = [
  ".claude/skills/external/**",
  ".claude/.external-skills-version",
  ".claude/commands/999_publish.md",
  ".pilot/**",
]
```

**AssetManifest Patterns**:
- **Include**: Core commands, agents, skills, guides, hooks, rules, settings.json
- **Exclude**: External skills, repo-dev-only commands (999_publish), .pilot directory
- **Special case**: settings.json (merge-only policy, never overwrite)

### Step Sequence

1. **Step 0.5: Sync Templates (CRITICAL)** - DEPRECATED (v4.0.4)
   - **NOTE**: This step is no longer needed with build-time asset generation
   - The build hook automatically generates assets from `.claude/**`
   - Kept for backward compatibility during transition

2. **Step 1: Pre-Flight Verification**
   - Check git status (must be clean)
   - Verify tests pass
   - Verify type check passes

3. **Step 2: Extract Current Version**
   - Parse pyproject.toml for version
   - Extract all 6 version locations:
     - pyproject.toml
     - src/claude_pilot/__init__.py
     - src/claude_pilot/config.py
     - install.sh
     - .claude/.pilot-version
     - src/claude_pilot/assets/.claude/.pilot-version (build-time generated)

4. **Step 3: Check Version Mismatch**
   - Compare all 6 version locations
   - Report mismatches if found
   - Exit if mismatch detected

5. **Step 4: Bump Version**
   - Prompt for new version (patch/minor/major)
   - Update all 6 version files
   - Commit version bump

6. **Step 5: Build & Verify**
   - Build package (`python3 -m build`)
   - Build hook generates assets automatically
   - Verify wheel contents (required paths present, forbidden paths absent)
   - Verify version in build artifacts
   - Run tests against built package

7. **Step 6: Deploy to PyPI**
   - Publish to PyPI
   - Verify deployment

8. **Step 7: Update .pilot-version Files**
   - Update .claude/.pilot-version
   - Build hook automatically updates src/claude_pilot/assets/.claude/.pilot-version
   - Verify all 6 files show new version

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| Build Hook (v4.0.4) | Generates assets | `.claude/**` → `src/claude_pilot/assets/.claude/**` |
| `/999_publish` Step 5 | Build & verify | Wheel with generated assets |
| `AssetManifest` | Curated subset | Include/exclude patterns |
| `verify_wheel_contents()` | Quality gate | Required/forbidden path checks |
| `/999_publish` Step 0.5 | Sync templates | DEPRECATED (build hook replaces) |
| `/999_publish` Step 4 | Checks version | Reads all 6 version files |
| `/999_publish` Step 5 | Updates version | Writes to all 6 version files |
| `scripts/sync-templates.sh` | Automates sync | DEPRECATED (build hook replaces) |
| `scripts/verify-version-sync.sh` | Verifies sync | Called after version update |

### Version File Locations

| File | Path | Purpose |
|------|------|---------|
| pyproject.toml | `/pyproject.toml` | Source of truth for package version |
| __init__.py | `/src/claude_pilot/__init__.py` | Runtime version access |
| config.py | `/src/claude_pilot/config.py` | Configuration version |
| install.sh | `/install.sh` | Installation script version |
| .pilot-version | `/.claude/.pilot-version` | Development template version |
| assets/.pilot-version | `/src/claude_pilot/assets/.claude/.pilot-version` | Deployment template version (build-time generated) |

---

## Interactive Recovery

### Trigger Conditions

- BLOCKING findings detected during auto-review
- No `--lenient` flag present
- Max 5 iterations

### Flow

```
BLOCKING > 0?
  |
  +-- Yes: Present findings
  |        |
  |        +-- AskUserQuestion for each BLOCKING
  |        |
  |        +-- Update plan with responses
  |        |
  |        +-- Re-run review
  |        |
  |        +-- BLOCKING = 0? → Exit
  |
  +-- No: Proceed to STOP
```

### Plan Update Format

```markdown
## External Service Integration
### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status |
|------|------|----|----------|----------|--------|
| [Description] | [Service] | [Service] | [Path] | [Package] | [New] |

[OR if skipped]
> ⚠️ SKIPPED: Deferred to implementation phase
```

---

## Gap Detection Categories

### External API

- SDK vs HTTP decision
- Endpoint verification
- Error handling strategy

### Database Operations

- Migration files required
- Rollback strategy
- Connection management

### Async Operations

- Timeout configuration
- Concurrent request limits
- Race condition prevention

### File Operations

- Path resolution (absolute vs relative)
- Existence checks before operations
- Cleanup strategy for temporary files

### Environment Variables

- Documentation in plan
- Existence verification
- No secrets in plan

### Error Handling

- No silent catches
- User notification strategy
- Graceful degradation

---

## Ralph Loop Integration

### Entry Point

- Immediately after first code change in `/02_execute`

### Verification Steps

1. Run tests
2. Type check
3. Lint check
4. Coverage report

### Iteration Logic

```
MAX_ITERATIONS = 7

WHILE NOT all_pass AND iterations < MAX:
    IF failures:
        Fix issues
        Run verification
    ELSE:
        Check completion
    iterations++
```

### Success Criteria

- All tests pass
- Coverage 80%+ (core 90%+)
- Type check clean
- Lint clean

---

## MCP Server Integration

### Recommended MCPs

| MCP | Purpose | Integration |
|-----|---------|-------------|
| context7 | Latest library docs | `@context7` for API lookup |
| serena | Semantic code operations | `@serena` for refactoring |
| grep-app | Advanced search | `@grep-app` for pattern search |
| sequential-thinking | Complex reasoning | `@sequential-thinking` for analysis |

### Configuration

Located in `.claude/settings.json`:
- Server definitions
- Connection parameters
- Tool mappings

---

## Hooks Integration

### PreToolUse Hook

- Runs before file edits
- Validates type check
- Validates lint status

### PostToolUse Hook

- Runs after file edits
- Type check validation
- Lint validation

### Stop Hook

- Runs at command end
- Checks TODO completion
- Enforces Ralph Loop continuation

### Hook Scripts

Located in `.claude/scripts/hooks/`:
- `typecheck.sh`: TypeScript validation
- `lint.sh`: ESLint/Pylint/gofmt
- `check-todos.sh`: Ralph continuation enforcement
- `branch-guard.sh`: Protected branch warnings

---

## Plan Management

### Directory Structure

```
.pilot/plan/
├── pending/        # Awaiting confirmation (created by /01_confirm)
├── in_progress/    # Currently executing (moved by /02_execute)
├── done/           # Completed plans (moved by /03_close)
└── active/         # Branch pointers (current plan per branch)
```

### Lifecycle

```
/01_confirm → pending/{timestamp}_{name}.md
/02_execute → in_progress/{timestamp}_{name}.md
/03_close   → done/{timestamp}_{name}.md
              active/{branch}.txt (pointer)
```

---

## Execution Context Handoff

### Purpose

Capture conversation state from `/00_plan` to ensure continuity between planning and execution.

### Components

| Component | Description | Source |
|-----------|-------------|--------|
| Explored Files | Files reviewed during planning | `/00_plan` file reads |
| Key Decisions | Architectural decisions made | `/00_plan` analysis |
| Implementation Patterns | Code examples, syntax, diagrams | Step 1.5 extraction |
| Assumptions | Validation needed during execution | Planner notes |
| Dependencies | External resource requirements | Gap Detection |

### Format

```markdown
## Execution Context (Planner Handoff)

### Explored Files
| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/01_confirm.md` | Current confirm command | 1-194 | Target for modification |

### Key Decisions Made
| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Option A (enhance /01_confirm) | Most direct fix | Option C (markers) |

### Implementation Patterns (FROM CONVERSATION)
#### Code Examples
> **FROM CONVERSATION:**
> ```typescript
> [exact code from /00_plan]
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> [exact command from /00_plan]
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> [exact diagram from /00_plan]
> ```
```

---

## CONTEXT.md Pattern (3-Tier Documentation)

### Purpose

CONTEXT.md files provide Tier 2 (Component-level) documentation for major folders, enabling efficient navigation and context discovery.

### Folder Structure

```
.claude/
├── commands/CONTEXT.md       # Command workflow and file list
├── guides/CONTEXT.md         # Guide usage and methodology patterns
├── skills/CONTEXT.md         # Skill list and auto-discovery mechanism
└── agents/CONTEXT.md         # Agent types and model allocation
```

### Standard Template

```markdown
# {Folder Name} Context

## Purpose
[What this folder does]

## Key Files
| File | Purpose | Lines |
|------|---------|-------|

## Common Tasks
- **Task**: Description

## Patterns
[Key patterns in this folder]

## Related Documentation
[Links to related guides, skills, commands]
```

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| CLAUDE.md | Links to CONTEXT.md files | Tier 1 → Tier 2 navigation |
| CONTEXT.md | Links to individual files | Component → File discovery |
| Individual files | Reference CONTEXT.md | File → Component context |

### Benefits

- **Fast Navigation**: Jump directly to relevant files
- **Context Discovery**: Understand folder purpose without opening all files
- **Token Efficiency**: CONTEXT.md loaded only when navigating to folder
- **Maintainability**: Single source of truth for folder structure

---

## Related Documentation

- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan definition
- `.claude/guides/prp-template.md` - PRP template (NEW 2026-01-17)
- `.claude/guides/claude-code-standards.md` - Official Claude Code standards (NEW)
- `.claude/guides/test-plan-design.md` - Test plan methodology (NEW 2026-01-17)
- `.claude/guides/worktree-setup.md` - Worktree setup script (NEW 2026-01-17)
- `.claude/commands/CONTEXT.md` - Command folder context (NEW)
- `.claude/guides/CONTEXT.md` - Guide folder context (NEW)
- `.claude/skills/CONTEXT.md` - Skill folder context (NEW)
- `.claude/agents/CONTEXT.md` - Agent folder context (NEW)
- `src/claude_pilot/CONTEXT.md` - Core package architecture, CLI patterns (NEW)
- `.claude/skills/documentation-best-practices/SKILL.md` - Documentation standards (NEW)
- `.claude/skills/vibe-coding/SKILL.md` - Code quality standards (Quick Reference, ~50 lines)
- `.claude/skills/vibe-coding/REFERENCE.md` - Code quality detailed guide (NEW 2026-01-17)
- `.claude/guides/gap-detection.md` - External service verification
- `.claude/skills/tdd/SKILL.md` - Test-driven development
- `.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration
- `.claude/guides/parallel-execution.md` - Parallel execution patterns

---

## Agent Invocation Patterns

### Agent File Format (YAML Frontmatter)

As of v3.2.0, all agent files use official Claude Code CLI YAML format:

**Valid Format**:
```yaml
---
name: coder
description: TDD implementation agent
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
skills: tdd, ralph-loop, vibe-coding, git-master
---

You are the Coder Agent. Implement features using TDD...
```

**Format Requirements**:
- `tools`: Comma-separated string (NOT array)
- `skills`: Comma-separated string (NOT array)
- `instructions`: Body content after `---` (NOT frontmatter field)

### Imperative Command Structure

As of v3.2.0, all agent invocations use **MANDATORY ACTION** sections with imperative language to ensure reliable agent delegation.

#### Pattern Structure

```markdown
### 🚀 MANDATORY ACTION: {Action Name}

> **YOU MUST invoke the following agents NOW using the Task tool.**
> This is not optional. Execute these Task tool calls immediately.

**EXECUTE IMMEDIATELY - DO NOT SKIP**:

[Specific Task tool calls with parameters]

**VERIFICATION**: After sending Task calls, wait for agents to return results before proceeding.
```

#### Key Components

| Component | Purpose | Example |
|-----------|---------|---------|
| 🚀 MANDATORY ACTION header | Visual emphasis for blocking action | "Parallel Agent Invocation" |
| YOU MUST invoke... NOW | Direct imperative command | "YOU MUST invoke the following agents NOW" |
| EXECUTE IMMEDIATELY - DO NOT SKIP | Emphasis on blocking nature | Prevents skipping to later steps |
| VERIFICATION instruction | Wait directive | "wait for both agents to return" |
| "send in same message" | Parallel execution hint | For concurrent Task calls |

### Command-Specific Patterns

| Command | Step | Agents | Pattern |
|---------|------|--------|---------|
| `/00_plan` | Step 0 | explorer + researcher | Parallel: "send in same message" |
| `/01_confirm` | Step 4 | plan-reviewer | Sequential: Single Task call |
| `/02_execute` | Step 3 | coder | Sequential: Single Task call with TDD |
| `/02_execute` | Step 3.5 | tester + validator + code-reviewer | Parallel: "send in same message" |
| `/02_execute` | Step 3.6 | coder (conditional) | Sequential: Feedback loop if critical issues |
| `/03_close` | Step 5 | documenter | Sequential: Single Task call |
| `/90_review` | Main | plan-reviewer | Sequential or parallel (3-angle) |
| `/91_document` | Main | documenter | **OPTIONAL**: May use main thread |

---

## Parallel Execution Integration

### Overview

claude-pilot supports parallel agent execution for maximum workflow efficiency. This reduces execution time by 50-70% while improving quality through agent specialization.

### Parallel Patterns by Command

#### /00_plan: Parallel Exploration

```
Main Orchestrator
       │
       ├─► Explorer Agent (Haiku) - Codebase exploration
       └─► Researcher Agent (Haiku) - External docs research
              ↓
       [Result Merge → Plan Creation]
```

**Implementation**:
- Uses **MANDATORY ACTION** section at Step 0
- Two Task calls sent in **same message** for true parallelism
- Explorer returns: Explored Files table, Key Decisions
- Researcher returns: Research Findings table with sources
- VERIFICATION checkpoint ensures both complete before proceeding

#### /02_execute: Parallel SC Implementation

```
Main Orchestrator
       │
       ├─► Coder-SC1 (Sonnet) - Independent SC
       ├─► Coder-SC2 (Sonnet) - Independent SC
       ├─► Coder-SC3 (Sonnet) - Independent SC
              ↓
       [Result Integration]
              ↓
       ├─► Tester Agent (Sonnet) - Test execution
       ├─► Validator Agent (Haiku) - Type+Lint+Coverage
       └─► Code-Reviewer Agent (Opus) - Deep review
              ↓
       [Ralph Loop Verification]
```

**Implementation**:
- Uses **MANDATORY ACTION** sections at Steps 3, 3.5, and 3.6
- SC dependency analysis before parallel execution
- Independent SCs run concurrently (one Task call per SC)
- Verification agents run in parallel after integration (Step 3.5)
- Review feedback loop for critical findings (Step 3.6, max 3 iterations)
- VERIFICATION checkpoints after each parallel phase
- Code-reviewer uses Opus for catching async bugs, memory leaks

#### /01_confirm & /90_review: Agent Delegation

```
/01_confirm → Plan-Reviewer Agent (Sonnet)
            - Gap Detection Review
            - Interactive Recovery for BLOCKING issues

/90_review → Plan-Reviewer Agent (Sonnet)
            - Multi-angle parallel review (optional)
            - Security, Quality, Testing, Architecture
```

### Agent Invocation Syntax

```markdown
Task:
  subagent_type: {agent_name}
  prompt: |
    {task_description}
    {context}
    {expected_output}
```

### Model Allocation for Parallel Work

| Model | Parallel Tasks | Rationale |
|-------|----------------|-----------|
| Haiku | explorer, researcher, validator | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Quality + speed balance |
| Opus | code-reviewer | Deep reasoning for critical review |

### File Conflict Prevention

- Each parallel agent works on different files
- SC dependency analysis identifies file ownership
- Clear merge strategy after parallel phase
- Integration tests verify merged results

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` | Parallel: Explorer + Researcher | → Merged plan structure |
| `/02_execute` | Parallel: Coder (per SC) | → Integrated code |
| `/02_execute` | Parallel: Tester + Validator + Code-Reviewer | → Verification results |
| `/01_confirm` | Delegates to plan-reviewer | → Gap Detection report |

### Benefits

| Benefit | Impact |
|---------|--------|
| Speed | 50-70% execution time reduction |
| Context Isolation | 8x token efficiency |
| Quality | Specialized agents per task |
| Scalability | Independent tasks run concurrently |

---

**Last Updated**: 2026-01-17 (GPT Delegation Improvements)
**Version**: 4.0.5
