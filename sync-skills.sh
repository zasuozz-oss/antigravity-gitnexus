#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# gitnexus-sync — Sync GitNexus skills to Antigravity format
#
# Usage:  gitnexus-sync [project-dir]
#         (defaults to current directory)
#
# GitNexus writes skills to .claude/skills/ (Claude Code format).
# Antigravity reads skills from .agents/skills/<name>/SKILL.md.
# This script bridges the two.
# ══════════════════════════════════════════════════════════════
set -euo pipefail

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}  ✓${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Config ───────────────────────────────────────────────────
PROJECT_DIR="${1:-.}"
CLAUDE_SKILLS="$PROJECT_DIR/.claude/skills"
AGENTS_SKILLS="$PROJECT_DIR/.agents/skills"

# ── Helpers ──────────────────────────────────────────────────

# Check if file already has YAML frontmatter (starts with ---)
has_frontmatter() {
  head -1 "$1" | grep -q '^---$'
}

# Extract first heading line as description fallback
extract_description() {
  grep -m1 '^#' "$1" | sed 's/^#* *//' || echo "GitNexus skill"
}

# Rewrite or inject YAML frontmatter with gitnexus- prefixed name
write_skill_file() {
  local src="$1"
  local dest_dir="$2"
  local skill_name="$3"
  local prefixed_name="gitnexus-${skill_name}"

  mkdir -p "$dest_dir"
  local dest="$dest_dir/SKILL.md"

  if has_frontmatter "$src"; then
    # Has frontmatter — rewrite name with gitnexus- prefix, keep rest
    local in_frontmatter=0
    local frontmatter_done=0
    local description=""

    # First pass: extract existing description
    description=$(awk '
      /^---$/ { count++; next }
      count == 1 && /^description:/ { sub(/^description:[[:space:]]*"?/, ""); sub(/"?$/, ""); print; exit }
    ' "$src")
    [ -z "$description" ] && description=$(extract_description "$src")

    # Write new file with corrected frontmatter
    {
      echo "---"
      echo "name: ${prefixed_name}"
      echo "description: \"${description}\""
      echo "---"
      # Skip original frontmatter, keep body
      awk '
        BEGIN { count=0 }
        /^---$/ { count++; next }
        count >= 2 { print }
      ' "$src"
    } > "$dest"
  else
    # No frontmatter — inject one
    local description
    description=$(extract_description "$src")
    {
      echo "---"
      echo "name: ${prefixed_name}"
      echo "description: \"${description}\""
      echo "---"
      echo ""
      cat "$src"
    } > "$dest"
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  if [ ! -d "$CLAUDE_SKILLS" ]; then
    err "No .claude/skills/ found in $PROJECT_DIR"
    info "Run 'npx gitnexus analyze' first to generate skills."
    exit 1
  fi

  local synced=0

  # ── Sync flat skill files (.claude/skills/*.md) ────────────
  for skill_file in "$CLAUDE_SKILLS"/*.md; do
    [ -f "$skill_file" ] || continue

    local basename
    basename=$(basename "$skill_file" .md)
    local dest_dir="$AGENTS_SKILLS/gitnexus-${basename}"

    write_skill_file "$skill_file" "$dest_dir" "$basename"
    ok "Synced: ${basename} → .agents/skills/gitnexus-${basename}/"
    synced=$((synced+1))
  done

  # ── Sync generated skills (.claude/skills/generated/*/SKILL.md) ──
  if [ -d "$CLAUDE_SKILLS/generated" ]; then
    for gen_dir in "$CLAUDE_SKILLS/generated"/*/; do
      [ -d "$gen_dir" ] || continue
      local skill_file="$gen_dir/SKILL.md"
      [ -f "$skill_file" ] || continue

      local dirname
      dirname=$(basename "$gen_dir")
      local dest_dir="$AGENTS_SKILLS/gitnexus-${dirname}"

      write_skill_file "$skill_file" "$dest_dir" "$dirname"
      ok "Synced: generated/${dirname} → .agents/skills/gitnexus-${dirname}/"
      synced=$((synced+1))
    done
  fi

  if [ "$synced" -eq 0 ]; then
    warn "No skill files found in $CLAUDE_SKILLS"
  else
    echo ""
    info "Synced ${synced} skill(s) to .agents/skills/"
  fi
}

main
