#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# Test suite for sync-skills.sh
# Run: bash test-sync.sh
# ══════════════════════════════════════════════════════════════
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
PASS=0; FAIL=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync-skills.sh"
TMPDIR_BASE="$(mktemp -d)"

cleanup() { rm -rf "$TMPDIR_BASE"; }
trap cleanup EXIT

assert_file_exists() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}  ✓ PASS${NC}: $2"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  ✗ FAIL${NC}: $2 — expected file: $1"
    FAIL=$((FAIL+1))
  fi
}

assert_file_not_exists() {
  if [ ! -f "$1" ]; then
    echo -e "${GREEN}  ✓ PASS${NC}: $2"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  ✗ FAIL${NC}: $2 — file should not exist: $1"
    FAIL=$((FAIL+1))
  fi
}

assert_file_contains() {
  if grep -q "$2" "$1" 2>/dev/null; then
    echo -e "${GREEN}  ✓ PASS${NC}: $3"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  ✗ FAIL${NC}: $3 — '$2' not found in $1"
    FAIL=$((FAIL+1))
  fi
}

assert_exit_code() {
  if [ "$1" -eq "$2" ]; then
    echo -e "${GREEN}  ✓ PASS${NC}: $3"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  ✗ FAIL${NC}: $3 — expected exit $2, got $1"
    FAIL=$((FAIL+1))
  fi
}

# ── Test 1: Flat skill file (.claude/skills/exploring.md) ────
test_flat_skill() {
  echo -e "\n── Test 1: Flat skill file ──"
  local dir="$TMPDIR_BASE/t1"
  mkdir -p "$dir/.claude/skills"

  cat > "$dir/.claude/skills/exploring.md" << 'EOF'
# Exploring Skill
Use the knowledge graph to navigate unfamiliar code.
## When to use
When exploring new codebases.
EOF

  (cd "$dir" && bash "$SYNC_SCRIPT")
  assert_file_exists "$dir/.agents/skills/gitnexus-exploring/SKILL.md" \
    "Flat skill → .agents/skills/gitnexus-exploring/SKILL.md"
  assert_file_contains "$dir/.agents/skills/gitnexus-exploring/SKILL.md" \
    "name: gitnexus-exploring" \
    "YAML frontmatter has correct name"
  assert_file_contains "$dir/.agents/skills/gitnexus-exploring/SKILL.md" \
    "description:" \
    "YAML frontmatter has description"
  assert_file_contains "$dir/.agents/skills/gitnexus-exploring/SKILL.md" \
    "knowledge graph" \
    "Original content preserved"
}

# ── Test 2: Generated skill (.claude/skills/generated/<name>/SKILL.md) ──
test_generated_skill() {
  echo -e "\n── Test 2: Generated skill ──"
  local dir="$TMPDIR_BASE/t2"
  mkdir -p "$dir/.claude/skills/generated/auth-module"

  cat > "$dir/.claude/skills/generated/auth-module/SKILL.md" << 'EOF'
---
name: auth-module
description: "Authentication module skill"
---
# Auth Module
Handle authentication flows.
EOF

  (cd "$dir" && bash "$SYNC_SCRIPT")
  assert_file_exists "$dir/.agents/skills/gitnexus-auth-module/SKILL.md" \
    "Generated skill → .agents/skills/gitnexus-auth-module/SKILL.md"
  assert_file_contains "$dir/.agents/skills/gitnexus-auth-module/SKILL.md" \
    "name: gitnexus-auth-module" \
    "Frontmatter name prefixed with gitnexus-"
  assert_file_contains "$dir/.agents/skills/gitnexus-auth-module/SKILL.md" \
    "Authentication" \
    "Original content preserved"
}

# ── Test 3: Skill file already has frontmatter ───────────────
test_existing_frontmatter() {
  echo -e "\n── Test 3: Existing frontmatter ──"
  local dir="$TMPDIR_BASE/t3"
  mkdir -p "$dir/.claude/skills"

  cat > "$dir/.claude/skills/debugging.md" << 'EOF'
---
name: debugging
description: "Trace bugs through call chains"
---
# Debugging with GitNexus
Use call chain analysis.
EOF

  (cd "$dir" && bash "$SYNC_SCRIPT")
  assert_file_exists "$dir/.agents/skills/gitnexus-debugging/SKILL.md" \
    "Skill with frontmatter synced"
  assert_file_contains "$dir/.agents/skills/gitnexus-debugging/SKILL.md" \
    "name: gitnexus-debugging" \
    "Name rewritten with gitnexus- prefix"
}

# ── Test 4: Idempotent — running twice doesn't duplicate ─────
test_idempotent() {
  echo -e "\n── Test 4: Idempotent ──"
  local dir="$TMPDIR_BASE/t4"
  mkdir -p "$dir/.claude/skills"
  echo "# Refactoring" > "$dir/.claude/skills/refactoring.md"

  (cd "$dir" && bash "$SYNC_SCRIPT")
  (cd "$dir" && bash "$SYNC_SCRIPT")

  local count
  count=$(find "$dir/.agents/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  if [ "$count" -eq 1 ]; then
    echo -e "${GREEN}  ✓ PASS${NC}: Idempotent — still 1 skill after 2 runs"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  ✗ FAIL${NC}: Expected 1 SKILL.md, found $count"
    FAIL=$((FAIL+1))
  fi
}

# ── Test 5: No .claude/skills → graceful exit ────────────────
test_no_claude_skills() {
  echo -e "\n── Test 5: No .claude/skills ──"
  local dir="$TMPDIR_BASE/t5"
  mkdir -p "$dir"

  local exit_code=0
  (cd "$dir" && bash "$SYNC_SCRIPT") || exit_code=$?
  assert_exit_code "$exit_code" 1 "Exit code 1 when no .claude/skills"
  assert_file_not_exists "$dir/.agents/skills" \
    "No .agents/skills created"
}

# ── Test 6: Mixed — flat + generated skills together ─────────
test_mixed() {
  echo -e "\n── Test 6: Mixed flat + generated ──"
  local dir="$TMPDIR_BASE/t6"
  mkdir -p "$dir/.claude/skills/generated/api-layer"
  echo "# Impact Analysis" > "$dir/.claude/skills/impact-analysis.md"
  echo "# API Layer" > "$dir/.claude/skills/generated/api-layer/SKILL.md"

  (cd "$dir" && bash "$SYNC_SCRIPT")
  assert_file_exists "$dir/.agents/skills/gitnexus-impact-analysis/SKILL.md" \
    "Flat skill synced"
  assert_file_exists "$dir/.agents/skills/gitnexus-api-layer/SKILL.md" \
    "Generated skill synced"
}

# ── Run all tests ────────────────────────────────────────────
main() {
  echo "═══════════════════════════════════════════"
  echo " sync-skills.sh test suite"
  echo "═══════════════════════════════════════════"

  test_flat_skill
  test_generated_skill
  test_existing_frontmatter
  test_idempotent
  test_no_claude_skills
  test_mixed

  echo ""
  echo "═══════════════════════════════════════════"
  echo -e " Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
  echo "═══════════════════════════════════════════"

  [ "$FAIL" -eq 0 ]
}

main
