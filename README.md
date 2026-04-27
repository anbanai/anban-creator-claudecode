# Anban 智能创作助手 Claude Code 插件

> 微信公众号 & 小红书 & 小绿书 AI 内容创作插件，基于 Claude Code Agent + Skill + MCP 架构。

## 快速开始

### 1. 安装插件

在 Claude Code 中运行：

```
/install-plugin anbanai/anbanwriter-claudecode
```

### 2. 连接平台账号

安装后需要在 [Anban Web 管理端](https://creator.anbanai.com) 注册并创建 API Key，插件会通过 MCP 自动连接平台服务。

> 前往 [https://creator.anbanai.com/settings](https://creator.anbanai.com/settings) 创建 API Key。

### 3. 初始化配置

安装完成后，在 Claude Code 中运行初始化命令，完成配置验证：

```
/init
```

### 4. 开始使用

用自然语言直接描述你的创作需求，插件会自动识别内容类型并启动对应的创作流程：

```
"帮我写一篇关于 AI Agent 的文章"          → 微信公众号图文
"小红书种草笔记，主题是降噪耳机"           → 小红书笔记
"小绿书图片帖，主题是春日穿搭"             → 小绿书图片帖
"帮我生成一组郁金香的鲜花图片"             → 鲜花图片
```

也可以指定 Agent 直接启动：

```
claude --agent anbanwriter:article AI Agent 入门指南
claude --agent anbanwriter:rednote 降噪耳机种草笔记
claude --agent anbanwriter:xls 春日穿搭图片帖
claude --agent anbanwriter:flower 春日鲜花摄影
```

## 支持的创作类型

| 类型 | 触发示例 | 创作流程 |
|------|---------|---------|
| 微信公众号图文 | "帮我写一篇关于 AI Agent 的文章" | 选题研究 → AI 写作 → 去痕优化 → SEO 优化 → 封面配图 → HTML 转换 → 草稿发布 |
| 小红书笔记 | "小红书种草笔记，主题是降噪耳机" | 选题研究 → 内容创作 → 图片规划 → 封面 + 内容配图 → 合规检查 → 归档 |
| 小绿书图片帖 | "小绿书图片帖，主题是春日穿搭" | 选题研究 → 视觉风格 → 图片生成 → 合规检查 → 草稿发布 |
| 鲜花图片 | "帮我生成一组郁金香的鲜花图片" | 花卉研究 → 提示词生成 → 批量图片生成 → 总结 |

## 项目结构

```
├── agents/          # 创作引擎（Agent 定义）
├── skills/          # 独立技能（18 个 Skill）
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
