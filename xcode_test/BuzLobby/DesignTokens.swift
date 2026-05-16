import SwiftUI

/// 工程内使用的语义 Token；色值来自 `TokenColors`（Figma Variables → `Tokens/Mode 1.tokens.json`）。
/// 重新导出 JSON 后（在 `BuzLobby` 目录）：`python3 ../../scripts/figma_tokens_to_swift.py > TokenColors.generated.swift`
enum DesignTokens {
    /// Lobby 外屏 / 导航条底：`Color.Background.2.Default` = `#1A1A1A`
    static let lobbyScreenBackground = TokenColors.background2
    static let background2 = TokenColors.background2
    static let background3 = TokenColors.background3
    static let background4 = TokenColors.background4
    static let background5 = TokenColors.background5
    static let background6 = TokenColors.background6

    static let foregroundHighlight = TokenColors.foregroundHighlight
    static let textHighlight = TokenColors.textHighlight
    /// `Color.Keys.Brand.90`
    static let basicPrimary = TokenColors.basicPrimary

    static let foregroundDND = TokenColors.foregroundDND
    static let keysPurple60 = TokenColors.keysPurple60
    static let keysBrand50 = TokenColors.keysBrand50
    static let keysBrand20 = TokenColors.keysBrand20
    static let keysBrand90 = TokenColors.keysBrand90

    static let textWhiteImportant = TokenColors.textWhiteImportant
    static let textWhitePrimary = TokenColors.textWhitePrimary
    static let textWhiteSecondary = TokenColors.textWhiteSecondary
    static let textWhiteTertiary = TokenColors.textWhiteTertiary
    static let textWhiteDisable = TokenColors.textWhiteDisable
    static let textBlackPrimary = TokenColors.textBlackPrimary
    static let textBlackOnColorPrimary = TokenColors.textBlackOnColorPrimary

    static let outline2 = TokenColors.outline2
    static let foregroundConsequential = TokenColors.foregroundConsequential

    static let keysNeutralBlack = TokenColors.keysNeutralBlack
    static let keysNeutral5 = TokenColors.keysNeutral5

    /// `Foreground/DND`（`#8F7DFF`）— Chat Frame 外框 1pt
    static let chatFrameStroke = TokenColors.chatFrameStroke

    /// Chat Frame 外框底：`Color.Keys.Neutral.Black`（`#000000`）—— Figma Dev: `var(--color/keys/neutral/black,black)`
    static let chatFrameFill = TokenColors.keysNeutralBlack
    /// Content Preview 圆角 26pt（Figma `rounded-[26px]`）
    static let messageCardCorner: CGFloat = 26

    static let pushToTalkFillBase = TokenColors.pushToTalkFillBase
    /// Figma Push to Talk（`16:10493`）：设计稿 164×164
    static let pushToTalkDiameter: CGFloat = 164
    /// Figma Fill：AI 线性渐变**图层**整体不透明度 30%（叠在径向高光与底层实色之上）
    static let pushToTalkAILinearLayerOpacity: Double = 0.3
    /// Figma Stroke：Inside · 3.27px（逻辑点按 `scale` 乘）
    static let pushToTalkStrokeWidth: CGFloat = 3.27

    /// Figma `16:10489` Nav · Autoplay 药丸（Dev CSS）
    enum AutoplayNav {
        static let height: CGFloat = 32
        static let minWidth: CGFloat = 106
        static let padding: CGFloat = 3
        static let gap: CGFloat = 3
        /// `border-radius: 68px`（高 32 时用 `Capsule()` 等效）
        static let cornerRadius: CGFloat = 68
    }

    // MARK: Layout（`lXmtAml17vk50Fv7QRts23` · Lobby `19227:9845`）

    enum LobbyLayout {
        static let statusBarTop: CGFloat = 44
        static let navBarHeight: CGFloat = 72
        static let chatFrameWidth: CGFloat = 363
        static let chatFrameHeight: CGFloat = 368
        static let chatFrameCorner: CGFloat = 30
        static let chatListTopInset: CGFloat = 13
        static let chatListBlockHeight: CGFloat = 186
        /// 头像轮播区与建议条之间（勿用 Spacer 撑满，否则中间会出现大块空白）
        static let carouselToSuggestionGap: CGFloat = 8
        /// 建议条与下方 Content Preview 间距
        /// 值设为 16pt 使三侧间距一致：top(13)+chatList(186)+gap(16)+preview(150)+bottom(3)=368 ✓
        static let chatListToPreviewGap: CGFloat = 16
        static let contentPreviewHeight: CGFloat = 150
        /// Content Preview 可用宽度：`chatFrameWidth` − 左右各 `3`（与 Figma `left/right-[3px]` 一致）
        static let contentPreviewWidth: CGFloat = chatFrameWidth - 6
        /// Content Preview 下方与 Chat Frame 底：3pt（与左右 3pt 一致）
        static let chatFrameBottomInset: CGFloat = 3
        static let bottomToolboxMargin: CGFloat = 24

        /// Figma 画板逻辑高度（与 `LobbyView.designHeight` 一致）
        static let designScreenHeight: CGFloat = 812

        // MARK: Chat-new / Friend 浮层（Figma `1:6701` / `1:6705`）

        /// `Chat Page` 顶距屏顶 = status(44) + Tool Bar(72) = **116**
        static let chatSheetTopInset: CGFloat = statusBarTop + navBarHeight
        /// Chat 页顶圆角（`rounded-tl/tr-[30px]`）
        static let chatSheetTopCorner: CGFloat = 30
        /// 遮罩 `rgba(0,0,0,0.7)`（`1:6703` Mask）
        static let chatOverlayMaskOpacity: Double = 0.7
    }

    /// Chat 页内间距与转写条内层圆角（`1:6701` · chat list / transcription inner）
    enum ChatLayout {
        /// Chat Page 设计高度（812 屏 − 顶距 116）
        static let chatSheetDesignHeight: CGFloat = LobbyLayout.designScreenHeight - LobbyLayout.chatSheetTopInset

        /// chat list：`pt-[20px] pb-[66px]`
        static let listTopInset: CGFloat = 20
        static let listBottomInset: CGFloat = 66
        /// Chat History Nav：`h-[72px]`（用于计算快捷短语叠层位置）
        static let chatHistoryNavHeight: CGFloat = 72
        /// `Message Set`：`absolute top-[574px]`（相对 Chat Page 顶 `1:6705`）
        static let quickChipsTopFromChatPageTop: CGFloat = 574
        /// 快捷短语行相对 **Nav 底** 的偏移 = 574 − 72
        static let quickChipsTopBelowNav: CGFloat = quickChipsTopFromChatPageTop - chatHistoryNavHeight
        /// 转写条内层文案区：`rounded-*-[13px]` 与一角 `2px`（`rounded-bl/br-[2px]` 依左右对齐）
        static let transcriptionInnerCorner: CGFloat = 13
        static let transcriptionInnerCornerTail: CGFloat = 2
    }
}
