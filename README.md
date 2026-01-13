# claude-pilot

> Your Claude Code copilot - Structured workflows, SPEC-First TDD, Ralph Loop automation, and context engineering. Fly with discipline.

---

## Quick Start

```bash
# Clone and install
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot
./install.sh

# Or copy to existing project
cp -r .claude /path/to/your/project/
cp CLAUDE.md /path/to/your/project/
```

---

## What is claude-pilot?

**claude-pilot** is an opinionated preset for Claude Code that brings structure and discipline to AI-assisted development. It provides:

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **Hierarchical Context**: Layered documentation (L0-L3) for efficient token usage
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Multilingual**: Runtime language selection (English/Korean/Japanese)

---

## Core Workflow

```
/00_plan     → Create spec-driven plan with PRP format
/01_confirm  → Review and approve plan
/02_execute  → Execute with Ralph Loop + TDD
/03_close    → Complete and commit
/90_review   → Auto-review code (multi-angle)
/91_document → Auto-document changes
```

---

## Project Structure

```
claude-pilot/
├── README.md
├── install.sh              # One-line installation
├── mcp.json                # Recommended MCP servers
├── CLAUDE.md               # Main project guide
├── AGENTS.md               # Agent configuration
├── .claude/
│   ├── settings.json       # Hooks, LSP, language config
│   ├── commands/           # Slash commands (6)
│   ├── templates/          # CONTEXT.md, SKILL.md, PRP.md
│   ├── guides/             # Methodology guides
│   └── scripts/hooks/      # Typecheck, lint, todos, branch
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Plans awaiting confirmation
│       ├── in_progress/    # Active plans
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
└── examples/               # Sample configurations
```

---

## Features

### 1. SPEC-First Development

Every feature starts with clear requirements:
- **What**: Functionality description
- **Why**: Business value and context
- **How**: Implementation approach
- **Success Criteria**: Measurable acceptance criteria
- **Constraints**: Technical/time/resource limits

### 2. Ralph Loop TDD

Autonomous iteration pattern:
1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Clean up while keeping tests green
4. **Repeat**: Until all criteria met

### 3. Hierarchical Context

Optimized token usage with layered documentation:
- **L0** (Immediate): Quick reference, 30-second context
- **L1** (Structural): Architecture, patterns, workflows
- **L2** (Detailed): Implementation details, best practices
- **L3** (Reference): Deep dives, history, alternatives

### 4. Integrated Hooks

Automation at key points:
- **PreToolUse**: Type checking, linting before edits
- **PostToolUse**: Validation after changes
- **Stop**: Todo completion verification (Ralph continuation)

---

## Installation

### Option 1: One-line Install

```bash
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot && ./install.sh
```

The installer will:
1. Detect your project type
2. Ask for language preference (en/ko/ja)
3. Copy template files
4. Configure hooks for your stack
5. Set up recommended MCPs

### Option 2: Manual Install

```bash
# Clone the template
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot

# Copy to your project
cp -r .claude /path/to/your/project/
cp CLAUDE.md /path/to/your/project/
cp AGENTS.md /path/to/your/project/

# Edit CLAUDE.md with your project info
nano /path/to/your/project/CLAUDE.md
```

---

## Configuration

### Language Settings

Edit `.claude/settings.json`:

```json
{
  "language": "en"  // Options: en, ko, ja
}
```

### MCP Servers

Recommended MCPs (auto-installed):

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |

### Hook Customization

Edit `.claude/settings.json` hooks section:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": ".claude/scripts/hooks/typecheck.sh"}]
      }
    ]
  }
}
```

---

## Usage Examples

### Start a New Feature

```bash
# In Claude Code
/00_plan "Add user authentication with JWT"

# Review the generated plan in .pilot/plan/pending/
# Edit if needed, then:

/01_confirm  # Approve the plan

/02_execute  # Execute with TDD + Ralph Loop
```

### Auto-Document Changes

```bash
# After completing work
/91_document

# Automatically updates:
# - CLAUDE.md
# - CONTEXT.md files
# - API documentation
```

### Multi-Angle Review

```bash
# Before committing
/90_review security performance accessibility

# Reviews code from multiple perspectives
```

---

## Development Workflow

### 1. Planning Phase

```
User Request
    ↓
/00_plan → Creates PRP in .pilot/plan/pending/
    ↓
Manual Review/Edit
    ↓
/01_confirm → Moves to .pilot/plan/in_progress/
```

### 2. Execution Phase

```
/02_execute
    ↓
Create Todo List from Plan
    ↓
Ralph Loop:
  1. Write test (Red)
  2. Implement (Green)
  3. Refactor
  4. Verify
    ↓
Repeat until all pass
    ↓
/03_close → Archive to .pilot/plan/done/
```

### 3. Documentation Phase

```
/91_document
    ↓
Analyze changes
    ↓
Update CONTEXT.md hierarchy
    ↓
Update CLAUDE.md
    ↓
Commit with docs
```

---

## Inspiration & Credits

claude-pilot synthesizes best practices from these projects:

### Core Methodology

- **[context-engineering-intro](https://github.com/coleam00/context-engineering-intro)**
  - Hierarchical CONTEXT.md structure
  - PRP (Product Requirements Prompt) pattern

- **[moai-adk](https://github.com/modu-ai/moai-adk)**
  - SPEC-First TDD methodology
  - Multilingual support architecture

- **[oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)**
  - Ralph Loop autonomous iteration
  - Todo continuation enforcement

### Official Resources

- **[Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
  - Official Anthropic guidelines

---

## Guides

- [Context Engineering Guide](.claude/guides/context-engineering.md)
- [Ralph Loop & TDD Guide](.claude/guides/ralph-loop-tdd.md)
- [Prompts Design Guide](.claude/guides/prompts-design-guide.md)
- [Getting Started](GETTING_STARTED.md)

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`/00_plan "your feature"`)
3. Follow TDD workflow (`/02_execute`)
4. Ensure tests pass
5. Submit PR with `/90_review` output

---

## License

MIT License - Free to use, modify, and distribute.

---

## FAQ

### Q: Can I use this for commercial projects?
A: Yes, MIT license allows commercial use.

### Q: How do I disable hooks?
A: Edit `.claude/settings.json` and remove unwanted hooks from the hooks section.

### Q: Can I add my own MCPs?
A: Yes, add them to `.claude/settings.json` under the mcp section.

### Q: What if I don't want TDD?
A: Ralph Loop can be configured to skip tests. Edit `/02_execute` command to adjust.

### Q: How do I add a new language?
A: Create translation files in `.claude/locales/` and add language code to settings.json.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/changoo89/claude-pilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/changoo89/claude-pilot/discussions)

---

**Built with inspiration from the Claude Code community.**
