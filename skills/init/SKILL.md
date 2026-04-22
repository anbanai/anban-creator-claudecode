---
name: init
description: Use when user mentions "初始化", "init", "配置", "设置", "setup", "第一次使用", "API Key", "密钥", or when MCP tools fail with auth/connection errors suggesting missing ANBANWRITER_API_KEY.
---

# /init anbanwriter 初始化

## 概述

引导用户完成 anbanwriter 的首次设置或配置检查。分两个阶段：

- **阶段 A**：客户端密钥设置（MCP 连接前必需）
- **阶段 B**：服务器端配置验证与状态报告

## 预检

尝试调用 `list_channels` MCP 工具：

- **成功** → MCP 已连接，跳到阶段 B
- **失败**（认证错误、连接失败）→ 进入阶段 A

## 阶段 A：MCP 连接密钥设置

### A.1 ANBANWRITER_API_KEY（必需）

向用户说明：

> anbanwriter MCP 服务器需要 API Key 进行认证。此密钥由 anbanwriter 服务管理员提供。

通过 AskUserQuestion 向用户索取密钥值。

收到后，引导用户设置环境变量并持久化：

```bash
# 1. 当前会话立即生效
export ANBANWRITER_API_KEY="<用户提供的密钥>"

# 2. 持久化到 shell 配置（二选一）
echo 'export ANBANWRITER_API_KEY="<密钥>"' >> ~/.zshrc   # zsh
echo 'export ANBANWRITER_API_KEY="<密钥>"' >> ~/.bashrc   # bash
```

### A.2 ANBANWRITER_API_URL（可选）

默认值为 `http://localhost:18060/mcp`。仅在用户服务器不在默认地址时才需设置，设置方式同 A.1。

### A.3 重启提示

告知用户：

> 环境变量已设置。**请退出并重新启动 Claude Code**，让 MCP 连接使用新密钥。重启后再次运行 `/init` 继续。

阶段 A 到此结束，不继续后续步骤。

## 阶段 B：配置验证

### B.1 验证 MCP 连接

调用 `list_channels` MCP 工具列出所有频道。对每个频道调用 `get_account_info(channel_id, scope)` 获取配置详情。

### B.2 检查各平台凭证

根据每个频道的 platform 字段检查对应凭证：

| platform | 必需凭证 |
|----------|----------|
| `article` / `xls` | 微信 AppID + AppSecret |
| `rednote` | 小红书凭证 |
| `flower` | 花卉内容配置 |

如果 `get_account_info` 返回错误或凭证缺失，告知用户需要在 anbanwriter 服务器端配置对应凭证。

### B.3 检查 AI 图片生成

确认图片生成 API 已配置。未配置时告知用户：部分创作流程需要图片生成能力。

### B.4 输出状态报告

格式化输出配置状态摘要：

```
=== anbanwriter 配置状态 ===

MCP 连接: OK
可用频道:
  - article (ID: xxx)  [已配置 / 缺少微信凭证]
  - rednote  (ID: xxx)  [已配置 / 缺少小红书凭证]

写作风格: dan-koe | cultural-depth | casual-science
排版主题: default | apple | autumn-warm | spring-fresh | ocean-calm
图片生成: [已配置 (provider) / 未配置]
```

## 首次运行向导

仅当 B.2 检测到无已配置频道时触发。

### W.1 微信账号凭证

通过 AskUserQuestion 获取 AppID 和 AppSecret。如果 MCP 提供配置写入工具则直接调用，否则告知用户在服务器端配置文件中添加。

### W.2 写作风格

列出可用风格供用户选择：

| 风格 | 说明 |
|------|------|
| `dan-koe` | 简洁有力，深刻犀利 |
| `cultural-depth` | 文化深度，引经据典 |
| `casual-science` | 轻松科普，通俗有趣 |

### W.3 排版主题

列出可用主题供用户选择：`default`、`apple`、`autumn-warm`、`spring-fresh`、`ocean-calm`

### W.4 最终验证

重新调用 `list_channels` 和 `get_account_info` 确认配置已生效。输出就绪报告，告知用户可使用的命令：
- `/article` — 微信公众号文章创作
- `/rednote` — 小红书笔记创作
- `/xls` — 小绿书图片帖创作
- `/flower` — 鲜花图片生成
