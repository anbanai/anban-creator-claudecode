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

收到后，引导用户设置环境变量并持久化：

```bash
# 1. 当前会话立即生效
export ANBANWRITER_API_KEY="<用户提供的密钥>"

# 2. 持久化到 shell 配置（二选一）
echo 'export ANBANWRITER_API_KEY="<密钥>"' >> ~/.zshrc   # zsh
echo 'export ANBANWRITER_API_KEY="<密钥>"' >> ~/.bashrc   # bash
```

告知用户：

> 环境变量已设置。**请退出并重新启动 Claude Code**，让 MCP 连接使用新密钥。重启后再次运行 `/init` 验证连接。
