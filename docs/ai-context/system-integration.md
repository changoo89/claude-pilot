# System Integration Guide

> **Purpose**: Component interactions, workflows, and integration points
> **Last Updated**: 2026-01-20 (Plan Detection Fix and Statusline Enhancement v4.3.2)
> **Note**: This is a router/overview file. See topic-specific files for detailed information.

---

## Quick Navigation

| Topic | File | Purpose |
|-------|------|---------|
| **Plugin Architecture** | @plugin-architecture.md | Plugin manifests, setup, hooks |
| **CI/CD Integration** | @cicd-integration.md | GitHub Actions, releases |
| **Codex Delegation** | @codex-integration.md | GPT expert consultation |
| **Continuation System** | @continuation-system.md | Agent persistence across sessions |
| **Project Structure** | @project-structure.md | Directory layout, key files |
| **Agent Ecosystem** | @agent-ecosystem.md | Agent configurations |
| **MCP Servers** | @mcp-servers.md | Recommended MCP servers |
| **Testing & Quality** | @testing-quality.md | Coverage, quality gates |
| **Documentation** | @docs-overview.md | 3-Tier system navigation |

---

## Slash Command Workflow

### Core Commands

| Command | Phase | Description |
|---------|-------|-------------|
| `/00_plan` | Planning | Create SPEC-First plan |
| `/01_confirm` | Planning | Review plan, verify requirements |
| `/02_execute` | Execution | Implement with TDD |
| `/03_close` | Completion | Archive plan, create commit |
| `/review` | Quality | Multi-angle code review |
| `/document` | Maintenance | Sync documentation |
| `/setup` | Setup | Initialize new project |
| `/999_release` | Release | Bump version, git tag |

### Workflow Sequence

```
User Request
       ↓
/00_plan (read-only exploration)
       ↓
/01_confirm (requirements verification)
       ↓
/02_execute (TDD + Ralph Loop)
       ↓
/03_close (archive + commit)
       ↓
/review (anytime - optional)
```

**Full details**: @.claude/commands/CONTEXT.md

### Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan
- **CANNOT DO**: Edit files, Write files, Create code, Implement

**Implementation Phase**: Starts ONLY after `/01_confirm` → `/02_execute`

**Full details**: @.claude/commands/00_plan.md (Phase Boundary Protection section)

---

## Key Integration Points

### Plugin Architecture

**Components**: Plugin manifests, MCP configuration, hooks

**Integration Flow**:
```
.claude-plugin/plugin.json → Claude Code CLI loads plugin
/pilot:setup → .mcp.json (merge strategy)
.claude/hooks.json → Claude Code hooks system
```

**Full details**: @plugin-architecture.md

### Codex Delegation

**Purpose**: Intelligent GPT expert consultation for complex tasks

**Trigger Examples**:
- Architecture decisions
- Security reviews
- 2+ failed fix attempts
- Large plans (5+ SCs)

**Full details**: @codex-integration.md

### Continuation System

**Purpose**: Agent persistence across sessions until completion

**State File**: `.pilot/state/continuation.json`

**Full details**: @continuation-system.md

### CI/CD Integration

**Purpose**: Automated release creation on git tag push

**Workflow**: Tag push → Version validation → GitHub Release

**Full details**: @cicd-integration.md

---

## Command Workflows

### /00_plan (Planning)

**Purpose**: Create SPEC-First plan through dialogue

**Process**:
1. Collect user requirements verbatim
2. Parallel exploration (Explorer + Researcher)
3. PRP definition (What/Why/How)
4. Test plan design
5. Present plan summary

**Full details**: @.claude/commands/00_plan.md

### /02_execute (Implementation)

**Purpose**: Implement features using TDD + Ralph Loop

**Process**:
1. Plan detection (MANDATORY, glob-safe with `find`)
2. Atomic plan state transition
3. Coder Agent execution
4. Parallel verification (Tester + Validator + Code-Reviewer)
5. Ralph Loop iteration

**Plan Detection Fix (v4.3.2)**:
- Fixed zsh glob failure when plan directories empty
- Uses `find` with `xargs` for portable empty-directory handling
- Cross-shell compatible (bash/zsh)

**Full details**: @.claude/commands/02_execute.md

### /03_close (Completion)

**Purpose**: Archive plan and create commit

**Process**:
1. Move plan to done/
2. Worktree cleanup (if applicable)
3. Create git commit
4. Safe git push with retry logic

**Full details**: @.claude/commands/03_close.md

---

## Development Workflow

### SPEC-First Development

1. **What**: Functionality requirements
2. **Why**: Context and business value
3. **How**: Implementation strategy
4. **Success Criteria**: Measurable outcomes

**Full methodology**: @.claude/guides/prp-framework.md

### TDD Cycle

1. **Red**: Write failing test
2. **Green**: Implement minimal code
3. **Refactor**: Clean up while green

**Full methodology**: @.claude/skills/tdd/SKILL.md

### Ralph Loop

**Purpose**: Autonomous iteration until quality gates pass

**Verification**: Tests, type-check, lint, coverage

**Full methodology**: @.claude/skills/ralph-loop/SKILL.md

---

## Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient |
| **Sonnet** | coder, tester, plan-reviewer | Balanced quality/speed |
| **Opus** | code-reviewer | Deep reasoning |

**Full details**: @agent-ecosystem.md

---

## MCP Servers

**Recommended Servers**:
- **context7**: Documentation navigation
- **serena**: Code operations
- **grep-app**: Fast code search
- **sequential-thinking**: Complex reasoning
- **codex**: GPT delegation

**Configuration**: `mcp.json`

**Full details**: @mcp-servers.md

---

## Quality Gates

Before marking work complete:

- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Documentation updated

**Full details**: @testing-quality.md

---

## Documentation System

### 3-Tier Hierarchy

| Tier | Location | Purpose | Max Lines |
|------|----------|---------|----------|
| **Tier 1** | `CLAUDE.md` | Project standards | 300 |
| **Tier 2** | `docs/ai-context/*.md` | System integration | 500 |
| **Tier 3** | `{component}/CONTEXT.md` | Component details | 200 |

**Full details**: @docs-overview.md

---

## See Also

**Command Documentation**:
- @.claude/commands/CONTEXT.md - Command workflow and file list
- @.claude/guides/CONTEXT.md - Guide usage and methodology

**Skill Documentation**:
- @.claude/skills/CONTEXT.md - Skill list and auto-discovery
- @.claude/skills/tdd/SKILL.md - Test-driven development
- @.claude/skills/ralph-loop/SKILL.md - Autonomous iteration

**Quality Standards**:
- @.claude/guides/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/claude-code-standards.md - Official Claude Code standards

---

**Version**: claude-pilot 4.3.0 (System Integration Router)
**Last Updated**: 2026-01-19
