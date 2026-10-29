import SwiftUI

enum TaoziFont {
    static func text(_ content: String, size: CGFloat, weight: Font.Weight) -> Text {
        Text(styled(content, size: size, weight: weight, style: nil))
    }

    static func text(_ content: String, style: Font.TextStyle, weight: Font.Weight) -> Text {
        Text(styled(content, size: baseSize(style), weight: weight, style: style))
    }

    private static func styled(
        _ content: String,
        size: CGFloat,
        weight: Font.Weight,
        style: Font.TextStyle?
    ) -> AttributedString {
        var result = AttributedString()
        var buffer = ""
        var latin = false

        func flush() {
            guard !buffer.isEmpty else { return }
            var piece = AttributedString(buffer)
            if latin {
                piece.font = style.map { .custom("DINCondensed-Bold", size: size, relativeTo: $0) }
                    ?? .custom("DINCondensed-Bold", size: size)
                piece.tracking = size * 0.06
            } else if let style {
                piece.font = .system(style).weight(weight)
            } else {
                piece.font = .system(size: size, weight: weight)
            }
            result.append(piece)
            buffer.removeAll(keepingCapacity: true)
        }

        for character in content {
            let nextLatin = isDIN(character)
            if !buffer.isEmpty, nextLatin != latin {
                flush()
            }
            latin = nextLatin
            buffer.append(character)
        }
        flush()
        return result
    }

    private static func isDIN(_ character: Character) -> Bool {
        if character == "–" {
            return true
        }
        guard character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first, scalar.isASCII else {
            return false
        }
        if CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar) {
            return true
        }
        return "+-.:/%,".contains(character)
    }

    private static func baseSize(_ style: Font.TextStyle) -> CGFloat {
        if style == .largeTitle { return 34 }
        if style == .title { return 28 }
        if style == .title2 { return 22 }
        if style == .title3 { return 20 }
        if style == .callout { return 16 }
        if style == .subheadline { return 15 }
        if style == .footnote { return 13 }
        if style == .caption { return 12 }
        if style == .caption2 { return 11 }
        return 17
    }
}
