# PlantAID · Video Call 迭代（静态原型）

单页原型：**`index.html`**（固定 **375×812** 量级布局 + `viewport`，便于手机浏览器查看）。

## 本迭代包含

- **Garden**：底部 Tab、快捷面板（含进入 Video Call）。
- **Video Call**：拨打中 / 接通中 / 通话中、浮动 Dock（主页 · 拨打中 · 通话中）、字幕区与 Lottie、铃声与挂断音效。
- **状态栏**：通话流程使用 `assets/vc-status-bar-white.png`（矢量 SVG 已移除）。
- **细节**：参见仓库内 [`ANIMATIONS.md`](ANIMATIONS.md)（动效、脚本与节点对照）。

## 目录结构

| 路径 | 说明 |
|------|------|
| `index.html` | 唯一页面入口（样式与脚本内联为主） |
| `assets/` | 图片、PNG/JPG、音频 MP3、Lottie JSON、`vc-status-bar-white.png` 等 |
| `fonts/` | `Rco.ttf` 图标字体；`merriweather/` 正文西文字体（OFL） |
| `design-tokens.tokens.json` | Design tokens 导出（参考，页面可不读取） |
| `ANIMATIONS.md` | 规格与动画说明 |

## 本地预览

在 **`plantaid`** 目录启动静态服务（避免 `file://` 下音频或字体异常）：

```bash
cd plantaid && python3 -m http.server 8080
```

浏览器打开：**http://127.0.0.1:8080/**

## 部署到 GitHub Pages（手机浏览器打开）

下面两种方式任选其一。

### 方案 A：当前 mono-repo（根目录启用 Pages）

适用于把整个 **`cursor_figma`** 推到 GitHub，只想用手机访问 PlantAID：

1. 在 GitHub **新建仓库**，把仓库根目录设为当前项目根（包含 `plantaid/` 与根目录 `index.html`）。
2. **Settings → Pages**：Source 选 **Deploy from a branch**，Branch **`main`**，文件夹 **`/ (root)`**。
3. 等待站点就绪后访问：
   - **仓库主页跳转**：`https://<用户名>.github.io/<仓库名>/` → 自动跳到 PlantAID；
   - **直达原型**：`https://<用户名>.github.io/<仓库名>/plantaid/`

页面使用相对路径 `assets/`、`fonts/`，在上述 URL 下可用。

### 方案 B：仅发布 PlantAID（独立仓库）

若希望站点根路径就是原型（URL 更短）：

1. 新建空仓库，仅将 **`plantaid/` 内的文件**拷到仓库根（根目录须有 **`index.html`**）。
2. Pages 同样选 **`main`** + **`/ (root)`**。
3. 访问：`https://<用户名>.github.io/<仓库名>/`

### 首次推送示例（命令在你本机终端执行）

```bash
cd /path/to/cursor_figma
git init
git add .
git commit -m "Add PlantAID Video Call prototype and Pages redirect"
git branch -M main
git remote add origin https://github.com/<用户名>/<仓库名>.git
git push -u origin main
```

然后在仓库 **Settings → Pages** 按上文开启。

### 手机端提示

- 使用 **HTTPS** 的 Pages 链接；铃声等多媒体可能在首次交互后才播放（浏览器策略）。
- 原型依赖 CDN 上的 **lottie-web**；离线环境请改为本地脚本。
