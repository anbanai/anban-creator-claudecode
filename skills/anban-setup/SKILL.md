---
name: anban-setup
description: Use when user mentions "初始化", "anban-setup", "第一次使用", "API Key", "密钥", or when MCP tools fail with auth/connection errors suggesting missing ANBAN_API_KEY.
---

# /anban:anban-setup Anban Creator 初始化

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


## 本地 CLI 预检

在调用 `list_projects` 之前，先确保插件内置的本地 `anban` CLI 可用。这个步骤用于视频剪辑等本地媒体能力，用户不需要手动安装二进制。

用 Bash 执行以下检查和自动修复流程：

```bash
ANBAN_CLI=""
ANBAN_DATA="${ANBAN_PLUGIN_DATA:-${CLAUDE_PLUGIN_DATA:-${PLUGIN_DATA:-}}}"
for root in "$ANBAN_DATA"; do
  [ -z "$root" ] && continue
  if [ -x "$root/bin/anban" ]; then
    ANBAN_CLI="$root/bin/anban"
    break
  fi
  if [ -x "$root/bin/anban.exe" ]; then
    ANBAN_CLI="$root/bin/anban.exe"
    break
  fi
done

for root in "${ANBAN_PLUGIN_ROOT:-}" "${CLAUDE_PLUGIN_ROOT:-}" "${PLUGIN_ROOT:-}"; do
  [ -z "$root" ] && continue
  if [ -x "$root/bin/anban" ]; then
    ANBAN_CLI="$root/bin/anban"
    break
  fi
  if [ -x "$root/bin/anban.exe" ]; then
    ANBAN_CLI="$root/bin/anban.exe"
    break
  fi
done

if [ -z "$ANBAN_CLI" ]; then
  for root in "${ANBAN_PLUGIN_ROOT:-}" "${CLAUDE_PLUGIN_ROOT:-}" "${PLUGIN_ROOT:-}"; do
    [ -z "$root" ] && continue
    if [ -x "$root/scripts/bootstrap.sh" ]; then
      ANBAN_PLUGIN_ROOT="$root" CLAUDE_PLUGIN_DATA="$ANBAN_DATA" PLUGIN_DATA="$ANBAN_DATA" "$root/scripts/bootstrap.sh" >/dev/null 2>&1 || true
      for bin_root in "$ANBAN_DATA" "$root"; do
        [ -z "$bin_root" ] && continue
        if [ -x "$bin_root/bin/anban" ]; then
          ANBAN_CLI="$bin_root/bin/anban"
          break 2
        fi
        if [ -x "$bin_root/bin/anban.exe" ]; then
          ANBAN_CLI="$bin_root/bin/anban.exe"
          break 2
        fi
      done
      if [ -x "$root/bin/anban" ]; then
        ANBAN_CLI="$root/bin/anban"
        break
      fi
      if [ -x "$root/bin/anban.exe" ]; then
        ANBAN_CLI="$root/bin/anban.exe"
        break
      fi
    fi
  done
fi

if [ -z "$ANBAN_CLI" ] || ! "$ANBAN_CLI" --help >/dev/null 2>&1; then
  echo "ANBAN_CLI_NOT_READY"
else
  echo "ANBAN_CLI_OK"
fi
```

这里的验证等价于运行 `anban --help`。如果输出 `ANBAN_CLI_NOT_READY`，请用普通用户能理解的话说明：本地视频工具没有准备好，请重新安装 Anban 插件；如果重新安装后仍失败，请联系 Anban 支持。不要要求用户运行构建命令或手动复制文件。

## 预检

尝试调用 `list_projects` MCP 工具：

- **成功** → 输出连接状态和可用项目，结束
- **失败**（认证错误、连接失败）→ 进入下方密钥设置流程

## 用户级配置：API Key

向用户说明：

> Anban Creator MCP 服务器需要 API Key 进行认证。请前往 https://creator.anbanai.com 注册账号并获取 API Key。

Claude Code 版插件已经在 `.claude-plugin/plugin.json` 中声明官方 `userConfig`：

- `api_key`：必填、敏感字段，映射到 MCP Authorization header。
- `api_url`：可选，默认 `https://api.creator.anbanai.com`。

如果 `list_projects` 因认证失败，先提示用户打开 Claude Code 插件配置，填写或更新 Anban 插件的 `api_key`。不要把 API Key 写入项目文件，也不要把密钥打印到日志或最终回答。

仅当用户明确要求兼容旧环境变量方式时，才引导其手动维护 `~/.claude/settings.json` 的 `env.ANBAN_API_KEY`；不得自动写入或覆盖用户配置。

## 项目级配置

API Key 设置完成后，可根据需要提示用户补充项目级配置（写入项目本地的 `.claude/settings.local.json`）。

### 服务地址（可选）

如果用户使用的不是默认地址 `https://api.creator.anbanai.com`，优先让用户在插件配置中修改 `api_url`。旧环境变量兼容方式才写入 `ANBAN_API_URL`。

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

**Agent-Reach 小红书数据预检**：Seednote 外部小红书研究完全走 Agent-Reach。用 Bash 执行 `agent-reach doctor --json` 检查可用性；如果命令不存在或 `xiaohongshu` 无可用 backend，提示用户按 Agent-Reach 官方流程安装/配置：

```text
帮我安装 Agent Reach：https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md
```

不要把 OpenCLI、xiaohongshu-mcp 或 xhs-cli 写成 Anban 自己的安装方案；它们只是 Agent-Reach doctor 选择和提示的 backend。

告知用户：

> 配置完成。**请退出并重新启动 Claude Code**，让 MCP 连接生效。重启后再次运行 `/anban:anban-setup` 验证连接。

## 重启后验证

用户重启 Claude Code 后，`/anban:anban-setup` 的预检步骤应自动执行。预期结果：
- `list_projects` 调用成功，返回可用项目列表
- 输出每个项目的 platform、name 和 ID

## 常见问题

**Q: 重启后 `list_projects` 仍然失败？**
A: 检查 Claude Code 的 Anban 插件配置是否已填写 `api_key`，以及网络是否能访问 `https://api.creator.anbanai.com`（如使用自建服务器，检查 `api_url` 是否正确）。

**Q: 想切换到另一个 API 地址？**
A: 优先在 Claude Code 的 Anban 插件配置中修改 `api_url`，然后重启 Claude Code。

**Q: 已有 API Key 但忘了存在哪里？**
A: Claude Code 会把敏感插件配置保存到安全存储。打开插件配置重新设置 `api_key` 即可。
