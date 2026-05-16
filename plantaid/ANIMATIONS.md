# PlantAID · 动画说明

本文档描述 `plantaid/index.html` 中的 **CSS 过渡 / keyframes**、**Lottie**、**音频** 及脚本驱动的动效相关状态：触发方式、DOM/CSS 钩子、时长与曲线、无障碍（含 `prefers-reduced-motion`）及与 Figma 的对照索引。

---

## 目录概览

| 章节 | 内容 |
|------|------|
| §1–§8 | Quick actions（FAB、面板、列表错峰、遮罩、层级、`prefers-reduced-motion`） |
| §9 | 相关文件与资产 |
| §10 | Figma Prototype 对齐备忘 |
| §11 | 多页面切换（Garden ↔ Video Call） |
| §12 | Video · 连接中阶段 UI + 「Connecting」胶囊脉冲 |
| §13 | Video · 提示卡片关闭动画 |
| §14 | Video · Lottie（连接中大圆点） |
| §15 | Video · 接通后阶段（8543:11257）与阶段切换 |
| §16 | Video · Lottie（接通后顶部三点） |
| §17 | Video · 通话计时器（脚本） |
| §18 | 音频（铃声循环 / 挂断音效 / 收起免挂断音） |
| §19 | 左侧 Dock（收起 / 折叠箭头 / FAB hover） |

---

## 1. 全局状态（Quick actions）

| 项目 | 说明 |
|------|------|
| **根状态类** | `.screen.action-sheet-open` 加在 `<main class="screen">` 上 |
| **触发控件** | `#tab-scan-toggle`（底部中央绿色 FAB，`aria-expanded` / `aria-label` 随状态切换） |
| **列表容器** | `#plantaid-action-sheet.action-sheet`，`role="dialog"`，`aria-hidden` 随开关更新 |
| **遮罩** | `#action-sheet-backdrop`，`aria-hidden` 同步 |

展开：`backdrop` 点击、`Escape`、任一 `.action-sheet-row` 点击会收起（脚本内逻辑）。

---

## 2. FAB 双图标切换（缩小消失 → 放大出现）

**设计对照**

- 扫描态图标：[8617:3586 · Scan glyph](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8617-3586) — Rco `\uE9A2`，**38px**
- 展开态图标：[8593:8132 · btm_tab（关闭 glyph）](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8593-8132) — Rco `\uE92A`，**30px**

**DOM**

- 容器：`.tab-scan-glyph-stack`（42×42 参考框，便于叠两层 glyph）
- 两层：`span.tab-scan-glyph.tab-scan-glyph--scan` 与 `span.tab-scan-glyph.tab-scan-glyph--close`，均 `position: absolute`，以 `left/top: 50%` + `translate(-50%, -50%)` 同心叠加

**默认（列表收起）**

| 图层 | `transform` | `opacity` | `font-size` |
|------|-------------|-----------|-------------|
| `--scan` | `translate(-50%, -50%) scale(1)` | `1` | `38px` |
| `--close` | `translate(-50%, -50%) scale(0.35)` | `0` | `30px` |

**展开（`.screen.action-sheet-open`）**

| 图层 | 动画目标 | 时长 / 延迟 | easing |
|------|-----------|-------------|--------|
| `--scan` | `scale(0.28)` + `opacity: 0` | **0.22s** / **0s** | `cubic-bezier(0.4, 0, 1, 1)` |
| `--close` | `scale(1)` + `opacity: 1` | **0.3s** / **~0.06–0.08s** | `cubic-bezier(0.34, 1.45, 0.64, 1)` |

**收起**：回到默认时，`--scan` / `--close` 使用各自「未展开」分支上的 `transition`。

语义效果：**扫描图标先缩小并淡出 → 关闭图标略延迟后从小到大并显现**。

---

## 3. 选项列表面板自下而上滑入

**设计对照**：[8593:8051 · list](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8593-8051)

**元素**：`.action-sheet`

| 状态 | `transform` | `opacity` | `pointer-events` |
|------|-------------|-----------|------------------|
| 收起 | `translateY(calc(100% + 120px))` | `0` | `none` |
| 展开 | `translateY(0)` | `1` | `auto` |

**过渡**

| 属性 | 时长 | easing |
|------|------|--------|
| `transform` | **0.38s** | `cubic-bezier(0.32, 0.72, 0, 1)` |
| `opacity` | **0.26s** | `ease` |

---

## 4. 列表行错峰（stagger）

**元素**：`.action-sheet-row`

**收起**：每行 `opacity: 0`，`translateY(16px)`，`transition-delay: 0`。

**展开延迟**

| 选择器 | `transition-delay` |
|--------|-------------------|
| `:nth-child(1)` | **0.07s** |
| `:nth-child(2)` | **0.11s** |
| `:nth-child(3)` | **0.15s** |

**单行**：`opacity` **0.26s** `ease`；`transform` **0.34s** `cubic-bezier(0.32, 0.72, 0, 1)`。

---

## 5. 背景遮罩淡入淡出

**元素**：`#action-sheet-backdrop`

- 颜色：`rgba(13, 14, 18, 0.28)`
- `opacity`：**0.28s** `ease`；收起时 `pointer-events: none`。

---

## 6. 层级（避免 FAB 被遮罩盖住）

| 层 | `z-index` |
|----|-----------|
| `.tabbar` | **10** |
| `.action-sheet` | **9** |
| `.action-sheet-backdrop` | **8** |
| 头部等内容 | ≤ **5** |

左侧 `.page-dock` 为 **400**（见 §19）。

---

## 7. `prefers-reduced-motion: reduce`（Quick actions）

在 `@media (prefers-reduced-motion: reduce)` 内：

- `.action-sheet`、`.action-sheet-backdrop`、`.action-sheet-row`、`.tab-scan-glyph--scan`、`.tab-scan-glyph--close`：**`transition: none !important`**
- `.screen:not(.action-sheet-open) .action-sheet-row`：**`opacity: 1`**、**`transform: none`**
- 展开态 FAB：`--scan` / `--close` 无过渡瞬时切换

Video 相关另有 `.vc-phase`、`Connecting` 胶囊、`vc-info` 等的 reduced-motion 规则（见 §12–§13、§15）。

---

## 8. 脚本副作用（Quick actions）

- **`aria-expanded`** / **`aria-label`**（「Quick actions」↔「Close quick actions」）
- **`aria-hidden`**：`sheet`、`backdrop`
- **键盘**：`Escape`（在 Garden 页）收起面板

---

## 9. 相关文件与资产

| 文件 | 说明 |
|------|------|
| `plantaid/index.html` | 全部 CSS + DOM + 内联脚本 |
| `plantaid/assets/list-row-badge.svg` | Video Call / Chatbot 行红点 |
| `plantaid/assets/video-call-bg.jpg` | Video 背景（连接态虚化裁切 + 接通态清晰铺满） |
| `plantaid/assets/status-bar.png` | 状态栏位图（Video 内需反白处理） |
| `plantaid/assets/tab-home-indicator.svg` | Home Indicator |
| `plantaid/assets/loading-spinner-dots.json` | Lottie 备选路径（连接中大.loader） |
| `plantaid/assets/three-dots-loading.json` | Lottie 备选路径（接通后顶部条） |
| `plantaid/assets/ring-marimba-universfield-487903.mp3` | 等待接通铃声（循环） |
| `plantaid/assets/end-call-z31mph1yzr-120633.mp3` | 挂断音效（单次） |
| **CDN** | `lottie-web` **5.12.2**（`cdnjs`）；离线需改本地副本 |

内联 JSON：`#vc-lottie-data`（连接 Loader）、`#vc-active-lottie-data`（接通后三点），避免 `file://` 下无法加载外部 JSON。

---

## 10. 日后对齐 Figma Prototype

若设计稿 **Prototype** 另有精确毫秒或曲线，在本节追加表格；当前数值以工程内 CSS / 脚本为准。

---

## 11. 多页面切换（My Garden ↔ Video Call）

| 项目 | 说明 |
|------|------|
| **Figma · 连接中** | [M3.0.1 · 8543:10380](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8543-10380) |
| **Figma · 接通后** | [M3.0.1_Scanning · 8543:11257](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8543-11257) |
| **根节点** | `#app-screen`，`data-active-page="garden"` \| `"video-call"` |
| **页面** | `#page-garden` / `#page-video-call`，激活 **`is-active`** |
| **页面过渡** | `.page`：`opacity` **0.24s** `ease`，配合 `visibility` / `pointer-events` |
| **进入 Video** | 菜单 **`data-nav-page="video-call"`**；Dock **`data-page="video-call"`** |
| **回 Garden** | Dock **`data-page="garden"`**；连接中挂断 **`#vc-hangup`**；接通后 **`#vc-active-hangup`**；**`Escape`**（优先离开 Video） |
| **收起通话 UI** | **`#vc-call-minimize`** → 回 Garden，**不播放**挂断音效（`skipHangSound`） |
| **通话阶段** | `#page-video-call` 上 **`data-video-phase="connecting"`** \| **`"active"`**（§15） |

---

## 12. Video · 连接中阶段 + 「Connecting」胶囊脉冲

**范围**：`.vc-phase--connecting`（模糊背景、深色 scrim、头像、`Connecting…` 胶囊、说明卡片、大号 Lottie、单枚挂断）。

**`@keyframes vc-connect-pulse`**

| keyframe | `opacity` |
|----------|---------|
| 0%, 100% | **0.78** |
| 50% | **1** |

**应用**：`.vc-connect-pill`，**`animation`：`vc-connect-pulse` · 2.2s · `ease-in-out` · `infinite`**；**`cursor: pointer`**（可跳过等待接入接通态）。

**`:focus-visible`**：白色outline，便于键盘跳过。

**`prefers-reduced-motion`**：`animation: none`，`opacity: 1`。

---

## 13. Video · 提示卡片（`#vc-info-card`）关闭

**展开**：`opacity: 1`，`transform: translate(-50%, 0) scale(1)`，`visibility: visible`。

**收起（`.vc-info--hidden`）**

| 属性 | 过渡 |
|------|------|
| `opacity` | **~0.26s**，`cubic-bezier(0.32, 0, 0.67, 0)` |
| `transform` | **~0.3s**，同上 → `translate(-50%, 14px) scale(0.93)` |
| `visibility` | **延迟 ~0.3s** 再 `hidden`，避免未播完即不可见 |

**关闭按钮**：`hover` 提亮；**`active`**：`scale(0.88)`、`opacity: 0.85`。

**`prefers-reduced-motion`**：极短过渡；收起时去掉位移缩放（仅瞬时淡出语义）。

---

## 14. Video · Lottie（连接中 · 大号 Loader）

| 项目 | 说明 |
|------|------|
| **容器** | `#vc-lottie.vc-lottie`（外包 `.vc-loader`，约 **168×168**） |
| **库** | `lottie-web`，**`renderer: svg`**，`loop: true`，**`autoplay: false`**（由脚本 `play()`） |
| **数据源** | 优先 **`animationData`**：`#vc-lottie-data`（内联 JSON）；否则 **`path`**：`assets/loading-spinner-dots.json` |
| **视觉** | SVG **`drop-shadow`** 增强白点在深色背景上的可读性 |
| **生命周期** | 进入 Video **连接中**且脚本就绪后播放；离开 Video **`pause`**；切入 **接通后**阶段 **`pause`** |

---

## 15. Video · 接通后阶段 UI + 阶段切换

**DOM**：`.vc-phase--active`（与 `.vc-phase--connecting` 同页叠加，`absolute inset 0`）。

**状态**：`#page-video-call[data-video-phase="active"]` 显示接通 UI；`connecting` 显示连接 UI。

**切换**

| 触发 | 行为 |
|------|------|
| **定时器** | 进入 Video **连接中**后 **~3.8s** 自动 `advanceVcToActive()` |
| **点击 / Enter / Space** | `#vc-connect-pill` 立即接通 |
| **离开 Video** | `vcMediaLeave()` → 重置为 **`connecting`**，清除定时器 |

**`.vc-phase` CSS 过渡**：**`opacity` + `visibility` · ~0.28s** `ease`；非当前阶段 **`pointer-events: none`**。

**`prefers-reduced-motion`**：`.vc-phase` **`transition-duration: 0.01ms`**。

**接通后视觉要点**

- 清晰全屏背景 **`.vc-active-bg`**（无 blur）
- **顶/底渐变**：`.vc-active-grad-top`（100px）、`.vc-active-grad-bottom`（300px），`rgba(0,0,0,0.4)` → 透明
- **顶栏**：`.vc-call-nav` — 计时 `#vc-call-timer`、收起 `#vc-call-minimize`
- **顶部卡片**：`.vc-processing-card` — `chief20` + blur + 白描边；左侧小号 Lottie 宿主 **`#vc-active-lottie`**
- **底部三钮**：`.vc-active-controls` — 挂断（危险色图标）、翻转相机、手电筒（后两者仅占位）

---

## 16. Video · Lottie（接通后 · 顶部三点条）

| 项目 | 说明 |
|------|------|
| **容器** | `#vc-active-lottie.vc-active-lottie-host`（约 **59×24**） |
| **数据源** | **`#vc-active-lottie-data`**（内联）；备选 **`assets/three-dots-loading.json`** |
| **播放** | 进入 **`data-video-phase="active"`** 后 **`play()`**；回到 **`connecting`** 或离开页面 **`pause`** |

---

## 17. Video · 通话计时器（脚本）

| 项目 | 说明 |
|------|------|
| **元素** | `#vc-call-timer` |
| **逻辑** | **`setInterval` 1s**，自接通时刻起累计秒数，格式 **`MM:SS`**（前置零） |
| **启停** | **`setVideoPhase("active")`** 内 **`startVcCallTimer()`**；离开 Video 或回到 **`connecting`** 时 **`stopVcCallTimer()`** |

---

## 18. 音频（非 CSS，与动效同窗）

| ID | 文件 | 行为 |
|----|------|------|
| **`#vc-ring-audio`** | `ring-marimba-universfield-487903.mp3` | **`loop`**；进入 Video **连接中** **`play()`**；**接通后**或离开 **`pause`** + `currentTime = 0` |
| **`#vc-end-call-audio`** | `end-call-z31mph1yzr-120633.mp3` | **单次**；从 Video **返回 Garden** 且 **`skipHangSound` 为假**时播放（挂断/FAB/Escape）；**`#vc-call-minimize`** 使用 **`skipHangSound: true`** |

自动播放受限时，`play()` Promise **`catch`** 静默处理。

---

## 19. 左侧 Dock（`.page-dock`）

**用途**：Garden ↔ Video 切换（原型辅助，非单一 Figma frame）。

**FAB**

- 尺寸 **34×34**，图标 **16px**，**`hover`**：`scale(1.05)`
- **`transition`**：`transform` / `box-shadow` / `background` / `color` **~0.18s**

**收起（`.page-dock--collapsed`）**

- **网格**：`.page-dock__fabs` 为 **`display: grid`**；收起时两枚 FAB **同一 grid cell**，当前页 **`z-index: 1`**，另一枚 **`opacity: 0`、`z-index: 2`**，仍可 **`pointer-events: auto`** —— **单击可视圆钮区域即在两页间切换**（避免旧版 `display:none` 无法点到 Video）。
- **展开**：两行纵向排列，`gap: 6px`。

**折叠按钮 `#page-dock-toggle`**

- **图标**：下行 **SVG 描边 chevron**（**`stroke="currentColor"`**），非字体字形。
- **收起态**：**`.page-dock__toggle-icon`** **`transform: rotate(180deg)`**，**~0.24s** `ease`。
- **`aria-expanded`** / **`aria-label`**：`Collapse` ↔ `Expand screen navigation`。

---

## 20. 脚本交互索引（便于检索）

| 行为 | 脚本入口 |
|------|-----------|
| 快捷菜单开关 | `#tab-scan-toggle`、`setOpen` |
| 导航 Video / Garden | `.action-sheet-row[data-nav-page]`、`.page-dock__fab`、`setActivePage` |
| 通话阶段 | `setVideoPhase`、`advanceVcToActive`、`vcMediaEnter` / `vcMediaLeave` |
| Lottie | `ensureVcLottie`、`ensureVcActiveLottie` |
| 挂断 vs 收起免音效 | `setActivePage("garden")` vs `setActivePage("garden", { skipHangSound: true })` |

---

*文档随 `index.html` 迭代更新；若与 Figma Dev Mode 数值冲突，以仓库实现为准并在此标注节点链接便于回溯。*
