#!/bin/bash
#
# dua-loop Installer
# Installs everything into ~/.claude/ so the repo can be deleted after install.
#
# Installed layout:
#   ~/.claude/lib/dualoop/          # Loop script + supporting files
#   ~/.claude/commands/             # Slash commands (/dua, /dua-prd, /tdd)
#   ~/.claude/CLAUDE.md             # dua-loop section appended
#
# Safe install logic for commands:
#   - If target file exists with source_id: dua-loop -> overwrite (update)
#   - If target file exists WITHOUT that source_id -> install with prefix
#   - If target file doesn't exist -> install as-is
#   - Shows version changes on updates
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_ID="dua-loop"
CLAUDE_DIR="$HOME/.claude"
DUALOOP_DIR="$CLAUDE_DIR/lib/dualoop"
PREFIX="dualoop-"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

installed=0
updated=0
prefixed=0
skipped=0

get_version() {
    local file="$1"
    grep -m1 '^version:' "$file" 2>/dev/null | sed 's/version: *//' || echo "unknown"
}

check_and_install() {
    local src="$1"
    local target_dir="$2"
    local filename
    filename="$(basename "$src")"

    mkdir -p "$target_dir"

    local target="$target_dir/$filename"
    local src_version
    src_version="$(get_version "$src")"

    local prefixed_name="${PREFIX}${filename}"
    local prefixed_target="$target_dir/$prefixed_name"

    if [ -f "$target" ] && grep -q "source_id: $SOURCE_ID" "$target" 2>/dev/null; then
        local target_version
        target_version="$(get_version "$target")"

        if [ "$src_version" = "$target_version" ]; then
            echo -e "  ${GRAY}current${NC}  $filename ${GRAY}(v$target_version)${NC}"
            skipped=$((skipped + 1))
        else
            cp "$src" "$target"
            echo -e "  ${BLUE}updated${NC}  $filename ${GRAY}v$target_version -> v$src_version${NC}"
            updated=$((updated + 1))
        fi
    elif [ -f "$prefixed_target" ] && grep -q "source_id: $SOURCE_ID" "$prefixed_target" 2>/dev/null; then
        local target_version
        target_version="$(get_version "$prefixed_target")"

        if [ "$src_version" = "$target_version" ]; then
            echo -e "  ${GRAY}current${NC}  $prefixed_name ${GRAY}(v$target_version)${NC}"
            skipped=$((skipped + 1))
        else
            cp "$src" "$prefixed_target"
            echo -e "  ${BLUE}updated${NC}  $prefixed_name ${GRAY}v$target_version -> v$src_version${NC}"
            updated=$((updated + 1))
        fi
    elif [ -f "$target" ]; then
        cp "$src" "$prefixed_target"
        echo -e "  ${YELLOW}prefixed${NC} $filename -> $prefixed_name ${GRAY}(existing file preserved)${NC}"
        prefixed=$((prefixed + 1))
    else
        cp "$src" "$target"
        echo -e "  ${GREEN}added${NC}    $filename ${GRAY}(v$src_version)${NC}"
        installed=$((installed + 1))
    fi
}

echo ""
echo "========================================="
echo "  dua-loop Installer"
echo "========================================="
echo ""

# --- dua-loop core ---
echo "dua-loop -> $DUALOOP_DIR/"
mkdir -p "$DUALOOP_DIR"
cp "$SCRIPT_DIR/bin/dualoop.sh" "$DUALOOP_DIR/dualoop.sh"
chmod +x "$DUALOOP_DIR/dualoop.sh"
cp "$SCRIPT_DIR/lib/prompt.md" "$DUALOOP_DIR/prompt.md"
cp "$SCRIPT_DIR/agents/verifier.md" "$DUALOOP_DIR/verifier.md"
echo -e "  ${GREEN}copied${NC}   dualoop.sh"
echo -e "  ${GREEN}copied${NC}   prompt.md"
echo -e "  ${GREEN}copied${NC}   verifier.md"
echo ""

# --- Commands ---
echo "Commands -> $CLAUDE_DIR/commands/"
for f in "$SCRIPT_DIR"/commands/*.md; do
    [ -f "$f" ] && check_and_install "$f" "$CLAUDE_DIR/commands"
done
echo ""

# --- CLAUDE.md section ---
echo "Config -> $CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ] || ! grep -q "dua-loop" "$CLAUDE_MD" 2>/dev/null; then
    mkdir -p "$CLAUDE_DIR"
    cat >> "$CLAUDE_MD" << 'SECTION'

## dua-loop - Autonomous Agent Loop

Available globally. Use when a project has `prd.json`:
- `dualoop` — run the autonomous loop (`~/.claude/lib/dualoop/dualoop.sh`)
- `dualoop init` — scaffold a new project
- `/dua-prd` — generate PRD from feature description
- `/dua` — convert PRD to prd.json
- `/tdd` — TDD workflow
SECTION
    echo -e "  ${GREEN}added${NC}    dua-loop section"
    installed=$((installed + 1))
else
    echo -e "  ${GRAY}current${NC}  dua-loop section already present"
    skipped=$((skipped + 1))
fi
echo ""

# --- Summary ---
echo "-----------------------------------------"
echo -e "  ${GREEN}Added:${NC}    $installed"
echo -e "  ${BLUE}Updated:${NC}  $updated"
echo -e "  ${GRAY}Current:${NC}  $skipped"
echo -e "  ${YELLOW}Prefixed:${NC} $prefixed"
echo ""
echo "Installed to ~/.claude/ (repo can be deleted)"
echo ""
