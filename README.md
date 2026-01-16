# claude-pilot

> Your Claude Code copilot - Structured workflows, SPEC-First TDD, Ralph Loop automation, and context engineering. Fly with discipline.

---

## Quick Start

```bash
# Install CLI globally
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash

# Initialize in your project
cd your-project
claude-pilot init .

# Start planning
claude-pilot version
```

---

## What is claude-pilot?

**claude-pilot** is an opinionated preset for Claude Code that brings structure and discipline to AI-assisted development. It provides:

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **3-Tier Documentation**: Foundation/Component/Feature hierarchy for efficient context
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Migration Support**: Auto-generate docs for existing projects with `/92_init`
- **Multilingual**: Runtime language selection (English/Korean/Japanese)

---

## Core Workflow

```
/92_init     → Initialize 3-Tier Documentation (for existing projects)
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
├── install.sh              # One-line CLI installer
├── pyproject.toml          # Python package config
├── CLAUDE.md               # Main project guide
├── .claude/agents/         # Agent configurations (8 agents)
├── .claude/
│   ├── settings.json       # Hooks, LSP, language config
│   ├── commands/           # Slash commands (7)
│   ├── templates/          # CONTEXT.md, SKILL.md, Tier templates
│   └── scripts/hooks/      # Typecheck, lint, todos, branch
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Plans awaiting confirmation
│       ├── in_progress/    # Active plans
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
└── src/                    # Python CLI source
    └── claude_pilot/       # CLI package
        ├── __init__.py
        ├── __main__.py
        ├── cli.py          # Click commands (init, update, version)
        ├── config.py       # Configuration constants
        ├── initializer.py   # Project initialization
        ├── updater.py      # Update logic with merge strategies
        └── templates/      # Bundled template files
            ├── .claude/     # Template files
            │   ├── commands/
            │   ├── templates/
            │   ├── scripts/hooks/
            │   └── settings.json
            ├── .pilot/
            │   └── plan/
            └── CLAUDE.md.template
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

### 3. 3-Tier Documentation System

Optimized token usage with hierarchical documentation:
- **Tier 1** (CLAUDE.md): Project foundation, rarely changes
- **Tier 2** (Component): Architecture, integration, occasionally changes
- **Tier 3** (Feature): Implementation details, frequently changes

Run `/92_init` in existing projects to auto-generate this structure.

### 4. Integrated Hooks

Automation at key points:
- **PreToolUse**: Type checking, linting before edits
- **PostToolUse**: Validation after changes
- **Stop**: Todo completion verification (Ralph continuation)

---

## Installation

### Step 1: Install CLI (One-time)

Install the claude-pilot CLI globally using pipx or pip:

```bash
# One-line install (automatically detects pipx or pip)
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash

# Or manually with pipx (recommended)
pipx install claude-pilot

# Or with pip
pip3 install --user claude-pilot
```

**What gets installed:**
- `claude-pilot` command globally available
- Templates bundled in package (offline-capable)
- No project files modified yet

### Step 2: Initialize Your Project

Navigate to your project and initialize:

```bash
cd your-project

# Initialize with interactive language selection
claude-pilot init .

# Or specify language directly
claude-pilot init . --lang en

# Or non-interactive mode (for CI/CD)
claude-pilot init . -y --lang en
```

**What gets created:**
- `.claude/` - Commands, templates, hooks, settings
- `.pilot/` - Plan management directories
- `CLAUDE.md` - Project documentation template
- Configured with your selected language

### Step 3: Update (Optional)

Update to the latest version:

```bash
# Auto merge (default - preserves your files)
claude-pilot update

# Manual merge (generates guide for manual review)
claude-pilot update --strategy manual
```

**What gets updated:**
- Core commands (00-03, 90-92)
- Templates and hooks
- Version tracking

**What gets preserved:**
- Your `CLAUDE.md` customizations
- Your `.claude/settings.json`
- Your `.pilot/` plans
- Custom commands you've added

### Manual Install (Alternative)

If you prefer manual setup or can't use the installer:

```bash
# Clone the repository
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot

# Install CLI
pip3 install .

# Initialize in your project
cd your-project
claude-pilot init .
```

---

## Updates

Update claude-pilot to the latest version:

```bash
# Auto merge (recommended)
claude-pilot update

# Manual merge (review changes before applying)
claude-pilot update --strategy manual

# Show version info
claude-pilot version
```

**Auto Merge** (default):
- Creates backup in `.claude-backups/`
- Updates all managed files
- Preserves your customizations
- Keeps last 5 backups

**Manual Merge**:
- Creates backup
- Generates merge guide in `.claude-backups/MANUAL_MERGE_GUIDE.md`
- You review and merge changes manually
- Provides rollback instructions

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

### Initialize New Project

```bash
# Navigate to your project
cd your-project

# Initialize (interactive - will prompt for language)
claude-pilot init .

# Or with language specified
claude-pilot init . --lang en

# For CI/CD (non-interactive)
claude-pilot init . -y --lang en
```

### Initialize Existing Project

```bash
# Navigate to your existing project
cd existing-project

# Initialize (will detect existing files)
claude-pilot init .

# If already initialized, use --force to reinitialize
claude-pilot init . --force
```

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
# - CLAUDE.md (Tier 1)
# - docs/ai-context/ files
# - Tier 2/3 CONTEXT.md files
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
/00_plan → Designs plan in conversation (no file)
    ↓
Manual Review/Edit
    ↓
/01_confirm → Saves plan to .pilot/plan/pending/
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
Update 3-Tier documentation:
  - Tier 1: CLAUDE.md
  - docs/ai-context/ files
  - Tier 2: Component CONTEXT.md
  - Tier 3: Feature CONTEXT.md
    ↓
Commit with docs
```

---

## Inspiration & Credits

claude-pilot synthesizes best practices from these projects:

### Core Methodology

- **[Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)**
  - 3-Tier Documentation System (Foundation/Component/Feature)
  - Hierarchical CONTEXT.md structure
  - AI-context documentation patterns

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

- [Getting Started](GETTING_STARTED.md)
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit) - 3-Tier Documentation System

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
