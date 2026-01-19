# claude-pilot ⭐

**SPEC-First Development Workflow for Claude Code**

> Autonomous agents. TDD-driven. Documentation sync.

[![Version](https://img.shields.io/github/v/release/changoo89/claude-pilot)](https://github.com/changoo89/claude-pilot/releases)
[![License](https://img.shields.io/github/license/changoo89/claude-pilot)](LICENSE)
[![Stars](https://img.shields.io/github/stars/changoo89/claude-pilot)](https://github.com/changoo89/claude-pilot/stargazers)

---

## Why claude-pilot?

Stop planning in your head. Start with SPECs, iterate with agents, review with confidence.

**Key Benefits**:
- ✅ **SPEC-First**: Requirements before code
- 🤖 **Autonomous**: Ralph Loop runs until tests pass
- 🔄 **Continuous**: Resume across sessions with Sisyphus
- 📚 **Documented**: Auto-sync 3-tier documentation
- 🧠 **Intelligent**: GPT Codex delegation for complex problems

---

## Quick Start

```bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup
```

⭐ **Star this repo if it helps your workflow!**

---

## What is claude-pilot?

**claude-pilot** is a Claude Code plugin that brings structure and discipline to AI-assisted development.

### Core Features

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **3-Tier Documentation**: Foundation/Component/Feature hierarchy for efficient context
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Pure Plugin**: No Python dependency, native Claude Code integration

---

## GPT Codex Integration

**Intelligent GPT Delegation**: Context-aware, autonomous delegation to GPT experts

### Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Architecture decisions | **Architect** |
| Security-related code | **Security Analyst** |
| Large plans (5+ SCs) | **Plan Reviewer** |
| 2+ failed fix attempts | **Architect** |
| Coder blocked (automatic) | **Architect** |

### Delegation Triggers

- **Explicit**: "ask GPT", "review architecture"
- **Semantic**: Architecture decisions, security issues, ambiguity
- **Automatic**: After 2nd failure (not first) → Progressive escalation
- **Self-Assessment**: Agent confidence scoring < 0.5 → Delegation

### Configuration

```bash
export CODEX_REASONING_EFFORT="medium"  # low | medium | high | xhigh
```

**Full Guide**: [docs/ai-context/codex-integration.md](docs/ai-context/codex-integration.md)

---

## claude-pilot vs Vanilla Claude Code

| Feature | claude-pilot | Vanilla Claude Code |
|---------|--------------|---------------------|
| **SPEC-First Planning** | ✅ PRP format, success criteria | ❌ Ad-hoc planning |
| **TDD Automation** | ✅ Ralph Loop autonomous | ❌ Manual test-run cycle |
| **Session Persistence** | ✅ Sisyphus continuation | ❌ Context lost on exit |
| **Documentation Sync** | ✅ 3-tier auto-update | ❌ Manual docs only |
| **Quality Gates** | ✅ Type check, lint, coverage | ❌ No enforcement |
| **GPT Delegation** | ✅ Intelligent escalation | ❌ Manual delegation |
| **Multi-Angle Review** | ✅ Parallel verification | ❌ Single perspective |

---

## Core Workflow

```
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
├── CLAUDE.md              # Main project guide
├── .claude-plugin/        # Plugin manifests
│   ├── marketplace.json   # Marketplace configuration
│   └── plugin.json        # Plugin metadata
├── .claude/               # Plugin components
│   ├── agents/            # Agent configurations (8 agents)
│   ├── commands/          # Slash commands (11)
│   ├── skills/            # TDD, Ralph Loop, Vibe Coding
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
└── docs/                  # Documentation
    ├── archive/           # Archived content (MIGRATION.md)
    └── ai-context/        # 3-Tier integration docs
```

---

## Installation

### Prerequisites

- **Claude Code** v1.0+ with plugin support

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
   - Detects project type and configures LSP

### What Gets Installed

- **11 Slash Commands**: Plan, Confirm, Execute, Close, Review, Document, Init, Setup, Release, Cleanup, Continue
- **8 Agents**: Coder, Tester, Validator, Documenter, Explorer, Researcher, Plan Reviewer, Code Reviewer
- **4 Skills**: TDD, Ralph Loop, Vibe Coding, Git Master
- **MCP Servers**: context7, serena, grep-app, sequential-thinking (configured via `/pilot:setup`)
- **Hooks**: Type checking, linting, todo validation, branch guard

---

## Configuration

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

## Guides

- [Getting Started](GETTING_STARTED.md)
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

### Q: Do I need Python installed?
A: No! The plugin is pure markdown/JSON - no Python required.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/changoo89/claude-pilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/changoo89/claude-pilot/discussions)

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

**Built with inspiration from the Claude Code community.**

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=changoo89/claude-pilot&type=Date)](https://star-history.com/#changoo89/claude-pilot&Date)
