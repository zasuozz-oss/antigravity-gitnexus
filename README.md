# GitNexus for Antigravity

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
**🌐 [Tiếng Việt](README.vi.md)**

> Auto-setup [GitNexus](https://github.com/abhigyanpatwari/GitNexus) MCP server for [Antigravity](https://github.com/google-deepmind/antigravity).

---

## What is GitNexus?

[GitNexus](https://github.com/abhigyanpatwari/GitNexus) — by [Abhigyan Patwari](https://github.com/abhigyanpatwari) — is a **code intelligence engine** that builds a knowledge graph from any codebase.

It parses ASTs (Tree-sitter), extracts every function, class, dependency, and call chain, then exposes it via [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). This setup script configures GitNexus specifically for **Antigravity** so you get code intelligence tools directly in your AI assistant.

Supports 13 languages: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++.

---

## Quick Start

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/zasuozz-oss/gitnexus-setup/main/setup.sh | bash
```

**Or clone and run:**

```bash
git clone https://github.com/zasuozz-oss/gitnexus-setup.git
cd gitnexus-setup
./setup.sh
```

The script does two things:

1. **Installs** `gitnexus` globally via npm
2. **Configures** Antigravity MCP (`~/.gemini/antigravity/mcp_config.json`)

After completion → **restart Antigravity** to load the MCP server.

---

## Usage

### 1. Index a codebase

Go to any project directory and index it:

```bash
cd your-project
gitnexus analyze
```

This creates a knowledge graph in `.gitnexus/` (gitignored). Run once per repo, re-analyze when code changes.

### 2. Use in Antigravity

Once indexed, Antigravity automatically has access to these MCP tools when working with that codebase:

```
# Find execution flows by concept
gitnexus_query({query: "authentication middleware"})

# 360° view — who calls it, what it calls, which flows it belongs to
gitnexus_context({name: "validateUser"})

# Blast radius before editing
gitnexus_impact({target: "UserService", direction: "upstream"})

# Check what your changes affect before committing
gitnexus_detect_changes({scope: "staged"})

# Safe rename via knowledge graph
gitnexus_rename({symbol_name: "oldName", new_name: "newName", dry_run: true})
```

---

## MCP Tools

| Tool | What it does | When to use |
|------|-------------|-------------|
| `query` | Search execution flows (hybrid: BM25 + semantic) | Understand code related to a topic |
| `context` | 360° symbol view — callers, callees, processes | Full picture of a function/class |
| `impact` | Blast radius analysis with depth grouping | **Before editing** any symbol |
| `detect_changes` | Map git diff → affected processes + risk | **Before committing** |
| `rename` | Multi-file rename via knowledge graph | Safe symbol renaming |
| `cypher` | Custom Cypher queries on code graph | Complex/custom queries |
| `list_repos` | List all indexed repositories | Multi-repo workflows |

---

## Update

```bash
./setup.sh update
```

Updates gitnexus to the latest version and re-validates MCP config.

---

## How it works

The script configures `~/.gemini/antigravity/mcp_config.json`:

```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "npx",
      "args": ["-y", "gitnexus@latest", "mcp"]
    }
  }
}
```

Uses `npx gitnexus@latest` — always uses the latest version, no hardcoded paths, works on any machine.

---

## Requirements

- **Node.js** ≥ 18 (with npm)
- **python3** (optional, for auto-config MCP)
- **macOS** or **Linux**

---

## Credits

- **[GitNexus](https://github.com/abhigyanpatwari/GitNexus)** by [Abhigyan Patwari](https://github.com/abhigyanpatwari)
- **[MCP](https://modelcontextprotocol.io/)** — Model Context Protocol

## License

Setup script: [MIT](LICENSE) · GitNexus: [PolyForm Noncommercial](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE)
