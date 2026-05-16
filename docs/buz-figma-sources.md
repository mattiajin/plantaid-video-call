# Buz：Figma 源文件索引

## Design System / Tokens（权威）

| 项目 | 值 |
|------|-----|
| **名称** | Specs — Buz New Design System |
| **链接** | [Figma — Specs — Buz New Design System](https://www.figma.com/design/WgRhzsK3ikl1aDjWRV2uih/%F0%9F%93%90-Specs---Buz-New-Design-System?node-id=54426-24751) |
| **`fileKey`** | `WgRhzsK3ikl1aDjWRV2uih` |
| **说明** | 颜色、间距、圆角、字体样式等 **Variables** 的规范来源；实现 UI 时应优先与此对齐，而不是仅从单个屏幕文件抄色值。 |

### MCP 如何拉 Token

- `get_variable_defs`：需指向**绑定了变量的图层**（例如设计系统里的组件实例）。对空画布或仅容器 node 可能提示需先选中图层；可改用文件内任一 **使用了变量的组件** 的 `node-id`（`54426-24751` → `54426:24751` 为整页画布，建议改用组件节点，例如 `58650:37488`）。
- `search_design_system`：在已连接库中按文案搜索组件/变量（以 Figma 文档为准）。

### 与屏幕稿的关系

- **屏幕/流程稿**（如 Playground）：用于布局与文案；**色与字重**应以本 Design System 的变量为准。
- 工程内 `DesignTokens.swift` 应对齐本文件中的命名与 hex；更新变量后应 **再跑一次** `get_variable_defs` 或 Dev Mode 导出，再同步代码。

---

## 示例：屏幕稿（历史参考）

| 项目 | 值 |
|------|-----|
| **Playground** | `ruZpg4uHSedL0o2ITsve2U`（如 Lobby 等实验画面） |

屏幕文件用于 **结构参考**；token 以 Design System 文件为准。
