# Agent 说明（cursor_figma）

本仓库积累 **Figma → Xcode / SwiftUI** 的方法论与可复用提示，供 Cursor Agent 或人工协作使用。

**Buz Design System（tokens 权威）**：[Figma — Specs — Buz New Design System](https://www.figma.com/design/WgRhzsK3ikl1aDjWRV2uih/%F0%9F%93%90-Specs---Buz-New-Design-System?node-id=54426-24751)，`fileKey`: `WgRhzsK3ikl1aDjWRV2uih`。详见 [`docs/buz-figma-sources.md`](docs/buz-figma-sources.md)。

| 用途 | 路径 |
|------|------|
| **精简 Skill（何时用、流程、验收）** | [`.cursor/skills/figma-to-xcode/SKILL.md`](.cursor/skills/figma-to-xcode/SKILL.md) |
| **完整方法论（token、MCP、验证、反模式）** | [`docs/figma-to-xcode-methodology.md`](docs/figma-to-xcode-methodology.md) |
| **工作流总览（启动步骤 + 资源索引）** | [`docs/figma-to-xcode-workflow.md`](docs/figma-to-xcode-workflow.md) |
| **对话前置 Prompt（粘贴到聊天开头）** | [`prompts/agent-preamble-figma-swiftui.md`](prompts/agent-preamble-figma-swiftui.md) |
| **示例 Xcode 工程** | [`xcode_test/`](xcode_test/) |
| **PlantAID 静态原型（Video Call 迭代）** | [`plantaid/README.md`](plantaid/README.md) · 入口 [`plantaid/index.html`](plantaid/index.html)；GitHub Pages 说明见 README |

**建议**：在 Cursor 中将 `figma-to-xcode` Skill 关联到本项目，或把 `prompts/agent-preamble-figma-swiftui.md` 并入团队规则。
