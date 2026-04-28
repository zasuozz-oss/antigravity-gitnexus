# GitNexus MCP Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
**🌐 [Tiếng Việt](README.vi.md)**

> Auto-setup [GitNexus](https://github.com/abhigyanpatwari/GitNexus) MCP server for Antigravity, Claude Desktop, and Codex.

---

## What is GitNexus?

[GitNexus](https://github.com/abhigyanpatwari/GitNexus) — by [Abhigyan Patwari](https://github.com/abhigyanpatwari) — is a **code intelligence engine** that builds a knowledge graph from any codebase.

It parses ASTs (Tree-sitter), extracts every function, class, dependency, and call chain, then exposes it via [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). This setup configures GitNexus for **Antigravity**, **Claude Desktop**, and **Codex** so you get code intelligence tools directly in your AI assistant.

Supports 13 languages: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++.

### Why?

Without GitNexus, AI assistants read code **file-by-file** — they can grep and search, but don't truly understand how pieces connect. GitNexus gives AI a **structural map** of your entire codebase:

- 🔍 **Trace execution flows** — see the full call chain `A → B → C`, not just individual files
- 💥 **Blast radius analysis** — before editing a function, know exactly what will break (direct callers, indirect dependents, affected modules)
- ⚠️ **Pre-commit risk detection** — map your `git diff` to affected processes and get a risk assessment before pushing
- ✏️ **Safe multi-file renames** — rename a symbol across the entire codebase using the knowledge graph, not regex find-and-replace

> **In short:** GitNexus turns your AI from a "file reader" into a "codebase navigator."

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

The script does five things:

1. **Builds and links** the local `GitNexus/gitnexus` CLI with `npm link`
2. **Configures** Antigravity MCP (`~/.gemini/antigravity/mcp_config.json`)
3. **Configures** Claude Desktop MCP (`~/Library/Application Support/Claude/claude_desktop_config.json`)
4. **Configures** Codex MCP (`~/.codex/config.toml`)
5. **Installs** GitNexus global skills for Antigravity, Claude, and Codex, then prepares the Web UI

After completion → restart Antigravity, Claude Desktop, and Codex to load the MCP server.

---

## Usage

### 1. Index a codebase

Go to any project directory and index it:

```bash
cd your-project
gitnexus analyze
```

This creates a knowledge graph in `.gitnexus/` (gitignored). Run once per repo, re-run when code changes. The legacy `--skills` flag is accepted as a no-op, but GitNexus no longer writes project skill folders during analyze.

### 2. Index a Unity project

For Unity games (like SDU), GitNexus has a specialized Unity parser that automatically skips heavy plugins, native SDKs (Firebase, AppsFlyer), and auto-generated Unity internals (`Library/`, `Logs/`). It also includes memory management improvements and graph noise reducers (e.g., pruning `MonoBehaviour` inheritance) to keep the AI Knowledge Graph clean, small, and fast.

```bash
cd your-unity-project
gitnexus unity analyze --embeddings
```

### 3. Global skills

`./setup.sh` installs bundled GitNexus skills globally:

```text
~/.gemini/antigravity/skills/gitnexus-*/SKILL.md
~/.claude/skills/gitnexus-*/SKILL.md
${CODEX_HOME:-~/.codex}/skills/gitnexus-*/SKILL.md
```

Analyze commands do not create `.claude/skills/` or `.agents/skills/` inside each indexed project.

### 4. Launch the Web UI

Visualize the knowledge graph in your browser:

```bash
./web-ui.sh
```

This starts both the **backend** (`http://127.0.0.1:4747`) and **frontend** (`http://localhost:5173`) in one command. Press `Ctrl+C` to stop both.

> **Note:** Requires `./setup.sh` to have been run first (clones GitNexus repo and installs dependencies).

### 5. Use in MCP clients

Once indexed, configured MCP clients automatically have access to these tools when working with that codebase:

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

## Project Structure

```
gitnexus-setup/
├── setup.sh          # Main setup — local build/link, MCP config, global skills
├── update.sh         # Pull upstream GitNexus, apply local custom files, rebuild local CLI
├── custom/           # Local custom files copied into GitNexus/ after upstream sync
├── sync-skills.sh    # Legacy project skill sync helper
├── web-ui.sh         # Launch backend + frontend in one command
├── test-sync.sh      # Test suite for sync-skills.sh (6 tests)
├── GitNexus/         # Embedded GitNexus upstream snapshot
├── LICENSE           # MIT
└── README.md
```

---

## Update

```bash
./update.sh
```

Updates the embedded GitNexus snapshot from upstream, then copies custom files from `custom/gitnexus-unity/` to restore `gitnexus unity analyze`, rebuilds the local CLI, and relinks `gitnexus`.

---

## Testing

Run the legacy sync-skills test suite:

```bash
bash test-sync.sh
```

Covers the legacy project-skill bridge: flat skills, generated skills, frontmatter rewriting, idempotency, graceful error handling, and mixed skill layouts.

---

## How it works

The setup script builds and links the local CLI:

```bash
cd GitNexus/gitnexus-shared
npm install
cd ../gitnexus-web
npm install
cd ../gitnexus
npm install
npm run build
npm link
```

It configures each MCP client with the same command:

```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "gitnexus",
      "args": ["mcp"]
    }
  }
}
```

Codex uses the equivalent TOML block:

```toml
[mcp_servers.gitnexus]
command = "gitnexus"
args = [ "mcp" ]
```

It also copies bundled GitNexus skills into Antigravity, Claude, and Codex global skill folders:

```text
~/.gemini/antigravity/skills/
~/.claude/skills/
${CODEX_HOME:-~/.codex}/skills/
```

`./update.sh` pulls `abhigyanpatwari/GitNexus` into `GitNexus/`, then applies local customizations from `custom/gitnexus-unity/`. This keeps custom Unity files out of the upstream snapshot until after the sync step, so future upstream updates do not permanently overwrite them.

---

## Requirements

- **Node.js** ≥ 20 (with npm)
- **python3** (for MCP config and local custom patching)
- **rsync** (for `./update.sh`)
- **gh** CLI (optional, for first-time fork/clone fallback)
- **macOS** or **Linux**

---

## Credits

- **[GitNexus](https://github.com/abhigyanpatwari/GitNexus)** by [Abhigyan Patwari](https://github.com/abhigyanpatwari)
- **[MCP](https://modelcontextprotocol.io/)** — Model Context Protocol

## License

Setup script: [MIT](LICENSE) · GitNexus: [PolyForm Noncommercial](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE)
