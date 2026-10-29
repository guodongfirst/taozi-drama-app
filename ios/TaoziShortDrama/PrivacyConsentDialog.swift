import SwiftUI

enum PrivacyConsent {
    static let version = "1"

    static func accept() {
        let defaults = UserDefaults.standard
        defaults.set(version, forKey: "privacyConsentVersion")
        defaults.set(Date().timeIntervalSince1970, forKey: "privacyConsentTime")
    }
}

struct PrivacyConsentDialog: View {
    var onAgree: () -> Void
    var onDisagree: () -> Void
    var onOpen: (LegalDocument) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TaoziFont.text("个人信息保护指引", size: 21, weight: .bold)
                .foregroundStyle(Color.consentInk)
                .padding(.top, 25)

            TaoziFont.text("我们非常重视你的个人信息安全，请充分阅读并理解后，点击下方按钮接受我们的服务：", size: 14, weight: .bold)
                .foregroundStyle(Color.consentInk)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 21)
                .padding(.horizontal, 24)

            notice
                .padding(.top, 8)
                .padding(.horizontal, 24)

            Button(action: onAgree) {
                TaoziFont.text("我已阅读并同意", style: .callout, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .padding(.horizontal, 24)

            Button(action: onDisagree) {
                VStack(spacing: 4) {
                    TaoziFont.text("不同意", size: 14, weight: .bold)
                        .foregroundStyle(Color.consentStone)
                    Rectangle()
                        .fill(Color.consentStone.opacity(0.45))
                        .frame(width: 59, height: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: 327)
        .background {
            LinearGradient(
                stops: [
                    .init(color: Color.consentCardTop, location: 0),
                    .init(color: Color.consentCardMid, location: 0.52),
                    .init(color: Color.consentCardBottom, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 82 / 255, green: 20 / 255, blue: 13 / 255).opacity(0.16), radius: 13, y: 10)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }

    private var notice: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    ViewThatFits(in: .horizontal) {
                        linkLine
                        VStack(alignment: .leading, spacing: 2) {
                            TaoziFont.text("1. 你可以查看", style: .footnote, weight: .bold)
                            HStack(spacing: 0) {
                                agreementButton
                                TaoziFont.text(" 和 ", style: .footnote, weight: .bold)
                                privacyButton
                            }
                        }
                    }
                    TaoziFont.text("了解我们收集、使用、共享和存储信息的情况，以及对应的信息保护措施。", style: .footnote, weight: .bold)
                }
                TaoziFont.text("2. 摄像头、麦克风、电话、位置与相册权限均不会默认或强制开启。你可以拒绝授权，相关功能可能受到影响，但不影响其他功能使用。", style: .footnote, weight: .bold)
                TaoziFont.text("3. 在使用服务过程中，我们可能根据功能需要收集设备信息、操作日志、观看记录与任务完成状态，用于保障服务安全和提供内容推荐。", style: .footnote, weight: .bold)
            }
            .foregroundStyle(Color.consentInk)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .frame(height: 206)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, Color.consentCardMid.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)
        }
    }

    private var linkLine: some View {
        HStack(spacing: 0) {
            TaoziFont.text("1. 你可以查看 ", style: .footnote, weight: .bold)
            agreementButton
            TaoziFont.text(" 和 ", style: .footnote, weight: .bold)
            privacyButton
        }
        .lineLimit(1)
    }

    private var agreementButton: some View {
        Button {
            onOpen(.userAgreement)
        } label: {
            TaoziFont.text("《用户协议》", style: .footnote, weight: .bold)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
    }

    private var privacyButton: some View {
        Button {
            onOpen(.privacyPolicy)
        } label: {
            TaoziFont.text("《隐私政策》", style: .footnote, weight: .bold)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
    }
}

private extension Color {
    static let consentInk = Color(red: 33 / 255, green: 28 / 255, blue: 26 / 255)
    static let consentStone = Color(red: 117 / 255, green: 110 / 255, blue: 107 / 255)
    static let consentCardTop = Color(red: 1, green: 254 / 255, blue: 252 / 255)
    static let consentCardMid = Color(red: 1, green: 246 / 255, blue: 240 / 255)
    static let consentCardBottom = Color(red: 1, green: 219 / 255, blue: 204 / 255)
}
