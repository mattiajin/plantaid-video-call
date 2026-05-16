# Figma → Xcode 高还原：方法论文档

本文面向：**用 Cursor + Figma MCP + Xcode** 做产品级 UI，目标是**可重复、可验收、可演进**，而不是依赖单次 AI 生成或手工改像素。

---

## 1. 目标层：先定义「一致」

在写第一行 UI 代码前，与产品/设计对齐：

| 维度 | 需要决定的内容 |
|------|------------------|
| 设备与基准 | 例如 iPhone 15 Pro 逻辑宽度为主，其它机型适配策略 |
| 色彩 | 是否仅 sRGB；是否支持 Dark Mode 变体 |
| 字体 | 动态类型（Dynamic Type）是否必须；否的话注明固定档 |
| 图标 | 自定义 iconfont vs SF Symbols；是否允许近似 |
| 动效 | 哪些必须还原，哪些可 Phase 2 |
| 误差 | 允许的 pt/色差范围（避免无限迭代） |

**产出物**：一段话写进 issue/PR 模板，避免「感觉不像」无法收尾。

---

## 2. 系统层：把「设计系统」当成接口

设计稿不是最终交付物，**设计系统（tokens + 组件 + 资产规则）才是**。

### 2.1 Token 优先

- Figma **Variables**（颜色、数字、字符串）应对应代码里 **唯一来源**（生成或手写 `Tokens`）。
- 禁止在 View 里散落 `Color(red:…)`，除非是 token 定义本身。
- **Buz 项目**：以 Design System 文件为 token 权威，见 [`buz-figma-sources.md`](buz-figma-sources.md)（`fileKey: WgRhzsK3ikl1aDjWRV2uih`）；屏幕稿仅作布局参考，色值/字重以 Design System 为准。

### 2.2 组件映射表

维护一张轻量表即可（Markdown/Notion）：

| Figma 组件名 | 代码组件 | 备注 |
|--------------|----------|------|
| `NavBar/Home` | `HomeNavBar` |  |
| `Message/Voice` | `VoiceMessageBubble` |  |

有 Code Connect 时，与 Figma 官方流程对齐；没有时，这张表就是人工 Code Connect。

### 2.3 图标字体（iconfont）

- 仓库内保存 **与 Figma 同源** 的 `.ttf`/`.otf`。
- 维护 **码表**：`语义 → Unicode → Figma 上的实例截图或 node**。
- 版本变更时：**同步替换字体文件 + 回归图标屏**。

---

## 3. 工具层：Figma MCP 怎么用才「信息量够」

典型顺序（对单个实现节点）：

1. **`get_variable_defs`**  
   拿到变量与样式，用于建/更新 token。

2. **`get_design_context`**  
   得到结构 + 参考代码 + 资源 URL。  
   **注意**：输出常带 Web 技术栈提示，必须按项目栈**重写**，不能粘贴即用。

3. **`get_screenshot`**（默认开启）  
   作为验收参照；大帧可再按区域拆 node。

4. **过大节点**  
   `get_metadata` 看骨架，再分块拉 `get_design_context`，避免一次上下文爆炸。

5. **FigJam / Make**  
   用对应工具（`get_figjam` 等），不要混用假设。

### 资产策略

- MCP 返回的 `figma.com/api/mcp/asset/...` **会过期**，只适合开发期。
- **上线路径**：Export / CI 拉取 / 设计交付包 → `Assets.xcassets` 或 bundle，并在 PR 里写清来源。

---

## 4. 实现层：SwiftUI 常见「漂移」与对策

| 风险 | 对策 |
|------|------|
| 用「差不多」渐变/模糊 | 从 Dev Mode 抄 stops、角度、半径；复杂时用 `Canvas` 或预渲染图 |
| 用 `clipShape(Circle())` 代替设计蒙版 | 复杂蒙版用 **mask Image** 或导出 PNG/WebP |
| 任意 `GeometryReader` 全局缩放 | 易扭曲字号与触摸热区；优先 **按约束 + 设计基准宽度** |
| 忽略 Safe Area | 与 Figma「含状态栏/不含」不一致；用 `safeAreaInset` 明确 |
| 动态类型未测 | 若产品要求支持，必须在验收里单列 |

---

## 5. 验证层：可重复的验收（核心）

### 5.1 截图叠加（最低成本）

1. Figma：选中同一 Frame，导出 PNG 或截屏（1x 与设备一致最好）。
2. 模拟器：同设备截图。
3. 在 Keynote/Figma/PS：**50% 透明度叠加**，差异一眼可见。

### 5.2 检查表（建议 PR 勾选）

- [ ] 颜色来自 token，无明文魔法色（除 token 文件）
- [ ] 字号/字重与样式表一致
- [ ] 间距为 token 的整数倍（若设计如此约定）
- [ ] 自定义图标与码表一致
- [ ] 关键屏截图叠加已做，偏差已写说明或已修

### 5.3 自动化（可选）

- 快照测试：适合 **稳定屏**；注意渲染差异（抗锯齿、字体）。
- CI 上固定模拟器型号，减少噪声。

---

## 6. 流程层：建议的迭代节奏

1. **Token + 骨架**（灰盒布局对即可）  
2. **样式对齐**（色、字、圆角、描边）  
3. **资源与图标**（替换占位图、iconfont）  
4. **动效与边界**（加载、空态、大字体）  

每一轮都带 **截图叠加**，避免最后集中爆炸。

---

## 7. 反模式（尽量避免）

- 直接把 MCP 的 React/Tailwind **翻译**成 Swift 而不重建约束关系。
- 无 token，靠「调一点」直到顺眼。
- 无截图验收，仅凭记忆对比 Figma。
- 图标字体无码表，靠试 Unicode。
- 长期依赖 MCP 临时图链不做资产化。

---

## 8. 给 Agent / Prompt 用的「前提块」（可粘贴）

见仓库 `prompts/agent-preamble-figma-swiftui.md`。

---

## 9. 与本仓库的配套

- **Skill**：`.cursor/skills/figma-to-xcode/SKILL.md`（精简执行版）  
- **本文**：展开说明与检查表  
- **示例工程**：`xcode_test/`（具体实现需按上文流程迭代，不等同于「终稿」）

更新本文时：同步检查 Skill 是否需指向同一「Definition of Done」。

---

## 10. 实战复盘：可复用的注意事项、教训与流程（Lobby / Chat 等叠层屏）

本节从「Playground 屏幕稿 + Chat 浮层」一类需求中抽象出**跨项目可复用**的要点；与上文第 1–9 节互补，偏**叠层、动效与布局钉死**。

### 10.1 锁定「唯一真源」再开工

| 做法 | 说明 |
|------|------|
| 写明 **主 Frame** | 例如 Lobby `node-id=1-6938`、Chat 整屏 `1-6701`、Chat Page 容器 `1-6705`、Chat Frame `1-6940`；PR/对话里只引用这些，避免混用旧 node。 |
| 区分 **Playground** 与 **Design System** | 布局、结构以屏幕稿为准；**色 / 变量冲突时**以 Buz Specs（`buz-figma-sources.md`）为准，并在代码注释或 PR 中写一句「冲突时以 DS 为准」。 |
| **Dev Mode CSS** 与 **iOS** | CSS `border-radius: 30px` 对应 SwiftUI 时要区分 **`RoundedCornerStyle.continuous`（squircle）** 与 **`.circular`（圆弧）**；与外层手机框若同为 continuous，接缝往往更顺。 |

### 10.2 从常见错误中学习（本类需求高频）

| 现象 | 常见原因 | 对策 |
|------|----------|------|
| 圆角/描边「差一口气」 | 只用 `clipShape`，子层半透明或模糊在圆角处渗色 | 对整块先 **`.compositingGroup()`** 再 `background` + `clipShape`；或保证背景与裁切用**同一 Shape**。 |
| Chat 顶与导航条之间 **有缝** | `Spacer` + `bottom` 对齐在 **GeometryReader × scale** 下舍入不一致 | 用 **固定高度** 钉死：`topInset(116) + sheetHeight(696) = 812`，`VStack` **顶对齐**，少用 Spacer 推高度。 |
| 叠层后 **顶栏图标与稿不一致** | 稿里 **Mask 上下有两套 Tool Bar**（如 `1:6702` vs `1:6704`），Chat 打开时可能 **无 Search** | 对照 **当前选中 node** 的 DOM/代码，**条件渲染**导航按钮，不要假设「整 App 同一套 Nav」。 |
| 横向轮播 **初始位置不对** | 默认从 contentOffset 0 开始，中心列不在视口中央 | `ScrollViewReader` + `scrollTo(id, anchor: .center)`，**onAppear** 里 `DispatchQueue.main.async` 再滚，避免布局未完成。 |
| MCP **图裂** | `figma.com/api/mcp/asset/...` **约 7 天过期** | 开发期可占位；合并前 **导出进 Asset** 或稳定 CDN，并在资源处注释 node。 |

### 10.3 叠层屏（Mask + Sheet）推荐流程

1. **读 Figma 层级顺序**：`Mask` 是全屏还是 `inset`？Toolbar 与 Chat Page **谁在 Mask 之上**（z-order）？这决定 **压暗区域** 与 **哪些控件保持高亮**。  
2. **实现顺序**：先 **几何**（顶距、高度、全宽）→ 再 **圆角与背景** → 再 **蒙版透明度** → 最后 **动效**。  
3. **验收**：同一 **fileKey + node** 拉 `get_screenshot`，与模拟器 **并排或叠加**；叠层类问题 **截图比只看代码更快**。

### 10.4 SwiftUI 实现备忘（值得写进 `DesignTokens` 的）

- **Chat Page**：`chatSheetTopInset`（如 116）、`chatSheetTopCorner`（如 30）、`chatOverlayMaskOpacity`（如 0.7）；**横向列表**内边距、**ScrollView** 内 `listTopInset` / `listBottomInset`（如 20 / 66）。  
- **异形圆角**（如转写条内层 `13px + 2px`）：**不要**用单一 `cornerRadius`；用 **`UnevenRoundedRectangle`** 或命名常量，与 Dev 里四个角分开写的一致。  
- **横向可滑动头像行**：`ScrollView(.horizontal)` + 列宽与稿一致；**peek 列**可改为内容内一列，用滑动替代 overlay offset，避免「只能露一截」与稿永久不一致。

### 10.5 与 Skill / Agent 的配合

- 执行流仍以 **`.cursor/skills/figma-to-xcode/SKILL.md`** 为准；本节作为 **方法论 §10** 的「叠层与钉位置」补充。  
- 用户若提供 **工作区 PNG**，优先以 **文件路径** 为视觉验收基准（Skill 已说明图像描述不足以像素级对齐）。

---

*§10 可随新屏复盘增量更新；重大结论建议同步一行到 SKILL 的「常见偏差」表。*
