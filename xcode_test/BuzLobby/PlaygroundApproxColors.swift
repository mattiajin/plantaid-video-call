import SwiftUI

/// Playground / Figma 单帧里出现、但 **Variables 未收录** 的近似色与渐变。
/// 非设计系统 Token；日后若 JSON 有正式变量，应迁回 `TokenColors` / `DesignTokens` 并删除此处。
enum PlaygroundApproxColors {
    /// Figma Dev「Basic/Primary」认证勾 `#B8FA64`（与 `TokenColors.basicPrimary` 略有偏差）
    static let textBasicPrimary = Color(hex: 0xB8FA64)

    /// Nav Autoplay 叠层：`linear-gradient(90deg, rgba(61,56,95,0.10) → #3D385F)`
    private static let autoplayOverlayGradientEnd = Color(hex: 0x3D385F)
    static let autoplayOverlayGradient = LinearGradient(
        colors: [
            Color(red: 61 / 255, green: 56 / 255, blue: 95 / 255).opacity(0.1),
            autoplayOverlayGradientEnd
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// 建议条药丸底（稿 `#1A2540`）
    static let lobbySuggestionStripFill = Color(hex: 0x1A2540)

    /// 建议条文案 AI 三色渐变（对齐 PTT AI 渐变色相）
    static let suggestionTitleGradient = LinearGradient(
        colors: [
            Color(red: 99 / 255, green: 140 / 255, blue: 232 / 255),
            Color(red: 120 / 255, green: 112 / 255, blue: 222 / 255),
            Color(red: 209 / 255, green: 156 / 255, blue: 90 / 255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// New Chat 圆钮径向：内 `#3D3D3D` → 外接 `background4`（`endRadius` 与头像直径比例一致，需乘 `scale`）
    static func newChatCircleRadial(outer: Color, endRadius: CGFloat) -> RadialGradient {
        RadialGradient(
            colors: [Color(hex: 0x3D3D3D), outer],
            center: .center,
            startRadius: 0,
            endRadius: endRadius
        )
    }

    /// PTT 底层实色（稿 `#141414`）
    static let pushToTalkFillBase = Color(hex: 0x141414)

    /// `linear-gradient(135deg, #63C0E8 → #7870DE → #D19C5A)` — Fill 顶层与 Stroke
    static let pushToTalkAIGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x63C0E8), location: 0),
            .init(color: Color(hex: 0x7870DE), location: 0.5),
            .init(color: Color(hex: 0xD19C5A), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Chat 页装饰模糊（与 PTT 同色渐变、低 opacity）
    static let chatDecorativeAIBlurGradient = LinearGradient(
        colors: [
            Color(hex: 0x63C0E8).opacity(0.12),
            Color(hex: 0x7870DE).opacity(0.1),
            Color(hex: 0xD19C5A).opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Content Preview 区底部分隔线（透明–白–透明）
    static let contentPreviewHairlineGradient = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: Color.white.opacity(0.12), location: 0.5),
            .init(color: .clear, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
