---
name: humanizer
version: 2.8.0
description: 'Use when 去除文本中的 AI 生成痕迹（去 AI 味），使文章更自然、更像人类书写。基于维基百科《Signs of AI writing》指南（WikiProject AI Cleanup 维护），检测并修正 33 类 AI 写作模式。当写作流程需要去除 AI 痕迹，或用户提到「去 AI 味」「去痕」「humanize」「润色得像真人写的」时使用。由 content-writing / seednote-writing / ecommerce-copywriting 在写作流程中调用，对中文正文就地改写。'
license: MIT
compatibility: claude-code opencode
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Humanizer：去除 AI 写作痕迹（去 AI 味）

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。

> **来源与许可证**：本 skill 内置自 [blader/humanizer](https://github.com/blader/humanizer) v2.8.0（MIT License），内容基于维基百科 [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)（WikiProject AI Cleanup 维护）。完整上游检测清单移到 `references/signs-of-ai-writing.md`；请保留本署名与许可证信息。

## 中文适配说明（先读这段）

本 skill 的 33 类模式源自英文维基百科，但绝大多数是**跨语言的结构性特征**，可直接套用到中文公众号 / 种草 / 电商文案。使用时把英文 tell 按下表映射到中文等价物：

| 类别 | 英文 tell（§） | 中文等价（重点扫这些） |
|------|----------------|------------------------|
| 意义拔高 / 知名度堆砌 | 1, 2 | 「标志着…」「具有重要意义」「见证了…」「为…注入了新的活力」「在…的浪潮中」「不可或缺」等空洞升华 |
| -ing 肤浅分析 | 3 | 「体现了…」「彰显了…」「展现了…」「折射出…」等动名词尾巴 |
| 广告式夸张 | 4 | 「极致」「震撼」「惊艳」「完美」「匠心」「赋能」「打造」（**注意与广告法极限词冲突**——见下游合规检查） |
| 模糊归因 / 鼬鼠词 | 5 | 「业内人士认为」「有观点指出」「众所周知」等无来源判断 |
| AI 高频词 | 7 | 此外、至关重要、深入探讨 / 深度解析、彰显、赋能、打造、助力、致力于、进一步、一系列、诸多 |
| 系动词回避 | 8 | 把「是」硬写成「作为…而存在」「肩负着…」 |
| 否定排比 | 9 | 「不仅…而且…」「不是…而是…」连用 |
| 三段式 | 10 | 凡观点必凑三个、强行排比 |
| 同义词循环 | 11 | 同一对象反复换称呼（主人公 / 主角 / 主人翁） |
| 虚假范围 | 12 | 「从…到…」两端不在同一尺度 |
| 被动 / 无主语 | 13 | 「被广泛认为」「需要指出的是」 |
| 标点 / 排版 | 14, 15, 16, 17, 18, 19 | 破折号（——）滥用、粗体滥用、emoji 装饰标题、弯引号；**标题式大写不适用中文，跳过 §17** |
| 协作 / 讨好痕迹 | 20, 22 | 「希望对你有帮助」「如有需要请联系」「很好的问题」 |
| 填充 / 对冲 | 23, 24, 27 | 「在某种程度上」「可以说」「总的来说」「毋庸置疑」「归根结底」 |
| 空洞结尾 | 25 | 「未来可期」「让我们拭目以待」「值得每个人深思」 |
| 谚语公式 | 32 | 「X 是 Y 的 Z」「X 不是工具，而是镜子」类强行升华 |

**关键原则**：

1. **改写而非删除**：覆盖原文全部信息点，保持段落数与字数量级（原文五段，改写也五段），不丢事实、不增虚构。
2. **保留人味**：中文写作里的人称代入、情绪节奏、口语化与具体细节（真实地名 / 数字 / 引述）都是「人味」，**不要一并抹平**（详见下方「Signs of human writing」）。
3. **零交互**：autonomous 写作流程不提供写作样本，按默认行为改写即可，**不要调用 AskUserQuestion**（该工具仅用于交互式 voice calibration，无样本时回退默认行为）。
4. **不引入违规**：改写后仍须过对应合规检查（公众号违禁词 / 电商广告法极限词 / 种草诱导互动），去 AI **不得**引入新的违规或极限词表述。
5. **看集群而非孤例**：单个破折号或「此外」不算 AI tell；多个 tell 叠加才是。详见下方「What NOT to flag」。

---

## 详细检测清单（按需加载）

完整 33 类英文上游模式、正反例、false positive 规则与 human-writing 线索位于 `references/signs-of-ai-writing.md`。执行以下任务时必须先读取该 reference：

- 需要逐段审计全文 AI 痕迹；
- 需要解释某段为什么像 AI 写作；
- 需要处理英文、双语或高风险长文；
- 中文适配表不足以判断是否要改写。

普通流水线调用可先按「中文适配说明」处理；遇到不确定项再加载 reference，避免每次预加载完整上游清单。

## Process and Output

1. Read the input carefully and identify every instance of the patterns above.
2. Write a **draft rewrite**. Check that it reads naturally aloud, varies sentence length, prefers specific details and simple constructions (is/are/has), and keeps the appropriate register.
3. Ask: **"What makes the below so obviously AI generated?"** Answer briefly with any remaining tells.
4. Revise into a **final rewrite** that addresses them and contains no em or en dashes (see §14).

Deliver the draft, the brief "still-AI" bullets, the final rewrite, and (optionally) a short summary of changes.

## Full Example

**Before (AI-sounding):**
> Great question! Here is an essay on this topic. I hope this helps!
>
> AI-assisted coding serves as an enduring testament to the transformative potential of large language models, marking a pivotal moment in the evolution of software development. In today's rapidly evolving technological landscape, these groundbreaking tools—nestled at the intersection of research and practice—are reshaping how engineers ideate, iterate, and deliver, underscoring their vital role in modern workflows.
>
> At its core, the value proposition is clear: streamlining processes, enhancing collaboration, and fostering alignment. It's not just about autocomplete; it's about unlocking creativity at scale, ensuring that organizations can remain agile while delivering seamless, intuitive, and powerful experiences to users. The tool serves as a catalyst. The assistant functions as a partner. The system stands as a foundation for innovation.
>
> Industry observers have noted that adoption has accelerated from hobbyist experiments to enterprise-wide rollouts, from solo developers to cross-functional teams. The technology has been featured in The New York Times, Wired, and The Verge. Additionally, the ability to generate documentation, tests, and refactors showcases how AI can contribute to better outcomes, highlighting the intricate interplay between automation and human judgment.
>
> - 💡 **Speed:** Code generation is significantly faster, reducing friction and empowering developers.
> - 🚀 **Quality:** Output quality has been enhanced through improved training, contributing to higher standards.
> - ✅ **Adoption:** Usage continues to grow, reflecting broader industry trends.
>
> While specific details are limited based on available information, it could potentially be argued that these tools might have some positive effect. Despite challenges typical of emerging technologies—including hallucinations, bias, and accountability—the ecosystem continues to thrive. In order to fully realize this potential, teams must align with best practices.
>
> In conclusion, the future looks bright. Exciting times lie ahead as we continue this journey toward excellence. Let me know if you'd like me to expand on any section!

**Draft rewrite:**
> AI coding assistants speed up some tasks. In a 2024 study by Google, developers using Codex completed simple functions 55% faster than a control group, but showed no improvement on debugging or architectural decisions.
>
> The tools are good at boilerplate: config files, test scaffolding, repetitive refactors. They are bad at knowing when they are wrong. I have mass-accepted suggestions that compiled, passed lint, and still did the wrong thing because I stopped paying attention.
>
> Mira, an engineer at a fintech startup I interviewed, said she uses Copilot "like autocomplete for boring code" but reviews every line before committing. Jake, a senior dev at a larger company, disabled it after it kept suggesting patterns from a deprecated internal library.
>
> The productivity claims are hard to verify. GitHub says Copilot users "accept 30% of suggestions," but acceptance is not correctness, and correctness is not value. The 2024 Uplevel study found no statistically significant difference in pull-request throughput between teams with and without AI assistants.
>
> None of this means the tools are useless. It means they are tools. They do not replace judgment, and they do not eliminate the need for tests. If you do not have tests, you cannot tell whether the suggestion is right.

**What makes the below so obviously AI generated?**
- The rhythm is still a bit too tidy (clean contrasts, evenly paced paragraphs).
- The named people and study citations can read like plausible-but-made-up placeholders unless they're real and sourced.
- The closer leans a touch slogan-y ("If you do not have tests...") rather than sounding like a person talking.

**Now make it not obviously AI generated.**
> AI coding assistants can make you faster at the boring parts. Not everything. Definitely not architecture.
>
> They're great at boilerplate: config files, test scaffolding, repetitive refactors. They're also great at sounding right while being wrong. I've accepted suggestions that compiled, passed lint, and still missed the point because I stopped paying attention.
>
> People I talk to tend to land in two camps. Some use it like autocomplete for chores and review every line. Others disable it after it keeps suggesting patterns they don't want. Both feel reasonable.
>
> The productivity metrics are slippery. GitHub can say Copilot users "accept 30% of suggestions," but acceptance isn't correctness, and correctness isn't value. If you don't have tests, you're basically guessing.

**Changes made:** Stripped the chatbot framing, significance inflation, promotional and -ing padding, rule-of-three and synonym cycling, false ranges, copula avoidance, em dashes/emojis/boldface/curly quotes, the formulaic "challenges" section, cutoff and hedging disclaimers, filler and persuasive framing, and the generic upbeat conclusion - then rebuilt the voice with varied rhythm and concrete detail.

## Reference

This skill is based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup. The patterns documented there come from observations of thousands of instances of AI-generated text on Wikipedia.

Key insight from Wikipedia: "LLMs use statistical algorithms to guess what should come next. The result tends toward the most statistically likely result that applies to the widest variety of cases."
