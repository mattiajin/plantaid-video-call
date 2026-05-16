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
| §20 | Video · 拨打界面 vs 接通界面 `.vc-call-screen` 图层过渡 |
| §21 | Video · 翻转相机（`rotateY` keyframes + 根节点 class） |
| §22 | Video · 点按对焦框 `vc-focus-frame-pop` |
| §23 | Video · 底部标题淡入淡出 `vc-hint-caption-fade-io` |
| §24 | Identified sheet + Add To Garden 页面上滑 / 遮罩 |
| §25 | 脚本交互索引 |

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

Video 相关另有 `.vc-phase`、Connecting 胶囊、`vc-info`、**§20–§24**（拨打/接通 UI、相机翻转、对焦、字幕循环、识别抽屉）等的 reduced-motion 规则（见 §12–§13、§15 及后文 §20+）。

---

## 8. 脚本副作用（Quick actions）

- **`aria-expanded`** / **`aria-label`**（「Quick actions」↔「Close quick actions」）
- **`aria-hidden`**：`sheet`、`backdrop`
- **键盘**：`Escape`（在 Garden 页）收起面板；在 Video 页优先用于离开通话（见 §11）

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
| `plantaid/assets/three-dots-loading.json` | Lottie 备选路径（**`joining` / `active` 会话条**共用三点动画） |
| `plantaid/assets/ring-marimba-universfield-487903.mp3` | 等待接通铃声（**仅在 `connecting`** 相位循环） |
| `plantaid/assets/end-call-z31mph1yzr-120633.mp3` | 挂断音效（单次） |
| **CDN** | `lottie-web` **5.12.2**（`cdnjs`）；离线需改本地副本 |

内联 JSON：**`#vc-connecting-lottie-data`**（连接中大圆点 Loader）、**`#vc-active-lottie-data`**（**`#vc-joining-lottie` / `#vc-active-lottie`** 共用三点数据源），避免 `file://` 下无法加载外部 JSON。

---

## 10. 日后对齐 Figma Prototype

若设计稿 **Prototype** 另有精确毫秒或曲线，在本节追加表格；当前数值以工程内 CSS / 脚本为准。

---

## 11. 多页面切换（My Garden ↔ Video Call）

| 项目 | 说明 |
|------|------|
| **Figma · 连接中** | [M3.0.1 · 8543:10380](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8543-10380) |
| **Figma · 接通后** | [M3.0.1_Scanning · 8543:11257](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8543-11257) |
| **根节点** | `#app-screen`，**`data-active-page`**：**`garden`** \| **`video-dialing`** \| **`video-in-call`** \| **`add-garden`** |
| **页面** | **`#page-garden`** · **`#page-video-call`** · **`#page-add-garden`**，激活 **`is-active`** |
| **页面过渡** | `.page`：`opacity` **0.24s** `ease`，配合 `visibility` / `pointer-events` |
| **进入 Video（拨打）** | 快捷菜单 **`data-nav-page="video-dialing"`**；Dock **`data-page="video-dialing"`**（接通后 Dock 会因相位同步为 **`video-in-call`**） |
| **回 Garden** | Dock **`data-page="garden"`**；拨打中断 **`#vc-hangup`**（`.vc-connecting-end-call`）；接通后挂断（含 **`#vc-active-hangup`**）；**`Escape`**（优先离开 Video） |
| **收起通话 UI** | **`#vc-call-minimize`** 等 → 回 Garden，**不播放**挂断音效（`skipHangSound`） |
| **通话阶段** | `#page-video-call`：**`data-video-phase="connecting"`** \| **`"joining"`** \| **`"active"`**（§15、§20） |

---

## 12. Video · 连接中阶段 + 「Connecting」胶囊脉冲

**范围**：`.vc-phase--connecting`（拨打中界面、大号 Lottie、说明卡片、`Connecting…` 胶囊、`#vc-hangup` / `.vc-connecting-end-call` 等）。

**`@keyframes vc-connect-pill-pulse`**

| keyframe | `opacity` | `border-color`（胶囊描边） |
|----------|-----------|----------------------------|
| 0%, 100% | **1** | `rgba(255,255,255,0.2)` |
| 50% | **0.55** | `rgba(255,255,255,0.42)` |

**应用**：**`.vc-phase--connecting:not([aria-hidden="true"]) .vc-connect-pill`** — **`animation: vc-connect-pill-pulse 1.2s ease-in-out infinite`**；离开 connecting 相位后不再有动画。**`cursor: pointer`**（可立即 `advanceVcToJoining()` 跳过等待）。

**`:focus-visible`**：**2px** 白色描边，`outline-offset: 3px`。

**`prefers-reduced-motion`**：**`animation: none !important`**，**`opacity: 1`**，描边复位为 **`rgba(255,255,255,0.2)`**。

---

## 13. Video · 提示卡片（`#vc-info-card`）显示 / 关闭

**常态（展开）**：`opacity: 1`，`transform: translate(-50%, 0) scale(1)`，`visibility: visible`，`transition`：**`opacity` 0.28s**、`cubic-bezier(0.33, 1, 0.68, 1)`；**`transform` 0.32s**，同上 easing；**`visibility`** 瞬时。

**收起（`.vc-info--hidden`）**

| 属性 | 过渡 |
|------|------|
| `opacity` | **0.26s**，`cubic-bezier(0.32, 0, 0.67, 0)` |
| `transform` | **0.3s**，同上 → `translate(-50%, 14px) scale(0.93)` |
| `visibility` | **`hidden`** 延后 **linear 0.3s**，避免淡出未完成即不可交互 |

**关闭按钮**：**`transition`** transform / color / opacity 各 **0.2s**；**`hover`** 提亮；**`active`**：`scale(0.88)`、`opacity: 0.85`。

**`prefers-reduced-motion`**：过渡时长缩至 **0.01ms**，延迟清零；收起时 **`transform`** 复位为 **`translate(-50%, 0) scale(1)`**（仅淡出语义）。

---

## 14. Video · Lottie（连接中 · 大号 Loader）

| 项目 | 说明 |
|------|------|
| **宿主** | **`#vc-connecting-lottie.vc-connecting-lottie-host`**（置于 **`.vc-loader`**，约 **140×140**） |
| **库** | `lottie-web`，**`renderer: svg`**，`loop: true`，**`autoplay: false`**（由脚本 **`play()`**） |
| **数据源** | 优先 **`animationData`**：内联 **`#vc-connecting-lottie-data`**；否则 **`path`**：**`VC_LOTTIE_DIALING_PATH`**（一般为 `assets/loading-spinner-dots.json`） |
| **生命周期** | 脚本 **`ensureVcConnectingLottie`**；**`connecting`** 相位内择机播放；进入 **`joining` / active**、离开页面时 **`pause`** |

---

## 15. Video · 相位 UI + 流程（connecting · joining · active）

**三组相位层**：`.vc-phase--connecting`、`.vc-phase--joining`、`.vc-phase--active` 叠在同一 `#page-video-call` 内；**`data-video-phase`** 控制哪一层可视（与 **§20** 的 **`data-vc-screen`** 拨打 / 接通 UI **配合**，并非重复）。

**`data-video-phase`**

| 值 | 语义（摘要） |
|----|----------------|
| `connecting` | 拨打中：连接 Lottie、`#vc-hangup` / `.vc-connecting-end-call`，铃声等在脚本中驱动 |
| `joining` | 接通缓冲：顶部 **`#vc-joining-card`**、**`#vc-joining-lottie`**、底部「Connecting…」字幕轨道 |
| `active` | 通话中：计时器、字幕 **`#vc-processing-card`**、**`#vc-active-lottie`** 等 |

**切换（脚本）**

| 触发 | 行为 |
|------|------|
| **`vcMediaEnter()`**（进入拨打 Video） | **`setVideoPhase("connecting")`**；约 **5s** 后 **`advanceVcToJoining()`** → **`joining`**；再 **2s** 后 **`advanceVcFromJoiningToActive()`** → **`active`** |
| **`#vc-connect-pill`**（点击 / Enter / Space） | 若仍在 **`connecting`** → **`advanceVcToJoining()`**（跳过 5s 等待） |
| **离开 Video** | **`vcMediaLeave()`** → 复位 **`connecting`**，清除上述定时器 |

**`.vc-phase` CSS**：**`opacity` + `visibility`** 各 **0.28s** `ease`；非当前相位 **`pointer-events: none`**。

**`prefers-reduced-motion`**：`.vc-phase` 等 **`transition-duration: 0.01ms`**（见 `index.html` 内 `@media` 块）。

**其它相关过渡（未单列章节）**：字幕折叠 **`data-vc-subtitles`**（`#vc-processing-card` 等 opacity / transform）；CC 切换图标 **`.vc-sub-toggle-icon`**（约 **0.26s / 0.28s**）；卡片背景字色 **`#page-video-call[data-vc-call-ui="listening"]`** 等——均以 **`index.html`** 为准。

---

## 16. Video · Lottie（接通缓冲 / 会话顶栏 · Three dots）

| 项目 | 说明 |
|------|------|
| **Joining 宿主** | **`#vc-joining-lottie.vc-active-lottie-host`**（约 **59×24**，在 **`#vc-joining-card`** 内可见） |
| **Active 宿主** | **`#vc-active-lottie.vc-active-lottie-host`**（同上尺寸，会话加载态使用） |
| **数据源** | 共用内联 **`#vc-active-lottie-data`**；否则 **`VC_LOTTIE_SUBTITLES_LOADING_PATH`**（`assets/three-dots-loading.json`） |
| **脚本** | **`ensureVcJoiningLottie`**（**`joining`** 相位 **`play()`**）；**`ensureVcActiveLottie`**（**`active`** 需要时 **`play()`**）；离开相位或离开时 **`pause`** |

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
| **`#vc-ring-audio`** | `ring-marimba-universfield-487903.mp3` | **`loop`**；**`connecting`** 相位 **`play()`**；进入 **`joining`** 或 **`active`**、或离开 Video 时 **`pause`** + `currentTime = 0` |
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

## 20. Video · `.vc-call-screen`（拨打图层 vs 接通图层）

**DOM**：**`.vc-call-screen--dialing`** 与 **`.vc-call-screen--in-call`** 叠放在 `#page-video-call` 内。

**状态钩子**：**`data-vc-screen="dialing"`** \| **`"in-call"`** — 由 **`syncVcCallScreenContext()`** 根据 **`data-video-phase`** 同步（**`connecting` → `dialing`**；**`joining` / `active` → `in-call`**）。

**`.vc-call-screen` 过渡**

| 属性 | 时长 | easing |
|------|------|--------|
| `opacity` | **0.38s** | `cubic-bezier(0.32, 0.72, 0, 1)` |
| `visibility` | **0.38s** | `ease` |
| `transform` | **0.38s** | `cubic-bezier(0.32, 0.72, 0, 1)` |

**典型关键帧**（其一隐藏时）：隐藏层带轻微 **`translateY` ±10~12px** 与 **`scale` 0.98~1.02**，形成上下错落切换（详见 `index.html` 选择器）。

**`prefers-reduced-motion`**：**`#page-video-call .vc-call-screen`** 的 **`transition-duration: 0.01ms !important`**。

---

## 21. Video · 翻转相机（`vc-camera-flip-out` / `vc-camera-flip-in`）

**目标元素**：**`.vc-phase--joining` / `.vc-phase--active`** 内 **`.vc-active-bg img`**（`transform-origin: center`，`backface-visibility: hidden`）。

**`@keyframes`**

| 名称 | 路径 | 时长 / 曲线 |
|------|------|----------------|
| **`vc-camera-flip-out`** | `rotateY(0deg)` → **`90deg`** | **420ms** · `cubic-bezier(0.45, 0, 0.55, 1)` · **`forwards`** |
| **`vc-camera-flip-in`** | `rotateY(-90deg)` → **`0deg`** | 同上 |

**类名（根节点）**：`#page-video-call` 依次加上 **`vc-camera-flip-out`** →（半周后换图）→ **`vc-camera-flip-in`**；常量 **`VC_CAMERA_FLIP_HALF_MS = 420`** 与单程动画等长。**`prefersReducedMotion()`** 为真时：**`toggleVcCameraFacing`** 直接换前后摄 **不附加**动画类。

**`prefers-reduced-motion`（CSS）**：上述 **`img`** **`animation: none !important`**。

---

## 22. Video · 点按对焦框 **`vc-focus-frame-pop`**

**元素**：每层 **`.vc-focus-hit`** 内的 **`.vc-focus-frame`**。

**触发**：点击命中层 → **`vc-focus-frame--visible`** · **`animation: vc-focus-frame-pop 0.22s ease-out both`**。

**`@keyframes vc-focus-frame-pop`**：**`from`** `opacity: 0`，`transform: scale(1.06)` → **`to`** `opacity: 1`，`scale(1)`。

**`prefers-reduced-motion`**：可见态 **`animation: none`**（瞬时出现）。

---

## 23. Video · 底部标题淡入淡出 **`vc-hint-caption-fade-io`**

**`@keyframes vc-hint-caption-fade-io`**：**0% / 100%** `opacity: 0` → **50%** `opacity: 1`（呼吸循环）。

**应用**

| 场景 | 选择器 / 条件 | `animation` |
|------|----------------|-------------|
| Joining ·「Connecting…」 | **`.vc-phase--joining:not([aria-hidden="true"]) .vc-joining-caption.vc-call-hint`** | **`vc-hint-caption-fade-io 2.4s ease-in-out infinite`**（另保留 **`.vc-joining-caption`** 的 opacity / transform **过渡**，用于折叠字幕等） |
| Active · 语音提示 | **`.vc-voice-hint.vc-voice-hint--visible`** | 同上 **2.4s** 循环 |
| 禁用 | **`#page-video-call[data-vc-subtitles="collapsed"]`** 下相关节点 | **`animation: none !important`** 等 |

**`prefers-reduced-motion`**：Joining 字幕与 **`.vc-voice-hint--visible`** **`animation: none !important`**，**`opacity: 1 !important`**（保留可读性）。

---

## 24. Post-call · Identified sheet + Add To Garden

**设计对照（识别抽屉）**：[8601:16480](https://www.figma.com/design/13xynwNrbY414RYKcDNrv8/PlantAID?node-id=8601-16480)（见 `index.html` 注释）。

**根状态**：**`.screen.identified-sheet-open`**（与 **`setIdentifiedPlantSheetOpen`** 同步 **`aria-hidden`**）。

**遮罩 `#identified-sheet-backdrop`**

| 状态 | `opacity` / `visibility` |
|------|--------------------------|
| 关 | `0` / `hidden`，**`pointer-events: none`** |
| 开 | `1` / `visible`，可点 |

**过渡**：**`opacity` 0.28s** `ease`；关 → 开时 **`visibility`** 无延迟；开 → 关时 **`visibility` 延迟 0.3s** 再隐藏。

**抽屉 `#identified-plant-sheet`**

| 状态 | `transform` | `opacity` |
|------|-------------|-----------|
| 关 | **`translate(-50%, 100%)`**（沉在底外） | `0` / `hidden` |
| 开 | **`translate(-50%, 0)`** | `1` |

**过渡**：**`transform` 0.42s** `cubic-bezier(0.32, 0.72, 0, 1)`；**`opacity`** 关→开 **0.26s** / 开→关 **0.24s** `ease`；**`visibility`** 与 transform 同步延迟（关态 **0.42s** 后再 `hidden`）。

**全屏 Add**：**`.page--add-garden`** 自 **`translateY(100%)`** 滑入 **`translateY(0)`**；**`opacity` 0.26s** `ease`，**`transform` 0.42s** `cubic-bezier(0.32, 0.72, 0, 1)`。

**Add 内提示条 `.add-garden-tip` 关闭**：**`.add-garden-tip--closing`** — `opacity` / `transform` / `max-height` / `margin` / `padding` / `border-width` 等多属性 **0.24s–0.34s** 过渡（收起为 **0** 高、无上内边距）。

**`.add-garden__plant-block`**：**`margin-top`** 随提示条显隐在 **20px ↔ 40px** 间 **0.32s** 过渡（`:has(...)` 规则）。

**层级**：打开识别抽屉时 **`.page-dock`** **`pointer-events: none`**；**`add-garden`** 时 Dock 抬升仍 **`pointer-events: auto`**（见 CSS 注释）。

**`prefers-reduced-motion`**：**`.identified-sheet-backdrop`**、**`.identified-plant-sheet`**、**`.page--add-garden`**、**`.add-garden-tip`**、**`.add-garden__plant-block`**、复选指示器等 **`transition-duration: 0.01ms !important`**。

---

## 25. 脚本交互索引（便于检索）

| 行为 | 脚本入口 |
|------|-----------|
| 快捷菜单开关 | `#tab-scan-toggle`、`setOpen` |
| 导航 Video / Garden / Add | `.action-sheet-row[data-nav-page]`、`.page-dock__fab`、`setActivePage` |
| 通话相位 | `setVideoPhase`、`advanceVcToJoining`、`advanceVcFromJoiningToActive`、`vcMediaEnter` / `vcMediaEnterInCall` / `vcMediaLeave` |
| Lottie | `ensureVcConnectingLottie`、`ensureVcJoiningLottie`、`ensureVcActiveLottie` |
| 翻转相机 | `toggleVcCameraFacing`、`resetVcCameraFlipVisual`、`VC_CAMERA_FLIP_HALF_MS` |
| 识别抽屉 | `setIdentifiedPlantSheetOpen`（及 `setActivePage` 内 **post-call** 打开逻辑） |
| 挂断 vs 收起免音效 | `setActivePage("garden")` vs `setActivePage("garden", { skipHangSound: true })` |

---

*文档随 `index.html` 迭代更新；若与 Figma Dev Mode 数值冲突，以仓库实现为准并在此标注节点链接便于回溯。*
