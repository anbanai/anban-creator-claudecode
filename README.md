# 案板创作助手 Claude Code 插件

微信公众号 & 小红书 & 小绿书 AI 内容创作插件，基于 Claude Code Agent + Skill + MCP 架构。

## 安装

```
/install-plugin anbanai/anbanwriter-claudecode
```

## 支持的创作类型

| 类型 | 触发示例 |
|------|---------|
| 微信公众号图文 | "帮我写一篇关于 AI Agent 的文章" |
| 小红书笔记 | "小红书种草笔记，主题是降噪耳机" |
| 小绿书图片帖 | "小绿书图片帖，主题是春日穿搭" |
| 鲜花图片 | "帮我生成一组郁金香的鲜花图片" |

## 项目结构

```
├── agents/          # 创作引擎
├── skills/          # 独立技能
├── hooks/           # 质量检查钩子
├── themes/          # 排版主题 (YAML)
└── writers/         # 写作风格 (YAML)
```

## License

MIT
