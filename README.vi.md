# GitNexus MCP Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
**🌐 [English](README.md)**

> Auto-setup [GitNexus](https://github.com/abhigyanpatwari/GitNexus) MCP server cho Antigravity, Claude Desktop và Codex.

---

## GitNexus là gì?

[GitNexus](https://github.com/abhigyanpatwari/GitNexus) — tác giả [Abhigyan Patwari](https://github.com/abhigyanpatwari) — là một **code intelligence engine** xây dựng knowledge graph từ codebase.

Nó phân tích AST (Tree-sitter), trích xuất mọi function, class, dependency, call chain, rồi expose qua [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). Bộ script này cấu hình GitNexus cho **Antigravity**, **Claude Desktop** và **Codex** để bạn có code intelligence tools trực tiếp trong AI assistant.

Hỗ trợ 13 ngôn ngữ: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++.

### Tại sao cần GitNexus?

Nếu không có GitNexus, AI chỉ đọc code **từng file một** — có thể grep và search, nhưng không thực sự hiểu các phần code liên kết với nhau thế nào. GitNexus cung cấp cho AI một **bản đồ cấu trúc** toàn bộ codebase:

- 🔍 **Truy vết luồng thực thi** — xem toàn bộ call chain `A → B → C`, không chỉ từng file riêng lẻ
- 💥 **Phân tích blast radius** — trước khi sửa một function, biết chính xác những gì sẽ bị ảnh hưởng (caller trực tiếp, phụ thuộc gián tiếp, module liên quan)
- ⚠️ **Phát hiện rủi ro trước khi commit** — map `git diff` tới các process bị ảnh hưởng và đánh giá mức độ rủi ro trước khi push
- ✏️ **Rename an toàn đa file** — đổi tên symbol trên toàn bộ codebase dựa vào knowledge graph, không phải regex find-and-replace

> **Tóm lại:** GitNexus biến AI từ "đọc file" thành "hiểu kiến trúc."

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

Script làm 5 việc:

1. **Build và link** CLI local từ `GitNexus/gitnexus` bằng `npm link`
2. **Cấu hình** Antigravity MCP (`~/.gemini/antigravity/mcp_config.json`)
3. **Cấu hình** Claude Desktop MCP (`~/Library/Application Support/Claude/claude_desktop_config.json`)
4. **Cấu hình** Codex MCP (`~/.codex/config.toml`)
5. **Cài GitNexus global skills** cho Antigravity, Claude và Codex, rồi chuẩn bị Web UI

Sau khi xong → restart Antigravity, Claude Desktop và Codex để load MCP server mới.

---

## Sử dụng

### 1. Index codebase

Vào thư mục project bất kỳ và index:

```bash
cd your-project
gitnexus analyze
```

GitNexus tạo knowledge graph trong `.gitnexus/` (đã gitignore). Chạy 1 lần, re-analyze khi code thay đổi. Flag cũ `--skills` vẫn được nhận nhưng là no-op; analyze không còn tạo project skill folders.

### 2. Index Unity project

Unity dùng command riêng để tự bỏ qua SDK, plugin nặng và asset/generated noise:

```bash
cd your-unity-project
gitnexus unity analyze --embeddings
```

### 3. Global skills

`./setup.sh` cài bundled GitNexus skills trực tiếp vào global folders:

```text
~/.gemini/antigravity/skills/gitnexus-*/SKILL.md
~/.claude/skills/gitnexus-*/SKILL.md
${CODEX_HOME:-~/.codex}/skills/gitnexus-*/SKILL.md
```

Các lệnh analyze không còn tạo `.claude/skills/` hoặc `.agents/skills/` bên trong từng project được index.

### 4. Khởi chạy Web UI

Trực quan hóa knowledge graph trên trình duyệt:

```bash
./web-ui.sh
```

Khởi động cả **backend** (`http://127.0.0.1:4747`) lẫn **frontend** (`http://localhost:5173`) trong một lệnh. Nhấn `Ctrl+C` để dừng cả hai.

> **Lưu ý:** Cần chạy `./setup.sh` trước (clone repo GitNexus và cài dependencies).

### 5. Sử dụng trong MCP clients

Khi đã index, các MCP client đã cấu hình có thể dùng các tools:

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

## Cấu trúc dự án

```
gitnexus-setup/
├── setup.sh          # Setup chính — build/link local, MCP config, global skills
├── update.sh         # Sync upstream GitNexus, apply custom files, rebuild CLI
├── custom/           # Custom files được copy vào GitNexus/ sau khi sync upstream
├── sync-skills.sh    # Helper legacy để sync project skills
├── web-ui.sh         # Khởi chạy backend + frontend bằng 1 lệnh
├── test-sync.sh      # Bộ test cho sync-skills.sh (6 test cases)
├── GitNexus/         # Snapshot upstream GitNexus được vendored local
├── LICENSE           # MIT
└── README.md
```

---

## Cập nhật

```bash
./update.sh
```

Cập nhật `GitNexus/` từ upstream, sau đó copy custom files từ `custom/gitnexus-unity/` để khôi phục `gitnexus unity analyze`, rebuild và relink CLI local.

---

## Chạy test

Chạy bộ test legacy cho sync-skills:

```bash
bash test-sync.sh
```

Bao gồm luồng legacy project-skill bridge: flat skills, generated skills, ghi đè frontmatter, idempotency, xử lý lỗi, và bố cục skill hỗn hợp.

---

## Cách hoạt động

Script build và link CLI local:

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

Các MCP client dùng cùng command:

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

Codex dùng TOML tương đương:

```toml
[mcp_servers.gitnexus]
command = "gitnexus"
args = [ "mcp" ]
```

Script cũng copy bundled GitNexus skills vào global skill folders của Antigravity, Claude và Codex:

```text
~/.gemini/antigravity/skills/
~/.claude/skills/
${CODEX_HOME:-~/.codex}/skills/
```

`./update.sh` sync `abhigyanpatwari/GitNexus` vào `GitNexus/`, rồi mới apply custom từ `custom/gitnexus-unity/`. Nhờ vậy custom Unity không bị mất vĩnh viễn khi update upstream.

---

## Yêu cầu

- **Node.js** ≥ 20 (kèm npm)
- **python3** (cho MCP config và apply custom local)
- **rsync** (cho `./update.sh`)
- **gh** CLI (tùy chọn, để fork thay vì clone)
- **macOS** hoặc **Linux**

---

## Credits

- **[GitNexus](https://github.com/abhigyanpatwari/GitNexus)** by [Abhigyan Patwari](https://github.com/abhigyanpatwari)
- **[MCP](https://modelcontextprotocol.io/)** — Model Context Protocol

## License

Script setup: [MIT](LICENSE) · GitNexus: [PolyForm Noncommercial](https://github.com/abhigyanpatwari/GitNexus/blob/main/LICENSE)
