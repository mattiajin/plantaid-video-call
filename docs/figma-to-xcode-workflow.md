# Figma → Xcode：以后的工作流（启动清单 + 资源总览）

本文是 **「一开任务就按顺序做」** 的攻略，并把本仓库里**相关文档、脚本、示例工程**集中在一处，便于复用与 onboarding。

---

## 一、先决条件（开启任务前 2 分钟）

| 步骤 | 做什么 |
|------|--------|
| 1 | 明确 **主 Frame**：记下 `fileKey` + `node-id`（或完整 Figma Dev Mode URL）。冲突时 **token 以 Buz Design System 为准**，见 [`buz-figma-sources.md`](buz-figma-sources.md)。 |
| 2 | 在对话里贴 **前置提示** [`prompts/agent-preamble-figma-swiftui.md`](../prompts/agent-preamble-figma-swiftui.md)，或确保项目已关联 Cursor **Skill** `figma-to-xcode`（见 [`.cursor/skills/figma-to-xcode/SKILL.md`](../.cursor/skills/figma-to-xcode/SKILL.md)）。 |
| 3 | 约定 **验收范围**：设备、是否动态类型、是否必须 iconfont 1:1、允许的 pt/色值误差。 |

---

## 二、一步一步：从「开需求」到「可合并」

按顺序执行；**不要跳过验证**（第 7 步）。

| # | 阶段 | 动作 |
|---|------|------|
| **1** | **锁源** | 写出本需求对应的 **主 Frame**（及子节点如 Chat Page、Chat Frame），避免实现中混用旧 node。 |
| **2** | **取数（Figma MCP）** | 对目标节点：`get_variable_defs`（变量/样式）→ `get_design_context`（结构 + 参考代码 + 资源 URL）；大页先 `get_metadata` 再分块。**保留 `get_screenshot`**。 |
| **3** | **Token** | 颜色/语义：从 DS 变量或 `Mode 1.tokens.json` 走 `scripts/figma_tokens_to_swift.py` → `TokenColors.generated.swift`；布局常量进 **`DesignTokens`**，**禁止**魔法数散落。 |
| **4** | **资产** | MCP 的 `figma.com/api/mcp/asset/...` **会过期**，仅作占位；计划内要 **导出进 Asset** 或稳定 CDN，并在 PR 说明。 |
| **5** | **实现** | 先 **布局语义**（对齐/约束方向与 Figma Auto Layout 一致）→ 再填**数值**；圆角/描边用 **token**；叠层屏注意 **Mask / z-order / 顶栏是否变体**（见方法论 §10）。 |
| **6** | **动效** | 若有：参数（spring 时长、曲线）与稿一致；`ScrollViewReader` 等**布局完成后再** `scrollTo`。 |
| **7** | **验收** | **Figma 同帧截图** vs **模拟器截图** 并排或叠加（约 50% 透明度）；偏差写入 PR 或 issue。可选：把工作区 **PNG** 放 `assets/` 或 `docs/reference-screenshots/` 并 @ 路径，便于跨会话复用。 |
| **8** | **收尾** | Definition of Done 勾选（见 [`SKILL.md`](../.cursor/skills/figma-to-xcode/SKILL.md)）；列出「已知偏差」与原因。 |

**复盘**：叠层、圆角、横向滚动等坑见 [`figma-to-xcode-methodology.md`](figma-to-xcode-methodology.md) **§10 实战复盘**。

---

## 三、资源总览（本仓库内，按用途）

| 用途 | 路径 |
|------|------|
| **精简 Skill（何时启用、原则、验收、DoD）** | [`.cursor/skills/figma-to-xcode/SKILL.md`](../.cursor/skills/figma-to-xcode/SKILL.md) |
| **完整方法论（token、MCP、验证、反模式）** | [`docs/figma-to-xcode-methodology.md`](figma-to-xcode-methodology.md) |
| **本文：启动步骤 + 资源索引** | [`docs/figma-to-xcode-workflow.md`](figma-to-xcode-workflow.md) |
| **Buz DS 链接与 `get_variable_defs` 说明** | [`docs/buz-figma-sources.md`](buz-figma-sources.md) |
| **对话前置 Prompt（粘贴到聊天开头）** | [`prompts/agent-preamble-figma-swiftui.md`](../prompts/agent-preamble-figma-swiftui.md) |
| **Token JSON → Swift 生成脚本** | [`scripts/figma_tokens_to_swift.py`](../scripts/figma_tokens_to_swift.py)（输出示例：`xcode_test/BuzLobby/TokenColors.generated.swift`） |
| **示例 Xcode 工程（BuzLobby）** | [`xcode_test/`](../xcode_test/) |
| **仓库入口说明（AGENTS）** | [`AGENTS.md`](../AGENTS.md) |

### 建议放「可复用验收图」的位置

| 目录 | 说明 |
|------|------|
| 仓库内 **`assets/`**（或自建 `docs/reference-screenshots/`） | 存放 Figma 导出 PNG、模拟器对照图，**路径写进 PR**；跨会话比依赖 MCP 截图更稳。 |

---

## 四、与 Cursor / Agent 的配合

1. **项目级**：在 Cursor 中关联 **Skill** `figma-to-xcode`，或把 `AGENTS.md` / 规则指向上述文档。  
2. **每次会话**：用户粘贴 [`agent-preamble-figma-swiftui.md`](../prompts/agent-preamble-figma-swiftui.md) + **主 Frame URL**，可减少重复说明。  
3. **大需求**：先读 **§10**（方法论）再动叠层/复杂屏，避免重复踩坑。

---

## 五、维护约定

- 新增「可复用流程」或「资源入口」时：**更新本文第三节表格**；**重大**结论同步到 `SKILL.md` §常见偏差或延伸阅读。  
- 方法论细节仍以 **methodology.md** 为准；本文不重复长文，只做**索引与步骤**。
