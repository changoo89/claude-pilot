# MCP Servers

> **Last Updated**: 2026-01-20
> **Purpose**: Recommended MCP servers for Claude Code

---

## Recommended Servers

| Server | Purpose | Package |
|--------|---------|---------|
| **context7** | Documentation navigation and context | `@upstash/context7-mcp` |
| **sequential-thinking** | Complex reasoning and planning | `@modelcontextprotocol/server-sequential-thinking` |

### Optional Servers (Require Additional Setup)

| Server | Purpose | Setup |
|--------|---------|-------|
| **serena** | Code operations and refactoring | Python-based, requires `uvx` (see below) |
| **grep-app** | Fast GitHub code search | Requires build from source |

---

## Configuration

**Location**: Project-level MCP servers are configured in `~/.claude.json` under `projects.<project-path>.mcpServers`

**Quick Setup** (context7 + sequential-thinking):
```bash
# Add to ~/.claude.json manually:
{
  "projects": {
    "/Users/chanho/claude-pilot": {
      "mcpServers": {
        "context7": {
          "type": "stdio",
          "command": "npx",
          "args": ["-y", "@upstash/context7-mcp"]
        },
        "sequential-thinking": {
          "type": "stdio",
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
        }
      }
    }
  }
}
```

**Alternative: CLI Wizard**:
```bash
claude mcp add context7
claude mcp add sequential-thinking
```

---

## Server Details

### context7

**Package**: `@upstash/context7-mcp`
**Purpose**: Documentation navigation and context retrieval

**Use When**:
- Navigating large codebases
- Finding relevant documentation
- Context-aware code assistance

**Source**: [github.com/upstash/context7](https://github.com/upstash/context7)

### sequential-thinking

**Package**: `@modelcontextprotocol/server-sequential-thinking`
**Purpose**: Complex reasoning and planning

**Use When**:
- Breaking down complex tasks
- Multi-step reasoning
- Strategic planning

### serena (Optional)

**Purpose**: Code operations and refactoring (Python-based)

**Setup**:
```bash
# Install uv first
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to ~/.claude.json:
{
  "mcpServers": {
    "serena": {
      "type": "stdio",
      "command": "uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server"]
    }
  }
}
```

**Source**: [github.com/oraios/serena](https://github.com/oraios/serena)

**Use When**:
- Performing code refactoring
- Applying code transformations
- Bulk code operations

### grep-app (Optional)

**Purpose**: Fast GitHub code search

**Setup**: Requires build from source
```bash
git clone https://github.com/ai-tools-all/grep_app_mcp.git
cd grep_app_mcp
npm install
npm run build
```

**Source**: [github.com/ai-tools-all/grep_app_mcp](https://github.com/ai-tools-all/grep_app_mcp)

**Use When**:
- Searching GitHub code repositories
- Finding implementation examples
- Learning from open source projects

---

## Verification

After adding MCP servers, restart Claude Code and verify:

```bash
/mcp
```

Expected output:
```
⎿  MCP Server Status
⎿
⎿  • context7: connected
⎿  • sequential-thinking: connected
```

---

## See Also

- **@docs/ai-context/system-integration.md** - System integration overview
- **@docs/ai-context/codex-integration.md** - Codex delegation details
- **[Configuring MCP Tools in Claude Code - The Better Way](https://scottspence.com/posts/configuring-mcp-tools-in-claude-code)** - External guide
- **@CLAUDE.md** - Project standards (Tier 1)
