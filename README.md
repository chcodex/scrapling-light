# scrapling-light

A lightweight `scrapling` CLI wrapper that proxies commands to a remote Scrapling MCP server via `mcp2cli`. Zero local Scrapling dependencies — no Python libraries, no Chromium browsers on the client machine.

## Architecture

```
scrapling extract get <url> <out>
  → bin/scrapling (shell wrapper, ~270 lines)
    → mcp2cli @scrapling get --url <url> --extraction-type <type>
      → MCP protocol (SSE)
        → Remote Scrapling MCP Server (with full Scrapling + Chromium)
```

## Features

All 10 MCP tools exposed as CLI commands:

| Command | MCP Tool | Description |
|---|---|---|
| `scrapling extract get` | `get` | Static HTTP with TLS fingerprint impersonation |
| `scrapling extract fetch` | `fetch` | Browser-based (Playwright) for JS-heavy pages |
| `scrapling extract stealthy-fetch` | `stealthy_fetch` | Anti-bot bypass, Cloudflare Turnstile solving |
| `scrapling extract bulk-get` | `bulk_get` | Batch static HTTP |
| `scrapling extract bulk-fetch` | `bulk_fetch` | Batch browser rendering |
| `scrapling extract bulk-stealthy-fetch` | `bulk_stealthy_fetch` | Batch stealth scraping |
| `scrapling session open/close/list` | session mgmt | Persistent browser sessions |
| `scrapling screenshot` | `screenshot` | Page screenshots via open session |

## Requirements (client-side)

- [mcp2cli](https://github.com/knowsuchagency/mcp2cli) (v3.x)
- A running Scrapling MCP Server (remote or local)

## Installation

```bash
# Clone
git clone https://github.com/YOUR_USER/scrapling-light.git
cd scrapling-light

# Install manually
## 1. Install mcp2cli (if not installed)
uv tool install mcp2cli

## 2. Configure bake (replace URL with your MCP server)
mcp2cli bake create scrapling --mcp http://localhost:8000/mcp
# or update if already exists:
# mcp2cli bake update scrapling --mcp http://localhost:8000/mcp

## 3. Install wrapper
mkdir -p ~/.local/bin
cp scripts/scrapling ~/.local/bin/scrapling
chmod +x ~/.local/bin/scrapling

## 4. Install skill
mkdir -p ~/.config/opencode/skills/scrapling-official/scripts
cp SKILL.md ~/.config/opencode/skills/scrapling-official/
cp LICENSE.txt ~/.config/opencode/skills/scrapling-official/
cp scripts/scrapling ~/.config/opencode/skills/scrapling-official/scripts/

## 5. Verify
scrapling --help
```

## Usage

```bash
# Simple fetch
scrapling extract get "https://example.com" page.md

# Browser fetch with JS rendering
scrapling extract fetch "https://example.com" page.html --network-idle

# Anti-bot bypass
scrapling extract stealthy-fetch "https://nopecha.com/demo/cloudflare" data.txt --solve-cloudflare

# Multiple URLs (output saved to a single file)
scrapling extract bulk-get results.md "https://site.com/a" "https://site.com/b"

# Session management
scrapling session open --session-type dynamic
scrapling session list
scrapling session close <session-id>

# Screenshot via an open session
scrapling screenshot "https://example.com" screenshot.png --session-id <session-id>

# Always use for prompt injection protection
scrapling extract get "https://site.com" page.md --main-content-only
```

Output format is chosen by file extension:
- `.md` → Markdown
- `.html` → raw HTML
- `.txt` → plain text

## Flag Compatibility

The wrapper translates official Scrapling CLI flags to mcp2cli equivalents automatically:

| Official Flag | Translation |
|---|---|
| `--ai-targeted` | `--main-content-only` |
| `-H "Key: Value"` | `--headers '{"Key":"Value"}'` |
| `-s selector` | `--css-selector selector` |
| `-p key=value` | `--params '{"key":"value"}'` |
| `--no-headless` | (dropped, default is headless) |
| `--no-follow-redirects` | `--follow-redirects false` |
| `--cookies "a=1; b=2"` | `--cookies '{"a":"1","b":"2"}'` |

## Limitations

- **No post/put/delete** — MCP server doesn't expose these.
- **No Python coding** — spiders, sessions API, adaptive parsing require local `pip install scrapling`.
- **No local debug shell** — `scrapling shell` requires local install.

## Updating

```bash
cd scrapling-light
git pull
# Re-run the install steps above (bake update + copy files)
```

## License

BSD 3-Clause (matches Scrapling). See `skill/LICENSE.txt`.
