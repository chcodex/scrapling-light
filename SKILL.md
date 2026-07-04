---
name: scrapling-light
description: |
  Scrape or extract content from individual web pages using scrapling, with JavaScript rendering, persistent browser sessions, screenshots, and anti-bot bypass for protected pages. Use when asked to fetch a URL, extract page content, render JavaScript, capture a screenshot, or handle Cloudflare/anti-bot pages. Do not use for broad site crawling or downloading entire documentation sites.
allowed-tools: Bash(mcp2cli @scrapling *)
---

# scrapling-light

## Fetch single page

Returns JSON `{status, content: [...], url}`. Content is an array, join before writing.

```bash
mcp2cli @scrapling get --url <url> --main-content-only
mcp2cli @scrapling fetch --url <url> --main-content-only --network-idle
mcp2cli @scrapling stealthy-fetch --url <url> --main-content-only --solve-cloudflare
```

## Bulk fetch

Returns NDJSON — one JSON per line.

```bash
mcp2cli @scrapling bulk-get --urls '["url1","url2"]' --main-content-only
mcp2cli @scrapling bulk-fetch --urls '["url1","url2"]' --main-content-only --network-idle
```

## Sessions

```bash
mcp2cli @scrapling open-session --session-type stealthy
mcp2cli @scrapling list-sessions
mcp2cli @scrapling close-session --session-id <id>
```

## Screenshot

```bash
mcp2cli @scrapling screenshot --url <url> --session-id <id>
```

## Help

```bash
mcp2cli @scrapling <command> --help
```

## Notes

- Always use `--main-content-only` for AI-safe extraction.
- Output is pure JSON. Content is a string array — join before writing to file.
- Check `.status` (200) before using `.content`.
- `get` for static pages, `fetch` for JS rendering, `stealthy-fetch` for Cloudflare.
