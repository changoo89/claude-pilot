# MCP Servers

> **Last Updated**: 2026-01-18
> **Purpose**: Recommended MCP servers for Claude Code

---

## Recommended Servers

| Server | Purpose |
|--------|---------|
| **context7** | Documentation navigation and context |
| **serena** | Code operations and refactoring |
| **grep-app** | Fast code search |
| **sequential-thinking** | Complex reasoning and planning |
| **codex** | GPT delegation (intelligent escalation) |

---

## Configuration

**File**: `mcp.json` (project root)

**Example Configuration**:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
    "serena": {
      "command": "npx",
      "args": ["-y", "@serena/mcp-server"]
    }
  }
}
```

---

## Server Details

### context7

**Purpose**: Documentation navigation and context retrieval

**Use When**:
- Navigating large codebases
- Finding relevant documentation
- Context-aware code assistance

### serena

**Purpose**: Code operations and refactoring

**Use When**:
- Performing code refactoring
- Applying code transformations
- Bulk code operations

### grep-app

**Purpose**: Fast code search

**Use When**:
- Searching for patterns across files
- Finding usages of symbols
- Quick code navigation

### sequential-thinking

**Purpose**: Complex reasoning and planning

**Use When**:
- Breaking down complex tasks
- Multi-step reasoning
- Strategic planning

### codex

**Purpose**: GPT delegation (intelligent escalation)

**Use When**:
- Delegating to GPT experts
- Progressive escalation after failures
- High-difficulty analysis

**See**: **@docs/ai-context/codex-integration.md** for full delegation guide

---

## See Also

- **@docs/ai-context/system-integration.md** - System integration overview
- **@docs/ai-context/codex-integration.md** - Codex delegation details
- **@CLAUDE.md** - Project standards (Tier 1)
