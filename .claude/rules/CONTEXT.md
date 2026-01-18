# Rules Context

## Purpose

Delegation and workflow rules for intelligent GPT expert consultation and core development standards. Rules provide structured patterns for autonomous decision-making, progressive escalation, and code quality enforcement.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `core/workflow.md` | SPEC-First development workflow | 43 | TDD cycle, Ralph Loop, Vibe Coding standards |
| `delegator/orchestration.md` | GPT delegation orchestration | 566 | Codex integration, expert routing, stateless design |
| `delegator/triggers.md` | Delegation trigger patterns | 289 | Explicit, semantic, and description-based triggers |
| `delegator/pattern-standard.md` | Unified GPT delegation pattern | 217 | Trigger detection, graceful fallback, execution flow |
| `delegator/delegation-format.md` | 7-section delegation prompt format | 288 | Standardized delegation prompt structure |
| `delegator/intelligent-triggers.md` | Heuristic-based autonomous delegation | 344 | Failure escalation, ambiguity detection, complexity assessment |
| `delegator/model-selection.md` | GPT expert directory and selection | 120 | Expert specialties, operating modes, sandbox types |
| `delegator/delegation-checklist.md` | Delegation prompt validation checklist | 91 | Quality checks before Codex calls |
| `delegator/prompts/architect.md` | GPT Architect system instructions | 78 | System design, tradeoffs, complex debugging |
| `delegator/prompts/plan-reviewer.md` | GPT Plan Reviewer system instructions | 164 | Plan validation, gap detection, completeness check |
| `delegator/prompts/scope-analyst.md` | GPT Scope Analyst system instructions | 103 | Pre-planning analysis, ambiguity detection |
| `delegator/prompts/code-reviewer.md` | GPT Code Reviewer system instructions | 100 | Code quality, bugs, maintainability |
| `delegator/prompts/security-analyst.md` | GPT Security Analyst system instructions | 99 | Vulnerabilities, threat modeling, hardening |
| `delegator/examples/before-phase-detection.md` | Before pattern: phase context missing | 92 | Example of problematic delegation |
| `delegator/examples/after-phase-detection.md` | After pattern: phase context explicit | 144 | Example of correct delegation |
| `delegator/examples/before-stateless.md` | Before pattern: no iteration history | 139 | Example of stateless violation |
| `delegator/examples/after-stateless.md` | After pattern: full history included | 245 | Example of stateless compliance |
| `documentation/tier-rules.md` | Documentation tier system rules | 54 | L0-L3 hierarchy, content organization |

**Total**: 18 files, 3,275 lines (average: 182 lines per file)

## Common Tasks

### Delegate to GPT Expert
- **Task**: Route task to appropriate GPT expert based on triggers
- **Rule**: @.claude/rules/delegator/triggers.md
- **Output**: Expert consultation with 7-section delegation prompt
- **Process**:
  1. **STOP**: Scan for trigger signals (explicit, semantic, description-based)
  2. **MATCH**: Identify expert type (Architect, Plan Reviewer, Scope Analyst, Code Reviewer, Security Analyst)
  3. **READ**: Load expert prompt file from @.claude/rules/delegator/prompts/
  4. **CHECK**: Verify Codex CLI installed (graceful fallback if not)
  5. **EXECUTE**: Call `codex-sync.sh` with appropriate mode (read-only or workspace-write)
  6. **CONFIRM**: Log delegation decision

**Graceful Fallback** (MANDATORY):
```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0  # NOT an error, continue with Claude
fi
```

### Detect Delegation Triggers
- **Task**: Identify when GPT delegation should occur
- **Rule**: @.claude/rules/delegator/intelligent-triggers.md
- **Output**: Decision to delegate or continue with Claude
- **Triggers**:
  - **Explicit**: User says "ask GPT", "consult GPT"
  - **Failure-based**: Agent fails 2+ times on same task
  - **Ambiguity**: Vague requirements, no success criteria (score ≥ 0.5)
  - **Complexity**: 10+ success criteria (score ≥ 0.7)
  - **Risk**: Auth/credential keywords (score ≥ 0.4)
  - **Description-based**: Agent description includes "use proactively"

### Build Delegation Prompt
- **Task**: Construct 7-section delegation prompt
- **Rule**: @.claude/rules/delegator/delegation-format.md
- **Output**: Complete delegation prompt with expert instructions
- **Structure**:
  1. **TASK**: One-sentence atomic goal
  2. **EXPECTED OUTCOME**: What success looks like
  3. **CONTEXT**: Phase, current state, relevant files, iteration history
  4. **CONSTRAINTS**: Technical, patterns, limitations
  5. **MUST DO**: Specific requirements (2-3 items)
  6. **MUST NOT DO**: Forbidden actions (2-3 items)
  7. **OUTPUT FORMAT**: How to structure response

**Critical**: Include full iteration history for retries (stateless design).

### Apply Progressive Escalation
- **Task**: Escalate to GPT after Claude failures
- **Rule**: @.claude/rules/delegator/intelligent-triggers.md
- **Output**: Fresh perspective from GPT expert
- **Pattern**:
  - Attempt 1 (Claude) → Fail → Retry with Claude
  - Attempt 2 (Claude) → Fail → Delegate to GPT Architect
  - Attempt 3 (GPT) → Success

**Cost Efficiency**: One well-structured delegation with full history < multiple vague attempts.

### Enforce Code Quality Standards
- **Task**: Apply Vibe Coding standards during implementation
- **Rule**: @.claude/rules/core/workflow.md
- **Output**: Clean, maintainable code
- **Standards**:
  - **Functions**: ≤50 lines
  - **Files**: ≤200 lines
  - **Nesting**: ≤3 levels
  - **Principles**: SRP, DRY, KISS, Early Return

### Validate Delegation Prompt
- **Task**: Verify delegation prompt quality before Codex call
- **Rule**: @.claude/rules/delegator/delegation-checklist.md
- **Output**: Validated delegation prompt or corrections
- **Checks**:
  - Phase context specified (Planning vs Implementation)
  - 7-section format compliance
  - Stateless design (full context included)
  - Expert-specific requirements met
  - Token budget awareness (8K-16K target)

## Patterns

### Stateless Design Pattern

**Each delegation is independent** - GPT has no memory of previous calls.

**Required context in every delegation**:
- User's original request (verbatim)
- Relevant file paths or code snippets
- Previous attempts and results (if retry)
- Current iteration count
- Phase context (Planning vs Implementation)

**Example**:
```markdown
CONTEXT:
- Phase: IMPLEMENTATION (code should exist now)
- Original request: "Fix authentication bug"
- Relevant files: src/auth/login.ts
- Previous iterations:
  - Attempt 1: Added JWT validation → Failed: TypeError
  - Attempt 2: Moved middleware after body parser → Failed: 401 on all requests
  - Current iteration: 3
```

### Progressive Escalation Pattern

**Delegate ONLY after 2nd failure** (not first):

```
Attempt 1 (Claude) → Fail
     ↓
Attempt 2 (Claude) → Fail
     ↓
Attempt 3 (GPT Architect) → Success
```

**Prevents**: Unnecessary Codex calls (cost efficiency)

### Phase Detection Pattern

**Always specify phase** when delegating to Plan Reviewer:

| Phase | Context Indicators | Focus |
|-------|-------------------|-------|
| **Planning** | "plan", "design", "proposed" | Plan clarity, completeness |
| **Implementation** | "implemented", "created", "done" | File system verification |

**Decision Rule**: Count indicators → Select phase with higher count → Default to Planning if tie

**Example Prompt**:
```markdown
CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: [full plan content]
```

### Graceful Fallback Pattern

**MANDATORY**: All GPT delegation points must include graceful fallback.

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

### 7-Section Delegation Format

**Standard structure** for all delegation prompts:

```markdown
1. TASK: [One sentence—atomic, specific goal]

2. EXPECTED OUTCOME: [What success looks like]

3. CONTEXT:
   - Phase: [PLANNING / IMPLEMENTATION]
   - Original request: [verbatim user input]
   - Relevant files: [paths or snippets]
   - Iteration history: [attempts and results]

4. CONSTRAINTS:
   - Technical: [versions, dependencies]
   - Patterns: [existing conventions]
   - Limitations: [what cannot change]

5. MUST DO:
   - [Requirement 1]
   - [Requirement 2]

6. MUST NOT DO:
   - [Forbidden action 1]
   - [Forbidden action 2]

7. OUTPUT FORMAT:
   - [How to structure response]
```

**Purpose**: Ensures consistent, complete delegation prompts.

### GPT Expert Mapping

**Situation → Expert** routing:

| Situation | Expert | Mode |
|-----------|--------|------|
| Security-related code | Security Analyst | Advisory |
| Large plan (5+ SCs) | Plan Reviewer | Advisory |
| Architecture decisions | Architect | Advisory |
| 2+ failed fix attempts | Architect | Implementation |
| Coder blocked (automatic) | Architect | Implementation |

**Operating Modes**:
- **Advisory** (read-only): Analysis, recommendations
- **Implementation** (workspace-write): Making changes, fixing issues

## Expert Categories

### Analysis Experts
- **Architect**: System design, tradeoffs, complex debugging
- **Plan Reviewer**: Plan validation, gap detection
- **Scope Analyst**: Pre-planning analysis, ambiguity detection

### Review Experts
- **Code Reviewer**: Code quality, bugs, maintainability
- **Security Analyst**: Vulnerabilities, threat modeling, hardening

## File Organization

### Naming Convention
- **Core rules**: `core/{rule-name}.md`
- **Delegator rules**: `delegator/{category}/{rule-name}.md`
- **Expert prompts**: `delegator/prompts/{expert}.md`
- **Examples**: `delegator/examples/{before|after}-{pattern}.md`

### Size Guidelines
**Target**: 150-200 lines per rule file

**When to split**:
- If rule exceeds 200 lines
- Extract examples to separate files
- Use cross-references for related rules

## Delegation Flow

### Complete Flow
```
1. STOP: Check for triggers
       ↓
2. MATCH: Identify expert type
       ↓
3. READ: Load expert prompt file
       ↓
4. CHECK: Verify Codex CLI (graceful fallback)
       ↓
5. BUILD: Construct 7-section prompt with full context
       ↓
6. EXECUTE: Call codex-sync.sh (read-only or workspace-write)
       ↓
7. CONFIRM: Log delegation decision
```

### State Management

**Continuation State Integration** (Sisyphus System):
- Track iteration count in `.pilot/state/continuation.json`
- Include iteration history in delegation context
- Resume from last checkpoint if session interrupted
- Max iterations: 7 (configurable via `MAX_ITERATIONS`)

## See Also

**Delegation system**:
- @.claude/scripts/codex-sync.sh - Codex CLI integration script
- @.claude/guides/intelligent-delegation.md - Delegation methodology (if exists)

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and delegation integration

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command delegation patterns

**Documentation standards**:
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
