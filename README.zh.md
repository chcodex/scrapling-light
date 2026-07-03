# scrapling-light

轻量级 `scrapling` CLI 包装器，通过 `mcp2cli` 代理命令到远程 Scrapling MCP 服务器。客户端零依赖——无需安装 Python 库、无需 Chromium 浏览器。

## 架构

```
scrapling extract get <url> <out>
  → bin/scrapling (shell 包装器, ~270 行)
    → mcp2cli @scrapling get --url <url> --extraction-type <type>
      → MCP 协议 (SSE)
        → 远程 Scrapling MCP 服务器 (完整 Scrapling + Chromium)
```

## 功能

所有 10 个 MCP 工具均以 CLI 命令形式暴露：

| 命令 | MCP 工具 | 说明 |
|---|---|---|
| `scrapling extract get` | `get` | 静态 HTTP 请求，TLS 指纹模拟 |
| `scrapling extract fetch` | `fetch` | 基于 Playwright 浏览器渲染，支持 JS 动态页面 |
| `scrapling extract stealthy-fetch` | `stealthy_fetch` | 反爬虫模式，可解决 Cloudflare Turnstile |
| `scrapling extract bulk-get` | `bulk_get` | 批量静态 HTTP |
| `scrapling extract bulk-fetch` | `bulk_fetch` | 批量浏览器渲染 |
| `scrapling extract bulk-stealthy-fetch` | `bulk_stealthy_fetch` | 批量反爬虫抓取 |
| `scrapling session open/close/list` | 会话管理 | 持久浏览器会话 |
| `scrapling screenshot` | `screenshot` | 通过打开的浏览器会话截取页面截图 |

## 客户端要求

- [mcp2cli](https://github.com/knowsuchagency/mcp2cli) (v3.x)
- 一个运行中的 Scrapling MCP 服务器（远程或本地）

## 安装

```bash
# 克隆仓库
git clone https://github.com/chcodex/scrapling-light.git
cd scrapling-light

# 安装（会提示输入 MCP 服务器 URL）
bash install.sh
```

或指定服务器 URL：

```bash
bash install.sh --mcp-url http://your-server:8000/mcp
```

### install.sh 做了什么

1. 检查 `mcp2cli` 是否可用
2. 配置 `mcp2cli bake` 指向你的 MCP 服务器
3. 安装包装器到 `~/.local/bin/scrapling`
4. 安装修改后的 Scrapling skill 到 `~/.config/opencode/skills/scrapling-official/`
5. 运行快速连通测试

## 使用示例

```bash
# 简单抓取
scrapling extract get "https://example.com" page.md

# 浏览器渲染（支持 JS）
scrapling extract fetch "https://example.com" page.html --network-idle

# 反爬虫模式（解决 Cloudflare）
scrapling extract stealthy-fetch "https://nopecha.com/demo/cloudflare" data.txt --solve-cloudflare

# 批量抓取多个 URL（结果保存到同一个文件）
scrapling extract bulk-get results.md "https://site.com/a" "https://site.com/b"

# 会话管理
scrapling session open --session-type dynamic
scrapling session list
scrapling session close <session-id>

# 通过打开的会话截取页面截图
scrapling screenshot "https://example.com" screenshot.png --session-id <session-id>

# 始终使用 --main-content-only 防止提示注入攻击
scrapling extract get "https://site.com" page.md --main-content-only
```

输出格式由文件扩展名决定：
- `.md` → Markdown
- `.html` → 原始 HTML
- `.txt` → 纯文本

## Flag 兼容性

包装器自动将官方 Scrapling CLI 参数翻译为 mcp2cli 对应格式：

| 官方参数 | 翻译结果 |
|---|---|
| `--ai-targeted` | `--main-content-only` |
| `-H "Key: Value"` | `--headers '{"Key":"Value"}'` |
| `-s selector` | `--css-selector selector` |
| `-p key=value` | `--params '{"key":"value"}'` |
| `--no-headless` | （跳过，默认即为 headless） |
| `--no-follow-redirects` | `--follow-redirects false` |
| `--cookies "a=1; b=2"` | `--cookies '{"a":"1","b":"2"}'` |

## 局限性

- **没有 post/put/delete** — MCP 服务器未暴露这些工具
- **不支持 Python 编码** — spider、会话 API、自适应解析需要本地 `pip install scrapling`
- **没有本地调试 shell** — `scrapling shell` 需要本地安装

## 更新

```bash
cd scrapling-light
git pull
bash install.sh --update
```

## 许可证

BSD 3-Clause（与 Scrapling 一致）。详见 `skill/LICENSE.txt`。
