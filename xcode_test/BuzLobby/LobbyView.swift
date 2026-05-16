import SwiftUI

// MARK: - Figma export assets（主 Frame `1:6938` · MCP URLs ~7 天有效）
// 轮播头像等：`16:10490`
// https://www.figma.com/design/ruZpg4uHSedL0o2ITsve2U/Design---Playground---Yexin?node-id=16-10490
private enum FigmaAssets {
    /// Nav `16:10489` Avatar-Image（`imgAvatarImage3`）
    static let navAvatar = URL(string: "https://www.figma.com/api/mcp/asset/3fea9713-0b6a-4b36-855e-74f1a1ac6585")!
    /// Chat List 中心 `16:10490` · `I16:10490;37616:10168`（`imgAvatarImage14` 内容图）
    static let centerAvatar = URL(string: "https://www.figma.com/api/mcp/asset/0c91b534-e54e-4807-acdc-988b7d7c14c1")!
    /// Buz Team 拼贴中复用的人像之一（`imgAvatarImage1`）；完整六格叠层需单独导出切图
    static let sideAvatar = URL(string: "https://www.figma.com/api/mcp/asset/2b5a44bb-7e75-45f1-9f25-25ae18ed8341")!
    /// Content Preview · Loading - Message（`imgLoadingMessage`）
    static let loadingMessage = URL(string: "https://www.figma.com/api/mcp/asset/3de3bd3b-86b4-4f88-b4b6-484ec7d83426")!
    /// ToggleLight 装饰 186×72（`imgGroup1321316808`）
    static let navToggleLight = URL(string: "https://www.figma.com/api/mcp/asset/76c24a08-be5e-4f75-8c96-ddfd8b8b1feb")!
}

struct LobbyView: View {
    private let baseWidth: CGFloat = 375
    private let designHeight: CGFloat = 812

    /// Chat Frame 头像轮播 `ScrollViewReader.scrollTo` 锚点
    private enum LobbyCarouselID: String, Hashable {
        case newChat, center, buzTeam, peek
    }

    /// 点击 Content Preview 后从底部滑入 Chat-new / Friend
    @State private var showChatScreen = false

    /// Playground Lobby `16:10488`：外屏纯黑
    private var lobbyRootBackground: Color { DesignTokens.lobbyScreenBackground }

    private var chatSheetAnimation: Animation {
        .spring(response: 0.45, dampingFraction: 0.88, blendDuration: 0)
    }

    var body: some View {
        ZStack {
            // 铺满整窗（含 Home Indicator 下方），避免安全区外露出默认底色形成「底条 / 边缘细缝」
            lobbyRootBackground
                .ignoresSafeArea()
                .allowsHitTesting(false)

            GeometryReader { geo in
            // 首帧 `geo.size` 可能为 0，若参与计算会得到 scale=0 → Chat Frame / Content Preview 宽度为 0，按钮无法点击
            let gw = max(geo.size.width, 1)
            let gh = max(geo.size.height, 1)
            // 同时适配宽、高，避免 scale 只按宽度放大导致总高度 > 812，底栏被裁切
            let scaleW = gw / baseWidth
            let scaleH = gh / designHeight
            let scale = min(min(scaleW, scaleH), 1.2)
            let contentW = baseWidth * scale
            let contentH = designHeight * scale
            let topInset = DesignTokens.LobbyLayout.chatSheetTopInset * scale
            /// Chat 浮层占满 **可视区** 剩余高度（不再钉死 696×scale）
            /// `gh` 在「未忽略底安全区」时为可视区高度（已不含 Home Indicator），Chat 底栏自然落在安全区内
            let chatSheetHeight = max(0, gh - topInset)

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: DesignTokens.LobbyLayout.statusBarTop * scale)
                    navBar(scale: scale)
                    HStack {
                        Spacer(minLength: 0)
                        chatFrame(scale: scale, contentWidth: contentW)
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                    pushToTalk(scale: scale)
                    Spacer(minLength: 0)
                    bottomToolbox(scale: scale)
                }
                .padding(.bottom, DesignTokens.LobbyLayout.bottomToolboxMargin * scale)
                .frame(width: contentW, height: contentH)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // Figma `1:6701`：Mask 仅压暗导航条以下区域（Chat Frame / PTT / 底栏）
                if showChatScreen {
                    Color.black.opacity(DesignTokens.LobbyLayout.chatOverlayMaskOpacity)
                        .padding(.top, topInset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .allowsHitTesting(false)
                        .zIndex(1)
                }

                // Chat Page：横向铺满 `geo`、纵向 = 屏高 − 顶栏（与 Figma 696 仅在 812 高等效）
                if showChatScreen {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: topInset)
                        ChatFriendView(scale: scale, sheetHeight: chatSheetHeight) {
                            withAnimation(chatSheetAnimation) {
                                showChatScreen = false
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: gw, height: gh, alignment: .top)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
            }
            .frame(width: gw, height: gh, alignment: .top)
            .clipShape(RoundedRectangle(cornerRadius: 50 * scale, style: .continuous))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // 顶 + 左右：与稿一致顶栏占位、横向顶满；底由底层 ZStack 铺色，几何高度仍含底安全区
        .ignoresSafeArea(edges: [.top, .leading, .trailing])
    }

    // MARK: Nav

    /// 与 Figma `Nav Bar - Homepage`：左下 186×72 ToggleLight 装饰 + 前景 HStack（头像 15、Autoplay 自 65、Search 右 65、联系人右 15）。
    /// Chat 打开时 lobby nav bar 保持完整（Search + Contacts 都可见）；Chat History Nav（带返回键）属于 `ChatFriendView` 内部。
    private func navBar(scale: CGFloat) -> some View {
        let edge: CGFloat = 15 * scale
        let avatar: CGFloat = 40 * scale
        let gapAfterAvatar: CGFloat = 10 * scale
        let icon: CGFloat = 40 * scale
        let betweenIcons: CGFloat = 10 * scale
        let navH: CGFloat = 72 * scale

        return ZStack(alignment: .bottomLeading) {
            navToggleLightDecoration(scale: scale)
                .frame(width: 186 * scale, height: navH)
                .allowsHitTesting(false)

            HStack(spacing: 0) {
                Color.clear.frame(width: edge)
                navAvatarBlock(scale: scale)
                    .frame(width: avatar, height: avatar)
                Color.clear.frame(width: gapAfterAvatar)
                autoplayPill(scale: scale)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                navIconButton(glyph: BuzGlyph.search, scale: scale)
                    .frame(width: icon, height: icon)
                Color.clear.frame(width: betweenIcons)
                navIconButton(glyph: BuzGlyph.contacts, scale: scale)
                    .frame(width: icon, height: icon)
                Color.clear.frame(width: edge)
            }
            .frame(maxWidth: .infinity, minHeight: navH, maxHeight: navH)
        }
        .frame(height: navH)
        .background(DesignTokens.lobbyScreenBackground)
    }

    private func navToggleLightDecoration(scale: CGFloat) -> some View {
        AsyncImage(url: FigmaAssets.navToggleLight) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color.clear
            }
        }
        .scaleEffect(x: 1, y: -1)
        .clipped()
    }

    private func navIconButton(glyph: String, scale: CGFloat) -> some View {
        Button(action: {}) {
            Text(glyph)
                .font(BuzGlyph.buz(size: 28 * scale))
                .foregroundStyle(DesignTokens.textWhiteImportant)
        }
        .buttonStyle(.plain)
    }

    /// `2:1821` Avatar touch 40×40：头像 30 居中；红点中心 (35,8)、紫点中心 (35,31)（相对框左上角）
    private func navAvatarBlock(scale: CGFloat) -> some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(DesignTokens.background5)
                    .frame(width: 30 * scale, height: 30 * scale)
                figmaMaskedCircleImage(imageURL: FigmaAssets.navAvatar, size: 30 * scale)
            }

            Circle()
                .fill(DesignTokens.foregroundConsequential)
                .frame(width: 6 * scale, height: 6 * scale)
                .overlay(Circle().stroke(DesignTokens.lobbyScreenBackground, lineWidth: 4 * scale))
                .offset(x: 15 * scale, y: -12 * scale)

            Circle()
                .fill(DesignTokens.foregroundDND)
                .frame(width: 8 * scale, height: 8 * scale)
                .overlay(Circle().stroke(DesignTokens.lobbyScreenBackground, lineWidth: 4 * scale))
                .offset(x: 15 * scale, y: 11 * scale)
        }
        .frame(width: 40 * scale, height: 40 * scale)
    }

    /// Figma `16:10489`：32×min106 · padding 3 · gap 3 · `Brand/20` + `linear-gradient(90deg, rgba(61,56,95,0.1) → #3D385F)`；左扬声器 `Foreground/Highlight`
    private func autoplayPill(scale: CGFloat) -> some View {
        let h = DesignTokens.AutoplayNav.height * scale
        let pad = DesignTokens.AutoplayNav.padding * scale
        let gap = DesignTokens.AutoplayNav.gap * scale
        let minW = DesignTokens.AutoplayNav.minWidth * scale
        let innerH = h - pad * 2
        let speakerIcon = max(12 * scale, innerH * 0.55)

        return HStack(spacing: gap) {
            ZStack {
                Circle()
                    .fill(DesignTokens.foregroundHighlight)
                Text(BuzGlyph.autoplaySpeaker)
                    .font(BuzGlyph.buz(size: speakerIcon))
                    .foregroundStyle(DesignTokens.textBlackPrimary)
            }
            .frame(width: innerH, height: innerH)

            Text("Autoplay")
                .font(AppFont.nunito(.semibold, size: 12 * scale))
                .foregroundStyle(DesignTokens.foregroundHighlight)
                .lineLimit(1)

            Text(BuzGlyph.autoplayChevron)
                .font(BuzGlyph.buz(size: 14 * scale))
                .foregroundStyle(DesignTokens.keysBrand50.opacity(0.92))
        }
        .padding(pad)
        .frame(minWidth: minW)
        .frame(height: h)
        .background(
            ZStack {
                Capsule()
                    .fill(DesignTokens.keysBrand20)
                Capsule()
                    .fill(PlaygroundApproxColors.autoplayOverlayGradient)
            }
        )
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }

    // MARK: Chat frame

    /// Chat Frame：内容 VStack → `.background()` 填色 → `.clipShape()` 裁切 → `.overlay(.stroke())` 画边框
    /// 顺序关键：clipShape 先裁切 peek 圆头像；stroke overlay 在裁切层之上，保持完整 1pt 线宽
    private func chatFrame(scale: CGFloat, contentWidth: CGFloat) -> some View {
        let corner = DesignTokens.LobbyLayout.chatFrameCorner * scale
        let designFrameW = DesignTokens.LobbyLayout.chatFrameWidth * scale
        /// 岛区变窄时 Chat Frame 随 `contentWidth` 收缩（左右各留 0）
        let chatFrameW = min(designFrameW, max(0, contentWidth))
        let innerPreviewW = max(0, chatFrameW - 6 * scale)

        return VStack(spacing: 0) {
            chatListRow(scale: scale, suggestionStripMaxWidth: min(323 * scale, max(0, chatFrameW - 20 * scale)))
                .frame(height: DesignTokens.LobbyLayout.chatListBlockHeight * scale)

            Color.clear.frame(height: DesignTokens.LobbyLayout.chatListToPreviewGap * scale)

            Button {
                withAnimation(chatSheetAnimation) {
                    showChatScreen = true
                }
            } label: {
                messagePreview(scale: scale, cardWidth: innerPreviewW)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 3 * scale)
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.messageCardCorner * scale, style: .circular))
        }
        .padding(.top, DesignTokens.LobbyLayout.chatListTopInset * scale)
        .padding(.bottom, DesignTokens.LobbyLayout.chatFrameBottomInset * scale)
        .frame(
            width: chatFrameW,
            height: DesignTokens.LobbyLayout.chatFrameHeight * scale
        )
        .background(DesignTokens.chatFrameFill,
                    in: RoundedRectangle(cornerRadius: corner, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(DesignTokens.chatFrameStroke, lineWidth: 1 * scale)
        )
    }

    /// 头像轮播 + 建议条（`1:6940` Chat List）。
    /// 横向 `ScrollView`：可左右滑动查看 New Chat / ALoHa / Buz Team / peek；出现时弹簧动画滚到中心列。
    private func chatListRow(scale: CGFloat, suggestionStripMaxWidth: CGFloat) -> some View {
        let carouselSpring = Animation.spring(response: 0.45, dampingFraction: 0.86)
        return VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        Color.clear.frame(width: 24 * scale)

                        newChatColumn(scale: scale)
                            .frame(width: 92 * scale)
                            .opacity(0.30)
                            .id(LobbyCarouselID.newChat)

                        centerChatColumn(scale: scale)
                            .frame(width: 130 * scale)
                            .id(LobbyCarouselID.center)

                        buzTeamColumn(scale: scale)
                            .frame(width: 92 * scale)
                            .opacity(0.30)
                            .id(LobbyCarouselID.buzTeam)

                        peekColumn(scale: scale)
                            .frame(width: 92 * scale)
                            .opacity(0.30)
                            .id(LobbyCarouselID.peek)

                        Color.clear.frame(width: 32 * scale)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation(carouselSpring) {
                            proxy.scrollTo(LobbyCarouselID.center, anchor: .center)
                        }
                    }
                }
            }

            Color.clear
                .frame(height: DesignTokens.LobbyLayout.carouselToSuggestionGap * scale)

            aiSuggestionStrip(scale: scale, maxWidth: suggestionStripMaxWidth)

            Spacer(minLength: 0)
        }
    }

    private func newChatColumn(scale: CGFloat) -> some View {
        VStack(spacing: 8 * scale) {
            ZStack {
                Circle()
                    .fill(
                        PlaygroundApproxColors.newChatCircleRadial(outer: DesignTokens.background4, endRadius: 40 * scale)
                    )
                    .frame(width: 64 * scale, height: 64 * scale)
                Text(BuzGlyph.newChat)
                    .font(BuzGlyph.buz(size: 30 * scale))
                    .foregroundStyle(DesignTokens.textWhiteImportant)
            }
            Text("New Chat")
                .font(AppFont.nunito(.extrabold, size: 16 * scale))
                .foregroundStyle(DesignTokens.textWhiteImportant)
        }
        .padding(.top, 18 * scale)
    }

    private func centerChatColumn(scale: CGFloat) -> some View {
        VStack(spacing: 6 * scale) {
            ZStack {
                // Figma: SelectFrame — gradient ring concentric with avatar (same center)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.04)],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 100 * scale, height: 100 * scale)
                figmaMaskedCircleImage(imageURL: FigmaAssets.centerAvatar, size: 100 * scale)
            }
            .padding(.top, 16 * scale)

            HStack(spacing: 4 * scale) {
                Text(BuzGlyph.verified)
                    .font(BuzGlyph.buz(size: 18 * scale))
                    .foregroundStyle(PlaygroundApproxColors.textBasicPrimary)
                Text("ALoHa | buz")
                    .font(AppFont.nunito(.extrabold, size: 18 * scale))
                    .foregroundStyle(DesignTokens.textWhiteImportant)
                    .lineLimit(1)
            }
        }
    }

    private func buzTeamColumn(scale: CGFloat) -> some View {
        VStack(spacing: 8 * scale) {
            ZStack {
                Circle()
                    .fill(DesignTokens.background5)
                    .frame(width: 64 * scale, height: 64 * scale)
                figmaMaskedCircleImage(imageURL: FigmaAssets.sideAvatar, size: 64 * scale)
            }
            Text("Buz Team")
                .font(AppFont.nunito(.extrabold, size: 16 * scale))
                .foregroundStyle(DesignTokens.textWhiteImportant)
                .lineLimit(1)
        }
        .padding(.top, 18 * scale)
    }

    /// 建议条：`Color.Background.4` 底；文案在药丸内水平居中，左右留对称宽度给关闭图标
    private func aiSuggestionStrip(scale: CGFloat, maxWidth: CGFloat) -> some View {
        let sideSlot: CGFloat = 26 * scale
        return HStack(spacing: 0) {
            Color.clear.frame(width: sideSlot)
            Text("I could suggest a lunch recipe")
                .font(AppFont.nunito(.regular, size: 14 * scale))
                .foregroundStyle(PlaygroundApproxColors.suggestionTitleGradient)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Text(BuzGlyph.suggestionClose)
                .font(BuzGlyph.buz(size: 14 * scale))
                .foregroundStyle(DesignTokens.textWhiteTertiary)
                .frame(width: sideSlot, alignment: .trailing)
        }
        .padding(.horizontal, 14 * scale)
        .frame(height: 30 * scale)
        .background(PlaygroundApproxColors.lobbySuggestionStripFill, in: RoundedRectangle(cornerRadius: 12 * scale, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12 * scale, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1 * scale)
        )
        .frame(width: maxWidth)
    }

    /// Content Preview：`Color.Background.3.Default` · `Stroke OFF` 底 `#000`（单层 1pt）
    /// 描边用 `strokeBorder` 避免 1pt 画在边界外被 Chat Frame `clipShape` 裁掉；圆角用 `.circular` 贴近 Figma CSS。
    private func messagePreview(scale: CGFloat, cardWidth: CGFloat) -> some View {
        let corner = DesignTokens.messageCardCorner * scale
        let cardW = cardWidth
        let cardH = DesignTokens.LobbyLayout.contentPreviewHeight * scale
        return VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12 * scale) {
                Text("Hey, How’s going today? Do you wanna come over tonight?")
                    .font(AppFont.nunito(.regular, size: 18 * scale))
                    .foregroundStyle(DesignTokens.textWhiteImportant)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .tracking(0.18 * scale)
                    .frame(maxWidth: .infinity, alignment: .leading)

                voiceMessagePill(scale: scale)
            }
            .frame(height: 92 * scale)
            .padding(.horizontal, 20 * scale)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(PlaygroundApproxColors.contentPreviewHairlineGradient)
                    .frame(height: 1 * scale)
            }

            HStack {
                HStack(spacing: 6 * scale) {
                    Text("Just now")
                        .font(AppFont.nunito(.regular, size: 14 * scale))
                        .foregroundStyle(DesignTokens.textWhiteTertiary)
                        .tracking(0.14 * scale)
                    AsyncImage(url: FigmaAssets.loadingMessage) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFit()
                        } else {
                            ProgressView().scaleEffect(0.6)
                        }
                    }
                    .frame(width: 16 * scale, height: 16 * scale)
                }
                Spacer()
                HStack(spacing: 4 * scale) {
                    Text("Chat")
                        .font(AppFont.nunito(.semibold, size: 14 * scale))
                        .foregroundStyle(DesignTokens.textWhiteTertiary)
                        .tracking(0.14 * scale)
                    Text(BuzGlyph.chatChevron)
                        .font(BuzGlyph.buz(size: 14 * scale))
                        .foregroundStyle(DesignTokens.textWhiteTertiary)
                }
            }
            .frame(height: 46 * scale)
            .padding(.horizontal, 20 * scale)
        }
        .padding(.top, 12 * scale)
        .frame(width: cardW, height: cardH)
        .background(DesignTokens.background3, in: RoundedRectangle(cornerRadius: corner, style: .circular))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .circular)
                .strokeBorder(DesignTokens.keysNeutralBlack, lineWidth: 1 * scale)
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .circular))
    }

    /// Content Preview 内小圆语音条（波形 + 时长；大按钮见 `pushToTalk`）
    private func voiceMessagePill(scale: CGFloat) -> some View {
        let d: CGFloat = 50 * scale
        return VStack(spacing: 2 * scale) {
            voiceBars(scale: scale)
                .frame(height: 14 * scale)
            Text("0:05")
                .font(AppFont.nunito(.semibold, size: 12 * scale))
                .foregroundStyle(DesignTokens.textWhiteImportant)
                .tracking(0.24 * scale)
        }
        .frame(width: d, height: d)
        .background(DesignTokens.background6, in: Circle())
    }

    private func voiceBars(scale: CGFloat) -> some View {
        HStack(spacing: 2 * scale) {
            Capsule().fill(DesignTokens.textWhiteImportant).frame(width: 2 * scale, height: 8 * scale)
            Capsule().fill(DesignTokens.textWhiteImportant).frame(width: 2 * scale, height: 12 * scale)
            Capsule().fill(DesignTokens.textWhiteImportant).frame(width: 2 * scale, height: 8 * scale)
        }
    }

    // MARK: Bottom

    /// Figma Fill：底 `#141414` → 径向白高光 → AI 线性 30%；描边单层 **AI 渐变**（双描边叠色会发灰）
    private func pushToTalk(scale: CGFloat) -> some View {
        let d = DesignTokens.pushToTalkDiameter * scale
        let borderW = DesignTokens.pushToTalkStrokeWidth * scale
        let micSize = 40 * scale * (DesignTokens.pushToTalkDiameter / 180)

        return ZStack {
            Circle()
                .fill(PlaygroundApproxColors.pushToTalkFillBase)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.32),
                            Color.white.opacity(0.16),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: d * 0.55
                    )
                )
            Circle()
                .fill(PlaygroundApproxColors.pushToTalkAIGradient)
                .opacity(DesignTokens.pushToTalkAILinearLayerOpacity)
            Circle()
                .strokeBorder(PlaygroundApproxColors.pushToTalkAIGradient, lineWidth: borderW)

            Text(BuzGlyph.micPushToTalk)
                .font(BuzGlyph.buz(size: micSize))
                .foregroundStyle(DesignTokens.textWhiteImportant)
        }
        .frame(width: d, height: d)
        .aspectRatio(1, contentMode: .fit)
    }

    private func bottomToolbox(scale: CGFloat) -> some View {
        HStack(spacing: -8 * scale) {
            bottomItem(glyph: BuzGlyph.bottomVoiceEmoji, scale: scale, badge: false)
            bottomItem(glyph: BuzGlyph.bottomFilter, scale: scale, badge: true)
            bottomItem(glyph: BuzGlyph.plus, scale: scale, badge: false)
        }
        .padding(.leading, 4 * scale)
        .padding(.trailing, 12 * scale)
        .padding(.vertical, 4 * scale)
        .background(DesignTokens.background4, in: Capsule())
    }

    /// `2:1824`：红点相对格子中心 `+12` 水平、`-12` 垂直（Figma `calc(50%+12)` / `calc(50%-12)`）
    private func bottomItem(glyph: String, scale: CGFloat, badge: Bool) -> some View {
        ZStack {
            Text(glyph)
                .font(BuzGlyph.buz(size: 24 * scale))
                .foregroundStyle(DesignTokens.textWhitePrimary)
                .frame(width: 56 * scale, height: 44 * scale)
            if badge {
                Circle()
                    .fill(DesignTokens.foregroundConsequential)
                    .frame(width: 8 * scale, height: 8 * scale)
                    .offset(x: 12 * scale, y: -12 * scale)
            }
        }
        .frame(width: 56 * scale, height: 44 * scale)
    }

    /// Carousel 右侧第 4 个头像（仅圆形 peek，无文字；chatFrame clipShape 负责裁切）
    private func peekColumn(scale: CGFloat) -> some View {
        figmaMaskedCircleImage(imageURL: FigmaAssets.navAvatar, size: 64 * scale)
            .padding(.top, 18 * scale)
    }

    // MARK: Remote image helper

    private func figmaMaskedCircleImage(imageURL: URL, size: CGFloat) -> some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            case .failure:
                Circle()
                    .fill(DesignTokens.background5)
                    .frame(width: size, height: size)
            default:
                Circle()
                    .fill(DesignTokens.background5)
                    .frame(width: size, height: size)
                    .overlay { ProgressView().scaleEffect(0.5) }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    LobbyView()
}
