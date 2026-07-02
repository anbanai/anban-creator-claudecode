---
name: anban-setup
description: Use when user mentions "初始化", "anban-setup", "第一次使用", "API Key", "密钥", or when MCP tools fail with auth/connection errors suggesting missing ANBAN_API_KEY.
---

# /anban-setup Anban Creator 初始化

## 预检

尝试调用 `list_projects` MCP 工具：

- **成功** → 输出连接状态和可用项目，结束
- **失败**（认证错误、连接失败）→ 进入下方密钥设置流程

## 用户级配置：API Key

向用户说明：

> Anban Creator MCP 服务器需要 API Key 进行认证。请前往 https://creator.anbanai.com 注册账号并获取 API Key。

通过 AskUserQuestion 向用户索取密钥值。

收到后，使用 Write/Edit 工具将密钥写入用户级别的 `~/.claude/settings.json` 的 `env` 字段中：

```json
{
  "env": {
    "ANBAN_API_KEY": "<用户提供的密钥>"
  }
}
```

**注意**：
- 如果 `~/.claude/settings.json` 已存在，必须先 Read 读取现有内容，然后用 Edit 合并 `env` 字段，不要覆盖其他已有配置。
- 如果已有 `env` 对象，只添加 `ANBAN_API_KEY` 字段。
- 这是**用户级别**配置，对所有项目生效，无需在每个项目中重复设置。

## 项目级配置

API Key 设置完成后，提示用户进行项目级配置（写入项目本地的 `.claude/settings.local.json`）。

### 服务地址（可选）

如果用户使用的不是默认地址 `http://localhost:8080`（如远程服务器），写入 `ANBAN_API_URL`：

```json
{
  "env": {
    "ANBAN_API_URL": "<用户的服务地址>"
  }
}
```

### 默认项目（可选）

如果 `list_projects` 返回多个项目，询问用户是否要设置默认项目，写入 `ANBAN_DEFAULT_PROJECT`：

```json
{
  "env": {
    "ANBAN_DEFAULT_PROJECT": "<项目 ID>"
  }
}
```

**项目级配置写入规则**：
- 写入项目本地 `.claude/settings.local.json`（已被 gitignore，不会提交到仓库）。
- 如果文件已存在，必须先 Read 读取现有内容，用 Edit 合并 `env` 字段，不覆盖已有配置。

## 完成

**写作去 AI SKILL 可用性校验**：确认去 AI 味能力已随插件内置——用 Bash 执行 `test -f "${CLAUDE_PLUGIN_ROOT}/skills/humanizer/SKILL.md" && echo OK`（或 Glob 检查 `skills/humanizer/SKILL.md`）。该 SKILL 被 `content-writing`、`seednote-writing`、`ecommerce-copywriting` 写作流程调用，随插件安装即就绪，无需联网或 `git clone`。若缺失，提示用户重新安装 Anban Creator 插件。

告知用户：

> 配置完成。**请退出并重新启动 Claude Code**，让 MCP 连接生效。重启后再次运行 `/anban-setup` 验证连接。

## 重启后验证

用户重启 Claude Code 后，`/anban-setup` 的预检步骤应自动执行。预期结果：
- `list_projects` 调用成功，返回可用项目列表
- 输出每个项目的 platform、name 和 ID

## 常见问题

**Q: 重启后 `list_projects` 仍然失败？**
A: 检查 `~/.claude/settings.json` 中 `ANBAN_API_KEY` 是否正确写入（无多余空格或换行）。检查网络是否能访问 `https://api.creator.anbanai.com`（如使用自建服务器，检查 `ANBAN_API_URL` 是否正确）。

**Q: 想切换到另一个 API 地址？**
A: 编辑 `.claude/settings.local.json`，修改 `ANBAN_API_URL` 的值，然后重启 Claude Code。

**Q: 已有 API Key 但忘了存在哪里？**
A: 检查 `~/.claude/settings.json` 的 `env` 字段。项目级配置在 `.claude/settings.local.json`。
