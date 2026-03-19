# GitNexus + Antigravity Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
**🌐 [Tiếng Việt](README.vi.md)**

> One-command setup for [GitNexus](https://github.com/abhigyanpatwari/GitNexus) MCP server with [Antigravity](https://github.com/AntimatterAI/antimatter).

---

## What is GitNexus?

[GitNexus](https://github.com/abhigyanpatwari/GitNexus) — by [Abhigyan Patwari](https://github.com/abhigyanpatwari) — is a **code intelligence engine** that builds a knowledge graph from your codebase.

It parses ASTs (Tree-sitter), extracts every function, class, dependency, and call chain, then exposes it via [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) so AI agents can:

- **Understand the real structure** of a codebase instead of just grepping text
- **Analyze blast radius** before editing — know exactly what will break
- **Trace execution flows** — follow the path from entry point to terminal
- **Rename safely** via the knowledge graph, not blind find-and-replace

Supports 13 languages: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++.

> GitNexus is licensed under [PolyForm Noncommercial License](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE). This setup script repo (contains only the script, not GitNexus source) uses [MIT License](LICENSE).

---

## Quick Start

**Option 1 — One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/zasuozz-oss/gitnexus-setup/main/setup.sh | bash
```

**Option 2 — Clone and run:**

```bash
git clone https://github.com/zasuozz-oss/gitnexus-setup.git
cd gitnexus-setup
./setup.sh
```

The script automatically:

1. ✅ Checks prerequisites (Node.js ≥ 18, npm, git)
2. 📦 Clones [GitNexus](https://github.com/abhigyanpatwari/GitNexus) into `./git-nexus`
3. 📦 Installs dependencies + builds
4. ⚙️ Configures MCP in `~/.gemini/antigravity/mcp_config.json`

After completion → **restart Antigravity** to load the new MCP server.

---

## Usage

### 1. Index your codebase

After setup, run this **inside the project directory** you want to analyze:

```bash
npx gitnexus analyze
```

GitNexus creates a knowledge graph in `.gitnexus/` (gitignored). Run once, then re-analyze when code changes.

### 2. Use in Antigravity

Once indexed, Antigravity automatically has access to MCP tools for that codebase:

```
# Find execution flows related to authentication
gitnexus_query({query: "authentication middleware"})

# 360° view of a function — who calls it, what it calls, which flows it's in
gitnexus_context({name: "validateUser"})

# Check blast radius before editing
gitnexus_impact({target: "UserService", direction: "upstream"})

# See what your changes affect before committing
gitnexus_detect_changes({scope: "staged"})

# Safe rename via knowledge graph
gitnexus_rename({symbol_name: "oldName", new_name: "newName", dry_run: true})
```

### 3. Web UI (optional)

```bash
cd git-nexus/gitnexus-web
npm run dev
```

Opens a visual graph explorer + AI chat in browser. Or use online at [gitnexus.vercel.app](https://gitnexus.vercel.app).

---

## MCP Tools Reference

| Tool | Description | When to use |
|------|-------------|-------------|
| `query` | Find execution flows by concept (hybrid: BM25 + semantic) | Understand code related to a topic |
| `context` | 360° symbol view — callers, callees, processes | Need full picture of a function/class |
| `impact` | Blast radius — d=1 will break, d=2 likely affected, d=3 needs testing | **Before editing** any symbol |
| `detect_changes` | Map git diff → affected processes + risk level | **Before committing** |
| `rename` | Multi-file rename via knowledge graph + text search | Safe symbol renaming |
| `cypher` | Custom Cypher queries on code graph | Complex/custom queries |
| `list_repos` | List all indexed repositories | Multi-repo workflows |

---

## Update

When GitNexus releases a new version:

```bash
./setup.sh update
```

Pulls latest → clean rebuild → updates MCP path.

---

## Configuration

### Custom install directory

```bash
GITNEXUS_DIR=/path/to/dir ./setup.sh
```

Default: clones into `./git-nexus` (current working directory).

### MCP Config

The script writes to `~/.gemini/antigravity/mcp_config.json`:

```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "node",
      "args": ["<absolute-path>/gitnexus/dist/cli/index.js", "mcp"]
    }
  }
}
```

The path is computed dynamically based on the actual repo location — **never hardcoded**, works correctly on any machine.

---

## System Requirements

| | Required | Optional |
|---|---------|----------|
| **Node.js** | ≥ 18 | |
| **npm** | ✓ (bundled with Node.js) | |
| **git** | ✓ | |
| **python3** | | For auto-config MCP |
| **OS** | macOS, Linux | |

---

## Credits

- **[GitNexus](https://github.com/abhigyanpatwari/GitNexus)** by [Abhigyan Patwari](https://github.com/abhigyanpatwari) — Code intelligence engine
- **[Antigravity](https://github.com/AntimatterAI/antimatter)** — AI coding assistant
- **[MCP](https://modelcontextprotocol.io/)** — Model Context Protocol

## License

Setup script: [MIT License](LICENSE).  
GitNexus: [PolyForm Noncommercial License](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE).
