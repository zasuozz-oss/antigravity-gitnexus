#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# GitNexus for Antigravity — auto setup MCP server
#
# Install:  curl -fsSL <raw-url> | bash
#           — or —  ./setup.sh
#
# Update:   ./setup.sh update
# ══════════════════════════════════════════════════════════════
set -euo pipefail

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; DIM='\033[2m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}  ✓${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }
step()  { echo -e "\n${CYAN}── $* ──${NC}"; }

# ── Config ───────────────────────────────────────────────────
ANTIGRAVITY_MCP="$HOME/.gemini/antigravity/mcp_config.json"

# ── Prereqs ──────────────────────────────────────────────────
check_prereqs() {
  step "Checking prerequisites"

  if ! command -v node &>/dev/null; then
    err "Node.js not found. Install Node >= 18 first."; exit 1
  fi
  local node_major
  node_major=$(node -v | sed 's/v//' | cut -d. -f1)
  if (( node_major < 18 )); then
    err "Node >= 18 required (found $(node -v))"; exit 1
  fi
  ok "Node $(node -v)"

  if ! command -v npm &>/dev/null; then
    err "npm not found"; exit 1
  fi
  ok "npm $(npm -v)"
}

# ── Install gitnexus globally ────────────────────────────────
install_gitnexus() {
  step "Installing gitnexus"

  # Check if already installed
  if command -v gitnexus &>/dev/null; then
    local current_ver
    current_ver=$(gitnexus --version 2>/dev/null || echo "unknown")
    ok "gitnexus v$current_ver already installed"
    return
  fi

  info "Installing gitnexus globally..."
  npm install -g gitnexus
  local ver
  ver=$(gitnexus --version 2>/dev/null || echo "unknown")
  ok "gitnexus v$ver installed"
}

# ── Configure Antigravity MCP ────────────────────────────────
configure_mcp() {
  step "Configuring Antigravity MCP"

  if ! command -v python3 &>/dev/null; then
    warn "python3 not found — add manually to $ANTIGRAVITY_MCP:"
    cat << 'EOF'
  "gitnexus": {
    "command": "npx",
    "args": ["-y", "gitnexus@latest", "mcp"]
  }
EOF
    return
  fi

  mkdir -p "$(dirname "$ANTIGRAVITY_MCP")"
  [ -f "$ANTIGRAVITY_MCP" ] || echo '{"mcpServers":{}}' > "$ANTIGRAVITY_MCP"

  local action
  action=$(python3 -c "
import json, sys

path = '$ANTIGRAVITY_MCP'

with open(path) as f:
    cfg = json.load(f)

servers = cfg.setdefault('mcpServers', {})
expected = {
    'command': 'npx',
    'args': ['-y', 'gitnexus@latest', 'mcp']
}
existing = servers.get('gitnexus')

if existing == expected:
    print('unchanged')
    sys.exit(0)

action = 'updated' if existing else 'added'
servers['gitnexus'] = expected

with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')

print(action)
")

  case "$action" in
    added)     ok "MCP entry added (npx gitnexus@latest mcp)" ;;
    updated)   ok "MCP entry updated (npx gitnexus@latest mcp)" ;;
    unchanged) ok "MCP already configured correctly" ;;
  esac
}

# ── Update ───────────────────────────────────────────────────
do_update() {
  echo -e "\n${CYAN}🔄 GitNexus Update${NC}"

  check_prereqs

  step "Updating gitnexus"
  local old_ver
  old_ver=$(gitnexus --version 2>/dev/null || echo "not installed")

  npm install -g gitnexus@latest

  local new_ver
  new_ver=$(gitnexus --version 2>/dev/null || echo "unknown")

  if [ "$old_ver" = "$new_ver" ]; then
    ok "Already on latest (v$new_ver)"
  else
    ok "Updated v$old_ver → v$new_ver"
  fi

  configure_mcp
  print_done "Updated to v$new_ver"
}

# ── Fresh setup ──────────────────────────────────────────────
do_setup() {
  echo -e "\n${CYAN}🔧 GitNexus for Antigravity${NC}"

  check_prereqs
  install_gitnexus
  configure_mcp
  print_done "Setup complete (v$(gitnexus --version 2>/dev/null || echo '?'))"
}

# ── Done banner ──────────────────────────────────────────────
print_done() {
  local msg="${1:-Done}"
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  $msg${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${DIM}Index a repo${NC}   cd your-project && gitnexus analyze"
  echo -e "  ${DIM}Update${NC}         ./setup.sh update"
  echo ""
  echo -e "  ${YELLOW}→ Restart Antigravity to load MCP${NC}"
  echo ""
}

# ── Usage ────────────────────────────────────────────────────
usage() {
  echo "Usage: ./setup.sh [command]"
  echo ""
  echo "Commands:"
  echo "  (none)     Install gitnexus + configure Antigravity MCP"
  echo "  update     Update gitnexus to latest version"
  echo "  help       Show this help"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  case "${1:-}" in
    update|upgrade)  do_update ;;
    help|--help|-h)  usage ;;
    *)               do_setup ;;
  esac
}

main "$@"
