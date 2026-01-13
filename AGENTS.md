# AGENTS.md

> **Last Updated**: 2025-01-13
> **Template**: claude-pilot

---

## Overview

This document describes the Claude Code agent patterns used in this project.

---

## Agent Patterns

### 1. Planner Agent

**Purpose**: Creates SPEC-First execution plans

**Trigger**: `/00_plan` command

**Responsibilities**:
- Analyze codebase context
- Gather requirements through dialogue
- Design execution approach
- Define success criteria
- Create test scenarios

**Output**: Plan file in `.pilot/plan/pending/`

**Tools**:
- Read, Glob, Grep (exploration)
- WebSearch (external docs)
- AskUserQuestion (clarification)

---

### 2. Executor Agent

**Purpose**: Executes plans with TDD + Ralph Loop

**Trigger**: `/02_execute` command

**Responsibilities**:
- Convert plan to todos
- Implement with Red-Green-Refactor
- Run verification (tests, types, lint)
- Iterate until all pass
- Track progress

**Output**: Completed work ready for review

**Tools**:
- Read, Write, Edit (code changes)
- Bash (tests, type check, lint)
- TodoWrite (progress tracking)

---

### 3. Reviewer Agent

**Purpose**: Multi-angle code analysis

**Trigger**: `/90_review` command

**Responsibilities**:
- Mandatory reviews (8 items)
- Extended reviews (by type)
- Autonomous discoveries
- Security analysis
- Performance evaluation

**Output**: Review findings report

**Tools**:
- Read, Glob, Grep (code analysis)
- Bash(git) (history)

---

### 4. Documenter Agent

**Purpose**: Auto-syncs documentation

**Trigger**: `/91_document` command

**Responsibilities**:
- Update CLAUDE.md
- Generate CONTEXT.md files
- Archive TDD artifacts
- Verify documentation sync

**Output**: Updated documentation

**Tools**:
- Read, Write (doc changes)
- Bash(git) (change analysis)

---

## Agent Coordination

### Workflow

```
/00_plan → /01_confirm → /02_execute → /90_review → /91_document → /03_close
   ↓          ↓           ↓            ↓             ↓            ↓
 Planner    Confirm    Executor     Reviewer    Documenter    Closer
```

### Handoff Points

1. **Plan → Confirm**: Pending plan approved
2. **Confirm → Execute**: Plan moved to in-progress
3. **Execute → Review**: Code ready for review
4. **Review → Document**: Changes approved
5. **Document → Close**: Documentation synced

---

## Agent Configuration

### Settings

Agent behavior configured in `.claude/settings.json`:
- Language preference
- Tool permissions
- Hook triggers
- LSP configuration
- MCP servers

### Hooks

Hooks enforce agent behavior:
- **Type check**: Ensure code quality
- **Lint**: Maintain code style
- **Check todos**: Ralph continuation
- **Branch guard**: Protected branch safety

---

## Customization

### Adding New Agents

1. Create command in `.claude/commands/`
2. Define purpose and responsibilities
3. Specify allowed tools
4. Document workflow integration

### Modifying Agent Behavior

1. Edit command file in `.claude/commands/`
2. Adjust permissions in `allowed-tools`
3. Update workflow in this document

---

## Best Practices

### Agent Design

- **Single Responsibility**: Each agent has one primary job
- **Clear Inputs/Outputs**: Well-defined handoff points
- **Verifiable**: Each agent produces evidence of work
- **Idempotent**: Can be re-run safely

### Agent Coordination

- **Sequential**: Agents work in defined order
- **Non-blocking**: Each agent can work independently
- **Traceable**: All work logged and tracked

---

## Troubleshooting

### Agent Failures

| Symptom | Cause | Solution |
|---------|-------|----------|
| Plan not found | No plan created | Run `/00_plan` first |
| Permission denied | Tool not allowed | Update `allowed-tools` |
| Hook failure | Script error | Check hook script |
| Todo incomplete | Ralph continuation | Complete todos before close |

### Debug Mode

Enable verbose logging:
```bash
# Set environment variable
export CLAUDE_DEBUG=1

# Run command
/02_execute
```

---

## Related Documentation

- [Command Reference](.claude/commands/)
- [Hooks Guide](.claude/scripts/hooks/)
- [Settings](.claude/settings.json)

---

**Template Version**: claude-pilot 1.0.0
