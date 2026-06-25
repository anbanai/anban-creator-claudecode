# Anban 智能创作助手 Claude Code 插件

> 微信公众号、种草笔记与直播切片 AI 创作插件，基于 Claude Code Agent + Skill + MCP 架构。

> **从旧版本升级？** `/init` 命令已改名为 `/setup`，以避免与 Claude Code 内置 `/init`（生成 CLAUDE.md）冲突。如果你之前在用 `/init` 配置 API Key，请改用 `/setup`。

## 接入流程

按下面顺序操作，第一次接入最省事：

1. 打开 [Anban Studio / Web 管理端](https://creator.anbanai.com) 注册或登录
2. 在设置页创建 API Key
3. 在 Claude Code 里安装插件
4. 把 API Key 写入 Claude Code 配置
5. 运行 `/setup`
6. 完全退出并重新启动 Claude Code
7. 重启后再次运行 `/setup` 验证连接
8. 开始用自然语言或指定 Agent 创作

---

## 1. 注册账号

访问 [https://creator.anbanai.com](https://creator.anbanai.com)，先注册或登录你的 Anban 账号。

如果你还没有 API Key，后面的插件无法连接平台服务。

## 2. 创建 API Key

登录后前往 [设置页](https://creator.anbanai.com/settings) 创建一个新的 API Key。

- 建议给 Key 起一个容易识别的名字，例如 `My MacBook`、`Office Claude`
- Key 只会在创建成功时完整展示一次
- 如果当时没有复制完整 Key，需要回到设置页重新创建一个新的

## 3. 安装插件

推荐直接在 Claude Code 中安装：

```bash
/install-plugin anbanai/anbanwriter-claudecode
```

安装完成后，可以用 `/plugin` 或插件列表确认插件已经启用。

## 4. 设置 API Key

推荐把 Key 写到 Claude Code 的用户级配置里，这样所有项目都能直接复用。

编辑 `~/.claude/settings.json`，确保有下面这段：

```json
{
  "env": {
    "ANBANWRITER_API_KEY": "你的完整 API Key"
  }
}
```

如果你使用的是 Anban 官方在线服务，可以额外补上服务地址：

```json
{
  "env": {
    "ANBANWRITER_API_KEY": "你的完整 API Key",
    "ANBANWRITER_API_URL": "https://api.creator.anbanai.com"
  }
}
```

如果你接的是自建或本地服务，就把 `ANBANWRITER_API_URL` 改成你自己的服务地址。

如果 `~/.claude/settings.json` 原来已经有别的配置，只需要把 `env` 里的字段合并进去，不要覆盖其他内容。

## 5. 运行 `/setup`

安装并写好 Key 后，在 Claude Code 中运行：

```bash
/setup
```

`/setup` 会帮你检查：

- API Key 是否生效
- MCP 服务是否连通
- 当前账号下有哪些可用项目

## 6. 重启 Claude Code

`/setup` 完成后，请**完全退出并重新启动 Claude Code**。

这是为了让新的环境变量和 MCP 连接真正生效。只刷新当前会话通常不够。

重启以后，再运行一次：

```bash
/setup
```

如果能看到项目列表或连接成功提示，就说明接入已经完成。

## 7. 开始使用

### 方式一：直接说需求

你可以直接输入自然语言，让插件自动识别内容类型：

```text
帮我写一篇关于 AI Agent 的公众号文章
种草笔记，主题是降噪耳机
把 ./live.mp4 做成直播切片
```

### 方式二：指定 Agent

如果你想明确指定流程，也可以直接运行：

```bash
claude --dangerously-skip-permissions --verbose --agent anbanwriter:article AI Agent 入门指南
claude --dangerously-skip-permissions --verbose --agent anbanwriter:seednote 降噪耳机种草笔记
claude --dangerously-skip-permissions --verbose --agent anbanwriter:live-slicer ./live.mp4
```

## 常用命令

- `/setup`
  初始化配置并验证连接
- `/plugin`
  查看插件是否已安装成功
- `anbanwriter:article`
  公众号图文创作
- `anbanwriter:seednote`
  种草笔记创作
- `anbanwriter:live-slicer`
  直播视频切片，需要本机可用 `ffmpeg` 和 `ffprobe`

## 遇到问题时先检查

1. 是否已经在 [设置页](https://creator.anbanai.com/settings) 创建并复制了完整 API Key
2. `~/.claude/settings.json` 里是否真的写入了 `ANBANWRITER_API_KEY`
3. 是否已经完全退出并重启过 Claude Code
4. 重启后是否重新执行过 `/setup`

## 支持的创作类型

| 类型 | 触发示例 | 创作流程 |
|------|---------|---------|
| 微信公众号图文 | "帮我写一篇关于 AI Agent 的文章" | 选题研究 → AI 写作 → 去痕优化 → SEO 优化 → 封面配图 → HTML 转换 → 草稿发布 |
| 种草笔记 | "种草笔记，主题是降噪耳机" | 选题研究 → 爆款拆解（复刻模式）→ 内容创作 → 图片规划 → 封面 + 内容配图 → 合规检查 → 归档 |
| 直播切片 | "把 live.mp4 剪成短视频切片" | ffmpeg 准备音频/封面 → 听悟转写 → 无效句过滤 → 智能切片规划 → 批量裁剪 → 报告 |

## 项目结构

```
├── agents/          # 创作引擎（Agent 定义）
├── skills/          # 独立技能（多个 Skill）
├── hooks/           # 质量检查钩子
├── themes/          # 排版主题 (YAML)
└── writers/         # 写作风格 (YAML)
```

## 其他版本

- [OpenClaw 插件](https://github.com/anbanai/anbanwriter-openclaw) — OpenClaw 平台原生插件版本
- [Web 管理端](https://creator.anbanai.com) — 在线管理后台，支持任务管理、积分充值等

## 加入社群

扫码加入 **Anban 智能创作助手讨论群**，获取使用技巧、功能更新和问题解答：

<img src="community-qr.jpg" alt="Anban 智能创作助手讨论群" width="200">

## License

MIT
