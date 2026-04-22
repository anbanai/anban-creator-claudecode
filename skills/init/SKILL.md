---
name: init
description: Use when user mentions "初始化", "init", "配置", "设置", "setup", "第一次使用", "API Key", "密钥", or when MCP tools fail with auth/connection errors suggesting missing ANBANWRITER_API_KEY.
---

# /init anbanwriter 初始化

## 预检

尝试调用 `list_channels` MCP 工具：

- **成功** → 输出连接状态和可用频道，结束
- **失败**（认证错误、连接失败）→ 进入下方密钥设置流程

## 密钥设置

向用户说明：

> anbanwriter MCP 服务器需要 API Key 进行认证。此密钥由 anbanwriter 服务管理员提供。

通过 AskUserQuestion 向用户索取密钥值。

收到后，使用 Write 工具将密钥写入项目本地的 `.claude/settings.local.json`：

```json
{
  "env": {
    "ANBANWRITER_API_KEY": "<用户提供的密钥>"
  }
}
```

**注意**：如果 `.claude/settings.local.json` 已存在，必须先 Read 读取现有内容，然后用 Edit 合并 `env` 字段，不要覆盖其他已有配置。如果已有 `env` 对象，只添加 `ANBANWRITER_API_KEY` 字段。

`.mcp.json` 中的 `${ANBANWRITER_API_KEY}` 会自动读取此环境变量。此文件已被 gitignore，不会提交到仓库。

告知用户：

> 密钥已写入 `.claude/settings.local.json`。**请退出并重新启动 Claude Code**，让 MCP 连接使用新密钥。重启后再次运行 `/init` 验证连接。
