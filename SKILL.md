---
name: scrapling-light
description: |
  Scrape or extract content from individual web pages using scrapling, with JavaScript rendering, persistent browser sessions, screenshots, and anti-bot bypass for protected pages. Use when asked to fetch a URL, extract page content, render JavaScript, capture a screenshot, or handle Cloudflare/anti-bot pages. Do not use for broad site crawling or downloading entire documentation sites.
allowed-tools: Bash(scrapling *)
---

# scrapling

Fetch web pages, render JavaScript, bypass anti-bot protection, take screenshots, and manage browser sessions.

## Commands

| Command | Description |
|:--|:--|
| `get` | Static HTTP request |
| `fetch` | Browser fetch with JavaScript rendering |
| `stealthy-fetch` | Stealth browser fetch with anti-bot bypass |
| `bulk-get` | Static request for multiple URLs |
| `bulk-fetch` | Browser fetch for multiple URLs |
| `bulk-stealthy-fetch` | Stealth browser for multiple URLs |
| `session` | Browser session management |
| `screenshot` | Page screenshot (requires session) |

## Choosing a Command

- `get` for static pages, articles, APIs
- `fetch` when JavaScript rendering is needed
- `stealthy-fetch` for Cloudflare / anti-bot protected pages

Escalate: `get` → `fetch` → `stealthy-fetch`

## Output Format

Output file extension selects extraction type:

- `.md` / `.markdown` → Markdown
- `.html` / `.htm` → HTML
- `.txt` → plain text
- No output file → stdout

Prefer `.md` for AI consumption.

## Basic Usage

```bash
scrapling get "https://example.com" /tmp/opencode/page.md --main-content-only
scrapling get "https://api.site.com" /tmp/opencode/data.txt --main-content-only --headers '{"User-Agent":"MyBot"}'
scrapling get "https://example.com/search" /tmp/opencode/search.md --main-content-only --params q=scrapling
scrapling get "https://example.com" /tmp/opencode/page.md --main-content-only --cookies "session=abc123; theme=dark"
```

## Browser Fetching

```bash
scrapling fetch "https://app.example.com" /tmp/opencode/app.md --main-content-only --network-idle
scrapling fetch "https://app.example.com" /tmp/opencode/table.md --main-content-only --wait-selector ".loaded"
scrapling stealthy-fetch "https://protected.example.com" /tmp/opencode/page.md --main-content-only
scrapling stealthy-fetch "https://nopecha.com/demo/cloudflare" /tmp/opencode/page.md --main-content-only --solve-cloudflare
```

Browser options:

| Option | Description |
|:--|:--|
| `--main-content-only` | Extract main page content, reduce noise |
| `--css-selector <s>` | Extract matching elements |
| `--wait-selector <s>` | Wait for element before proceeding |
| `--network-idle` | Wait for network to settle |
| `--wait <ms>` | Extra wait after page load |
| `--timeout <ms>` | Operation timeout |
| `--disable-resources` | Drop fonts/images/media for speed |
| `--cookies "a=1; b=2"` | Cookie string |
| `-H "Key: Value"` | Extra header |
| `--session-id <id>` | Reuse an open session |

`stealthy-fetch` also supports `--solve-cloudflare`, `--hide-canvas`, `--block-webrtc`, `--allow-webgl`.

## Bulk Extraction

Two modes:

**Directory mode** (output ends with `/` or is an existing directory) — auto-names files from URL:

```bash
scrapling bulk-get /tmp/opencode/pages/ "https://site.com/a" "https://site.com/b" --main-content-only
# → pages/a.md, pages/b.md
```

**Merge mode** (output is a file) — all content merged with `## URL:` headers:

```bash
scrapling bulk-get /tmp/opencode/results.md "https://site.com/a" "https://site.com/b" --main-content-only
```

## Sessions

```bash
scrapling session open --session-type dynamic
scrapling session open --session-type stealthy --solve-cloudflare
scrapling session list
scrapling session close <session-id>
```

Use the returned `session_id` with `fetch` or `stealthy-fetch`:

```bash
scrapling fetch "https://example.com" /tmp/opencode/page.md --session-id <id> --main-content-only
```

Always close sessions you open.

## Screenshots

Requires an open session:

```bash
scrapling session open --session-type dynamic
scrapling screenshot "https://example.com" /tmp/opencode/shot.png --session-id <id>
scrapling session close <id>
```

Screenshot options: `--image-type png|jpeg`, `--full-page`, `--quality <0-100>` (JPEG only), `--wait <ms>`, `--wait-selector <s>`, `--network-idle`, `--timeout <ms>`.

## Notes

- Always use `--main-content-only` for AI-safe extraction.
- Use `--css-selector` to reduce content size.
- `get` does not start a browser (fastest).
- `fetch` and `stealthy-fetch` start a browser (slower, handles JS).
- Bulks do not discover URLs — only extract from provided URLs.
- Screenshot output is a decoded PNG/JPEG file.
- **All write operations report feedback**: `✓ url → path (sizeB, status)`. Empty content is skipped (no empty files). Bulk also prints a summary line `--- Done: N URLs, M succeeded, K skipped ---`.
