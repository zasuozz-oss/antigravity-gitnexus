# GitNexus for Antigravity

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
**🌐 [English](README.md)**

> Auto-setup [GitNexus](https://github.com/abhigyanpatwari/GitNexus) MCP server cho [Antigravity](https://github.com/google-deepmind/antigravity).

---

## GitNexus là gì?

[GitNexus](https://github.com/abhigyanpatwari/GitNexus) — tác giả [Abhigyan Patwari](https://github.com/abhigyanpatwari) — là một **code intelligence engine** xây dựng knowledge graph từ codebase.

Nó phân tích AST (Tree-sitter), trích xuất mọi function, class, dependency, call chain, rồi expose qua [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). Script này cấu hình GitNexus riêng cho **Antigravity** để bạn có code intelligence tools trực tiếp trong AI assistant.

Hỗ trợ 13 ngôn ngữ: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++.

---

## Quick Start

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/zasuozz-oss/gitnexus-setup/main/setup.sh | bash
```

**Hoặc clone rồi chạy:**

```bash
git clone https://github.com/zasuozz-oss/gitnexus-setup.git
cd gitnexus-setup
./setup.sh
```

Script làm 3 việc:

1. **Cấu hình** Antigravity MCP (`~/.gemini/antigravity/mcp_config.json`)
2. **Cài đặt** `gitnexus-sync` vào `~/.local/bin/` — đồng bộ skill GitNexus sang định dạng Antigravity
3. **Pre-download** `gitnexus` qua npx cache

Sau khi xong → **restart Antigravity** để load MCP server mới.

---

## Sử dụng

### 1. Index codebase

Vào thư mục project bất kỳ và index:

```bash
cd your-project
npx gitnexus analyze --skills
```

GitNexus tạo knowledge graph trong `.gitnexus/` (đã gitignore). Flag `--skills` tạo skill files cho AI agent. Chạy 1 lần, re-analyze khi code thay đổi.

### 2. Đồng bộ skill sang Antigravity

GitNexus ghi skill vào `.claude/skills/` (định dạng Claude Code). Chạy `gitnexus-sync` để chuyển sang định dạng Antigravity:

```bash
gitnexus-sync
```

Skill sẽ được copy sang `.agents/skills/gitnexus-*/SKILL.md` kèm YAML frontmatter chuẩn.

### 3. Sử dụng trong Antigravity

Khi đã index, Antigravity tự động có thể dùng các MCP tools:

```
# Tìm execution flows theo concept
gitnexus_query({query: "authentication middleware"})

# Xem 360° — ai gọi nó, nó gọi ai, thuộc flow nào
gitnexus_context({name: "validateUser"})

# Blast radius trước khi sửa
gitnexus_impact({target: "UserService", direction: "upstream"})

# Xem thay đổi ảnh hưởng gì trước khi commit
gitnexus_detect_changes({scope: "staged"})

# Rename an toàn qua knowledge graph
gitnexus_rename({symbol_name: "oldName", new_name: "newName", dry_run: true})
```

---

## MCP Tools

| Tool | Mô tả | Khi nào dùng |
|------|--------|-------------|
| `query` | Tìm execution flows (hybrid: BM25 + semantic) | Muốn hiểu code liên quan đến 1 chủ đề |
| `context` | 360° symbol view — callers, callees, processes | Cần biết mọi thứ về 1 function/class |
| `impact` | Blast radius với phân tầng depth | **Trước khi sửa** bất kỳ symbol nào |
| `detect_changes` | Map git diff → affected processes + risk | **Trước khi commit** |
| `rename` | Multi-file rename qua knowledge graph | Rename symbol an toàn |
| `cypher` | Custom Cypher queries trên code graph | Query phức tạp, tùy biến |
| `list_repos` | Liệt kê tất cả repos đã index | Multi-repo |

---

## Update

```bash
./setup.sh update
```

Cập nhật gitnexus lên version mới nhất và kiểm tra lại MCP config.

---

## Cách hoạt động

Script cấu hình `~/.gemini/antigravity/mcp_config.json`:

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

Dùng `npx gitnexus@latest` — luôn dùng version mới nhất, không hardcode đường dẫn, hoạt động trên mọi thiết bị.

---

## Yêu cầu

- **Node.js** ≥ 18 (kèm npm)
- **python3** (tùy chọn, cho auto-config MCP)
- **macOS** hoặc **Linux**

---

## Credits

- **[GitNexus](https://github.com/abhigyanpatwari/GitNexus)** by [Abhigyan Patwari](https://github.com/abhigyanpatwari)
- **[MCP](https://modelcontextprotocol.io/)** — Model Context Protocol

## License

Script setup: [MIT](LICENSE) · GitNexus: [PolyForm Noncommercial](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE)
