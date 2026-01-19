# claude-pilot

> Your Claude Code copilot - Structured workflows, SPEC-First TDD, Ralph Loop automation, and context engineering. Fly with discipline.

[![License](https://img.shields.io/github/license/changoo89/claude-pilot?v=2)](LICENSE)
[![Stars](https://img.shields.io/github/stars/changoo89/claude-pilot?v=2)](https://github.com/changoo89/claude-pilot/stargazers)

---

## Quick Start

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

After installation, `/pilot:setup` will be prompted automatically to configure MCP servers and project settings.

---

## What is claude-pilot?

**claude-pilot** is a Claude Code plugin that brings structure and discipline to AI-assisted development. It provides:

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **3-Tier Documentation**: Foundation/Component/Feature hierarchy for efficient context
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Migration Support**: Auto-generate docs for existing projects with `/92_init`
- **Multilingual**: Runtime language selection (English/Korean/Japanese)
- **Pure Plugin**: No Python dependency, native Claude Code integration

---

## CLAUDE.local.md (Project-Specific Configuration)

**When to use**: Add `CLAUDE.local.md` to your project root for project-specific documentation that stays private (gitignored).

### Two-Layer Documentation Strategy

claude-pilot uses a two-layer documentation approach:

1. **Plugin Layer (CLAUDE.md)**: Plugin architecture, features, distribution
   - Located in the plugin directory
   - Updated via `/plugin update`
   - Contains plugin-level documentation only

2. **Project Layer (CLAUDE.local.md)**: Your project-specific configuration, structure, and standards
   - Located in your project root
   - Gitignored (stays private)
   - Survives plugin updates

### How to Create CLAUDE.local.md

Run `/pilot:setup` and choose "Yes" when prompted:

```
Would you like to create a CLAUDE.local.md file? [Y/n]
```

This copies `.claude/templates/CLAUDE.local.template.md` to your project root as `CLAUDE.local.md`.

### What to Include

`CLAUDE.local.md` contains your project-specific settings:

```yaml
---
# Project Configuration
continuation_level: normal  # aggressive | normal | polite
coverage_threshold: 80      # Overall coverage target
core_coverage_threshold: 90 # Core modules coverage target
max_iterations: 7            # Max Ralph Loop iterations
testing_framework: {pytest|jest|go test|cargo test}
type_check_command: {tsc --noEmit|mypy|typecheck}
lint_command: {eslint|ruff|gofmt|lint}
---
```

Plus project-specific sections:
- Project structure
- Testing strategy
- Quality standards
- MCP servers
- Custom workflows

### Benefits

- **Clean Plugin Docs**: Plugin CLAUDE.md stays focused on plugin features
- **Private Customization**: Your project settings stay local (gitignored)
- **Update-Safe**: Plugin updates won't affect your local documentation
- **Clear Separation**: Plugin vs project concerns are explicitly separated

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
/pilot:setup → Configure MCP servers
```

---

## Project Structure

```
claude-pilot/
├── README.md
├── CHANGELOG.md           # Version history
├── MIGRATION.md           # PyPI to plugin migration guide
├── CLAUDE.md              # Main project guide
├── .claude-plugin/        # Plugin manifests
│   ├── marketplace.json   # Marketplace configuration
│   └── plugin.json        # Plugin metadata
├── .claude/               # Plugin components
│   ├── agents/            # Agent configurations (8 agents)
│   ├── commands/          # Slash commands (10)
│   ├── skills/            # TDD, Ralph Loop, Vibe Coding, Git Master
│   ├── guides/            # Methodology guides
│   ├── templates/         # CONTEXT.md, SKILL.md templates
│   ├── scripts/hooks/     # Typecheck, lint, todos, branch
│   ├── hooks.json         # Hook definitions
│   └── settings.json      # Example settings
├── .pilot/                # Plan management
│   └── plan/
│       ├── pending/       # Plans awaiting confirmation
│       ├── in_progress/   # Active plans
│       └── done/          # Completed plans
└── mcp.json               # Recommended MCP servers
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

### 5. Frontend Design Skill

**Production-grade frontend design for distinctive, non-generic UI**

Avoid generic "AI slop" aesthetics through specific aesthetic direction guidelines:

**Key Features**:
- **Aesthetic Directions**: Minimalist, Warm/Human, Brutalist, Maximalist, Technical/Precise
- **Anti-Pattern Prevention**: Never use Inter as default, avoid purple-to-blue gradients
- **Specific Guidelines**: Typography, color palettes, motion, spatial composition
- **Example Components**: Dashboard, landing page, portfolio with full code

**Usage**:
```bash
# When building frontend components
"I'll use a **Warm/Human** aesthetic for this landing page with coral accents and cream background."
```

**Reference**: `.claude/skills/frontend-design/SKILL.md`

---

## Installation

### Prerequisites

- **Claude Code** v1.0+ with plugin support
- **GitHub CLI** (optional, for automatic starring)

### Installation (3-Line)

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

### What Happens During Installation

1. Plugin files are copied to `.claude/` directory
2. You'll be prompted to run `/pilot:setup`
3. Setup automatically:
   - Configures recommended MCP servers
   - Creates `.pilot/` directories for plan management
   - Sets hooks executable permissions
   - Prompts for language selection (English/Korean/Japanese)
   - Detects project type and configures LSP

### What Gets Installed

- **10 Slash Commands**: Plan, Confirm, Execute, Close, Review, Document, Init, Setup, Publish
- **8 Agents**: Coder, Tester, Validator, Documenter, Explorer, Researcher, Plan Reviewer, Code Reviewer
- **4 Skills**: TDD, Ralph Loop, Vibe Coding, Git Master
- **MCP Servers**: context7, serena, grep-app, sequential-thinking (configured via `/pilot:setup`)
- **Hooks**: Type checking, linting, todo validation, branch guard

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

Run `/pilot:setup` to configure recommended MCPs:

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |

The setup command uses a merge strategy:
- Preserves existing `.mcp.json` configurations
- Adds only new servers
- Skips servers with conflicting names

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

### Initialize Existing Project

```bash
# In Claude Code
/92_init

# Automatically generates 3-Tier documentation structure
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

## Updates

```bash
# Update to latest version
/plugin update claude-pilot

# Check current version
# See .claude-plugin/plugin.json
```

---

## Migration from PyPI (v4.0.5)

**Breaking Change**: PyPI distribution discontinued in v4.1.0

If you previously installed via `pip install claude-pilot`:

1. **Uninstall Python package**:
   ```bash
   pipx uninstall claude-pilot
   # OR
   pip uninstall claude-pilot
   ```

2. **Install plugin** (follow 3-line installation above)

3. **All functionality preserved** - commands, agents, skills work identically

**Benefits of Migration**:
- No Python dependency
- Simpler updates (`/plugin update`)
- Native Claude Code integration

See [MIGRATION.md](MIGRATION.md) for detailed guide.

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

- **[claude-delegator](https://github.com/jarrodwatts/claude-delegator)**
  - Pure plugin architecture
  - GitHub star prompting
  - MCP server configuration

### Official Resources

- **[Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
  - Official Anthropic guidelines
- **[Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)**
  - Plugin development guide

---

## Guides

- [Getting Started](GETTING_STARTED.md)
- [Migration Guide](MIGRATION.md) - PyPI to plugin migration
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit) - 3-Tier Documentation System

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`/00_plan "your feature"`)
3. Follow TDD workflow (`/02_execute`)
4. Submit PR with `/90_review` output

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
A: Yes, run `/pilot:setup` to add recommended MCPs, or manually edit `.mcp.json`.

### Q: What if I don't want TDD?
A: Ralph Loop can be configured to skip tests. Edit `/02_execute` command to adjust.

### Q: How do I add a new language?
A: Create translation files in `.claude/locales/` and add language code to settings.json.

### Q: Do I need Python installed?
A: No! The plugin is pure markdown/JSON - no Python required.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/changoo89/claude-pilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/changoo89/claude-pilot/discussions)

---

**Built with inspiration from the Claude Code community.**

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=changoo89/claude-pilot&type=Date&v=2)](https://star-history.com/#changoo89/claude-pilot&Date)
