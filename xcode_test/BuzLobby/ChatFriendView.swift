import SwiftUI

// MARK: - 主 Frame `1:6701`（Chat-new/Friend）· Chat Page `1:6705`（MCP asset URLs ~7 天有效）

private enum ChatPageAssets {
    /// Chat History Nav · Profile（`imgAvatar`）
    static let headerAvatar = URL(string: "https://www.figma.com/api/mcp/asset/2016da3c-0170-4d48-906d-7c59dfbbc16b")!
    /// Official card 插图（`imgChatGptImage2026251050445`）
    static let officialCover = URL(string: "https://www.figma.com/api/mcp/asset/3170740b-cc5b-48e7-8191-9f92582f781d")!
    /// 入站语音条右侧未读点（`imgPotArea`）
    static let potArea = URL(string: "https://www.figma.com/api/mcp/asset/662261b1-f591-4793-88b6-3deb458f75ed")!
}

/// Chat Page `1:6705`：自屏顶 `116` 至底；由 `LobbyView` 给剩余高度（全屏自适应）。
struct ChatFriendView: View {
    let scale: CGFloat
    /// 本页可用高度（`LobbyView` 在 **保留底安全区** 的 `GeometryReader` 内计算：≈ 可视区高 − 顶栏）
    let sheetHeight: CGFloat
    var onDismiss: () -> Void

    private let bubbleR: CGFloat = 17

    /// 相对 **Chat History Nav 底** 的快捷短语顶偏移（稿 502pt @696 高）
    private var quickChipsTopPadding: CGFloat {
        let designH = DesignTokens.ChatLayout.chatSheetDesignHeight
        let navH = DesignTokens.ChatLayout.chatHistoryNavHeight * scale
        let ratioFromPageTop = DesignTokens.ChatLayout.quickChipsTopFromChatPageTop / designH
        return max(0, sheetHeight * ratioFromPageTop - navH)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            chatDecorativeBackground

            VStack(spacing: 0) {
                chatHistoryNavBar

                // `1:6705`：`Message Set` 为 `absolute top-[574px]`，叠在 chat list 上（非排在 Scroll 下方）
                ZStack(alignment: .topLeading) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16 * scale) {
                            officialIntroCard
                            centeredInfoText("Just now")
                            outgoingTranscriptionBubble
                            incomingTranscriptionBubble
                            centeredInfoText("Chat About Something New")
                        }
                        .padding(.horizontal, 20 * scale)
                        .padding(.top, DesignTokens.ChatLayout.listTopInset * scale)
                        // 列表底要留出「悬浮快捷短语」占位，避免最后一行文案与 chip 叠在同一带
                        .padding(.bottom, DesignTokens.ChatLayout.listBottomInset * scale + 56 * scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignTokens.background3)

                    quickReplyChips
                        .padding(.top, quickChipsTopPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomChatBox
                Color.clear
                    .frame(height: 24 * scale)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .clipShape(chatPageClipShape)
        // `.background` 必须在 `.clipShape` 之后：SwiftUI 后置的 background 填的是 clip 前的完整矩形（不受 clip 路径影响）
        // → TL/TR 圆角缺口由 background3 填满，父级 ZStack 的黑色 lobby 底就不会透出来
        .background(DesignTokens.background3)
        // Dev：`border: 1px solid rgba(143,125,255,0)` — 无视觉，不叠 stroke
    }

    /// `1:6705`：`border-radius: 30px 30px 0 0`（TL/TR=30，BL/BR=0）
    private var chatPageClipShape: UnevenRoundedRectangle {
        let r = DesignTokens.LobbyLayout.chatSheetTopCorner * scale
        return UnevenRoundedRectangle(
            topLeadingRadius: r,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: r,
            style: .continuous
        )
    }

    // MARK: - Decorative (Figma `9:4072` AI Background — 简化)

    private var chatDecorativeBackground: some View {
        ZStack {
            Circle()
                .fill(PlaygroundApproxColors.chatDecorativeAIBlurGradient)
                .frame(width: 400 * scale, height: 400 * scale)
                .blur(radius: 80 * scale)
                .offset(y: 120 * scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        // 模糊会溢出边界，在父级 clip 前单独裁一层，减轻顶角发灰/露缝
        .clipShape(chatPageClipShape)
    }

    // MARK: - Chat History Nav Bar (`9:4013`)

    private var chatHistoryNavBar: some View {
        HStack(spacing: 16 * scale) {
            Button(action: onDismiss) {
                Text(BuzGlyph.chatBack)
                    .font(BuzGlyph.buz(size: 24 * scale))
                    .foregroundStyle(DesignTokens.textWhiteImportant)
            }
            .buttonStyle(.plain)

            HStack(spacing: 10 * scale) {
                AsyncImage(url: ChatPageAssets.headerAvatar) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(DesignTokens.background5)
                    }
                }
                .frame(width: 30 * scale, height: 30 * scale)
                .clipShape(RoundedRectangle(cornerRadius: 17 * scale, style: .continuous))

                HStack(spacing: 2 * scale) {
                    Text(BuzGlyph.verified)
                        .font(BuzGlyph.buz(size: 18 * scale))
                        .foregroundStyle(DesignTokens.textHighlight)
                    Text("ALoHa | buz")
                        .font(AppFont.nunito(.extrabold, size: 18 * scale))
                        .foregroundStyle(DesignTokens.textWhiteImportant)
                        .tracking(0.18 * scale)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20 * scale)
        .frame(height: 72 * scale)
        .background(DesignTokens.background3)
    }

    // MARK: - Official card (`9:4017`)

    private var officialIntroCard: some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            AsyncImage(url: ChatPageAssets.officialCover) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle().fill(Color.white.opacity(0.08))
                }
            }
            .frame(width: 237 * scale, height: 130 * scale)
            .clipShape(RoundedRectangle(cornerRadius: 8 * scale, style: .continuous))

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text("ALoHa dropped")
                    .font(AppFont.nunito(.extrabold, size: 16 * scale))
                    .foregroundStyle(DesignTokens.textWhiteImportant)
                    .tracking(0.16 * scale)
                Text("Hi, I’m ALoHa, here with buz. I share buz updates and tips — and yes, you can chat with me anytime!")
                    .font(AppFont.nunito(.regular, size: 14 * scale))
                    .foregroundStyle(DesignTokens.textWhiteSecondary)
                    .tracking(0.14 * scale)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12 * scale)
        .frame(maxWidth: 261 * scale, alignment: .leading)
        .background(DesignTokens.background5, in: bubbleShape(
            topLeading: bubbleR * scale,
            topTrailing: bubbleR * scale,
            bottomLeading: 4 * scale,
            bottomTrailing: bubbleR * scale
        ))
    }

    // MARK: - Outgoing transcription (`9:4035`)

    private var outgoingTranscriptionBubble: some View {
        HStack {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                HStack(spacing: 4 * scale) {
                    Spacer(minLength: 0)
                    Text("0:01")
                        .font(AppFont.nunito(.regular, size: 14 * scale))
                        .foregroundStyle(DesignTokens.textBlackPrimary)
                        .tracking(0.14 * scale)
                    voiceWaveform(color: DesignTokens.textBlackPrimary, scale: scale)
                }
                .padding(.horizontal, 12 * scale)
                .frame(height: 34 * scale)
                .frame(maxWidth: .infinity)

                VStack(spacing: 0) {
                    Text("Could you recommend me some restaurant?")
                        .font(AppFont.nunito(.regular, size: 16 * scale))
                        .foregroundStyle(DesignTokens.textBlackOnColorPrimary)
                        .tracking(0.32 * scale)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10 * scale)
                        .padding(.vertical, 6 * scale)
                        .frame(maxWidth: .infinity)
                        .background(
                            DesignTokens.keysBrand90,
                            in: UnevenRoundedRectangle(
                                topLeadingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                bottomLeadingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                bottomTrailingRadius: DesignTokens.ChatLayout.transcriptionInnerCornerTail * scale,
                                topTrailingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                style: .continuous
                            )
                        )
                }
                .padding(4 * scale)
            }
            .frame(maxWidth: 261 * scale)
            .background(DesignTokens.foregroundHighlight, in: bubbleShape(
                topLeading: bubbleR * scale,
                topTrailing: bubbleR * scale,
                bottomLeading: bubbleR * scale,
                bottomTrailing: 4 * scale
            ))
        }
    }

    // MARK: - Incoming transcription (`9:4047`)

    private var incomingTranscriptionBubble: some View {
        HStack {
            VStack(spacing: 0) {
                HStack(spacing: 4 * scale) {
                    voiceWaveform(color: DesignTokens.textWhiteImportant, scale: scale)
                    Text("0:04")
                        .font(AppFont.nunito(.regular, size: 14 * scale))
                        .foregroundStyle(DesignTokens.textWhiteImportant)
                        .tracking(0.14 * scale)
                    Spacer(minLength: 0)
                    AsyncImage(url: ChatPageAssets.potArea) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFit()
                        } else {
                            Color.clear.frame(width: 16 * scale, height: 5 * scale)
                        }
                    }
                    .frame(width: 16 * scale, height: 5 * scale)
                }
                .padding(.leading, 12 * scale)
                .padding(.trailing, 7 * scale)
                .frame(height: 34 * scale)

                VStack(spacing: 0) {
                    Text("Is this a classic show? What's it about?")
                        .font(AppFont.nunito(.regular, size: 16 * scale))
                        .foregroundStyle(DesignTokens.textWhitePrimary)
                        .tracking(0.32 * scale)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 10 * scale)
                        .padding(.vertical, 6 * scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            DesignTokens.background4,
                            in: UnevenRoundedRectangle(
                                topLeadingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                bottomLeadingRadius: DesignTokens.ChatLayout.transcriptionInnerCornerTail * scale,
                                bottomTrailingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                topTrailingRadius: DesignTokens.ChatLayout.transcriptionInnerCorner * scale,
                                style: .continuous
                            )
                        )
                }
                .padding(4 * scale)
            }
            .frame(maxWidth: 261 * scale)
            .background(DesignTokens.background5, in: bubbleShape(
                topLeading: 4 * scale,
                topTrailing: bubbleR * scale,
                bottomLeading: 4 * scale,
                bottomTrailing: bubbleR * scale
            ))
            Spacer(minLength: 0)
        }
    }

    private func centeredInfoText(_ text: String) -> some View {
        Text(text)
            .font(AppFont.nunito(.regular, size: 14 * scale))
            .foregroundStyle(DesignTokens.textWhiteTertiary)
            .tracking(0.14 * scale)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    // MARK: - Quick chips (`9:4064`–`9:4071`)

    private var quickReplyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6 * scale) {
                quickChip(title: "💡 Speak Your Mind", width: 151)
                quickChip(title: "💬 Say It Better", width: 124)
                quickChip(title: "🎮 Quick game", width: 119)
                // 尾部留白，避免 ScrollView 默认 clip 把最后一枚 chip 切在屏缘
                Color.clear.frame(width: 32 * scale, height: 1)
            }
            .padding(.leading, 20 * scale)
            .padding(.trailing, 12 * scale)
        }
        .scrollClipDisabled()
        .background(DesignTokens.background3)
    }

    private func quickChip(title: String, width: CGFloat) -> some View {
        Text(title)
            .font(AppFont.nunito(.semibold, size: 14 * scale))
            .foregroundStyle(DesignTokens.textWhiteImportant)
            .tracking(0.14 * scale)
            .lineLimit(1)
            .padding(.horizontal, 12 * scale)
            .padding(.vertical, 6 * scale)
            .frame(minWidth: width * scale, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: bubbleR * scale, style: .continuous)
                    .stroke(DesignTokens.outline2, lineWidth: 1 * scale)
            )
    }

    // MARK: - Bottom chat box (`1:3556` / `9:4077`)

    private var bottomChatBox: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(DesignTokens.outline2)
                .frame(height: 0.5 * scale)

            HStack(spacing: 10 * scale) {
                bottomIconCircle(glyph: BuzGlyph.bottomVoiceEmoji, scale: scale)

                Text("Enter message")
                    .font(AppFont.nunito(.regular, size: 16 * scale))
                    .foregroundStyle(DesignTokens.textWhiteDisable)
                    .tracking(0.32 * scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 11.5 * scale)
                    .frame(height: 36 * scale)
                    .background(DesignTokens.background3, in: RoundedRectangle(cornerRadius: 20 * scale, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                            .stroke(DesignTokens.outline2, lineWidth: 0.5 * scale)
                    )

                bottomIconCircle(glyph: BuzGlyph.plus, scale: scale)
                bottomIconCircle(glyph: BuzGlyph.micPushToTalk, scale: scale)
            }
            .padding(.horizontal, 12 * scale)
            .padding(.vertical, 6 * scale)
        }
        .background(DesignTokens.background4)
    }

    private func bottomIconCircle(glyph: String, scale: CGFloat) -> some View {
        Text(glyph)
            .font(BuzGlyph.buz(size: 22 * scale))
            .foregroundStyle(DesignTokens.textWhitePrimary)
            .frame(width: 36 * scale, height: 36 * scale)
            .background(DesignTokens.background5, in: RoundedRectangle(cornerRadius: 20 * scale, style: .continuous))
    }

    // MARK: - Shapes & waveform

    private func bubbleShape(topLeading: CGFloat, topTrailing: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: topLeading,
            bottomLeadingRadius: bottomLeading,
            bottomTrailingRadius: bottomTrailing,
            topTrailingRadius: topTrailing,
            style: .continuous
        )
    }

    private func voiceWaveform(color: Color, scale: CGFloat) -> some View {
        HStack(spacing: 2 * scale) {
            Capsule().fill(color).frame(width: 2 * scale, height: 8 * scale)
            Capsule().fill(color).frame(width: 2 * scale, height: 12 * scale)
            Capsule().fill(color).frame(width: 2 * scale, height: 8 * scale)
        }
        .frame(width: 14 * scale, height: 14 * scale)
    }
}

#Preview("Chat Page Figma 9:4008") {
    ChatFriendView(scale: 1, sheetHeight: DesignTokens.ChatLayout.chatSheetDesignHeight, onDismiss: {})
        .background(DesignTokens.background2)
}
