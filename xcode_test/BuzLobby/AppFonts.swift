import SwiftUI

/// Nunito static fonts — PostScript names from bundled `.ttf` files (see `Fonts/` + `Info.plist` `UIAppFonts`).
enum AppFont {
    enum NunitoWeight: String {
        case regular = "Nunito-Regular"
        case medium = "Nunito-Medium"
        case semibold = "Nunito-SemiBold"
        case extrabold = "Nunito-ExtraBold"
    }

    static func nunito(_ weight: NunitoWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}

/// Icon font `buz` — private-use codepoints aligned with Figma / design export.
enum BuzGlyph {
    private static func scalar(_ value: UInt32) -> String {
        guard let s = UnicodeScalar(value) else { return "" }
        return String(Character(s))
    }

    static let search = scalar(0xE9B9)
    static let contacts = scalar(0xE9A0)
    static let autoplaySpeaker = scalar(0xE929)
    static let autoplayChevron = scalar(0xE9B5)
    static let newChat = scalar(0xE9A9)
    static let verified = scalar(0xE945)
    static let micPushToTalk = scalar(0xE927)
    static let bottomVoiceEmoji = scalar(0xE952)
    static let bottomFilter = scalar(0xE92B)
    static let plus = scalar(0xE900)
    static let chatChevron = scalar(0xE909)
    /// Chat History Nav — 返回 / 收起（Figma `9:4013` · `\uE908`）
    static let chatBack = scalar(0xE908)
    static let suggestionClose = scalar(0xE905)

    static func buz(size: CGFloat) -> Font {
        .custom("buz", size: size)
    }
}
