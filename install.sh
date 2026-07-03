#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
SKILL_DIR="${HOME}/.config/opencode/skills/scrapling-official"
DEFAULT_MCP_URL="http://192.168.2.245:8000/mcp"

MCP_URL=""
UPDATE_ONLY=false

while [ $# -gt 0 ]; do
    case "$1" in
        --mcp-url) MCP_URL="$2"; shift 2 ;;
        --update)  UPDATE_ONLY=true; shift ;;
        *)         echo "Usage: $0 [--mcp-url <url>] [--update]"; exit 2 ;;
    esac
done

echo "🔍 Checking prerequisites..."

if ! command -v mcp2cli &>/dev/null; then
    echo "❌ mcp2cli not found. Install it first:"
    echo "   pip install mcp2cli"
    exit 1
fi
echo "   ✓ mcp2cli $(mcp2cli --version 2>&1)"

if ! $UPDATE_ONLY; then
    if [ -z "$MCP_URL" ]; then
        read -r -p "Enter MCP server URL [${DEFAULT_MCP_URL}]: " input
        MCP_URL="${input:-$DEFAULT_MCP_URL}"
    fi

    echo ""
    echo "🔧 Configuring mcp2cli bake..."
    if mcp2cli bake list 2>/dev/null | grep -q "^scrapling"; then
        mcp2cli bake update scrapling --mcp "$MCP_URL" 2>/dev/null || \
        mcp2cli bake update scrapling --mcp-url "$MCP_URL" 2>/dev/null || true
    else
        mcp2cli bake create scrapling --mcp "$MCP_URL" 2>&1
    fi
    echo "   ✓ bake configured → $MCP_URL"

    # Quick connectivity test
    echo ""
    echo "🔗 Testing MCP server connection..."
    if mcp2cli @"scrapling" list-sessions 2>/dev/null >/dev/null; then
        echo "   ✓ Server reachable"
    else
        echo "   ⚠️  Server unreachable — check URL and try again"
        echo "      You can re-run: $0 --mcp-url <url>"
    fi
fi

echo ""
echo "📦 Installing wrapper → ${BIN_DIR}/scrapling"
mkdir -p "$BIN_DIR"
cp "${SCRIPT_DIR}/bin/scrapling" "${BIN_DIR}/scrapling"
chmod +x "${BIN_DIR}/scrapling"
echo "   ✓ Installed"

echo ""
echo "📦 Installing skill → ${SKILL_DIR}"
mkdir -p "$SKILL_DIR"
cp -r "${SCRIPT_DIR}/skill/"* "$SKILL_DIR/"
echo "   ✓ $(find "$SKILL_DIR" -type f | wc -l) files installed"

echo ""
echo "🔍 Verifying wrapper..."
if scrapling --help 2>&1 | grep -q "extract"; then
    echo "   ✓ scrapling command works"
else
    echo "   ⚠️  Command not found — ensure ${BIN_DIR} is on PATH"
fi

echo ""
echo "✅ Done!"
if ! $UPDATE_ONLY; then
    echo ""
    echo "Quick test:"
    echo "  scrapling extract get 'https://example.com' test.md"
    echo "  cat test.md"
fi
