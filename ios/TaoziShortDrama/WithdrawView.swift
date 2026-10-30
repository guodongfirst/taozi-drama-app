import SwiftUI

enum WithdrawRoute: Hashable {
    case page
}

struct WithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount = "0.3"

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 0) {
                    balances
                        .padding(.top, 15)
                    card
                        .padding(.top, 17)
                        .padding(.horizontal, 12)
                    footer
                        .padding(.top, 15)
                }
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            LinearGradient(
                stops: [
                    .init(color: .minePeach, location: 0),
                    .init(color: .mineBlush, location: 0.42),
                    .init(color: .mineCream, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        ZStack {
            TaoziFont.text("提现", style: .body, weight: .bold)
                .foregroundStyle(Color.withdrawInk)
            HStack {
                Button(action: { dismiss() }) {
                    Image("withdraw-back")
                        .resizable()
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("返回")
                Spacer()
                Button(action: {}) {
                    TaoziFont.text("历史记录", style: .caption2, weight: .bold)
                        .foregroundStyle(Color.withdrawStone)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
        }
        .frame(height: 44)
    }

    private var balances: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                balanceTitle("金币余额")
                TaoziFont.text("3500", size: 30, weight: .semibold)
                    .foregroundStyle(Color.withdrawInk)
                    .frame(height: 36, alignment: .bottom)
                    .padding(.top, 8)
                TaoziFont.text("每天凌晨自动兑换成现金", size: 9, weight: .bold)
                    .foregroundStyle(Color.withdrawStone)
                    .lineLimit(1)
                    .frame(height: 17, alignment: .top)
                    .padding(.top, 5)
            }
            .frame(width: 190, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                balanceTitle("现金余额")
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    TaoziFont.text("0.71", size: 30, weight: .semibold)
                    TaoziFont.text("元", style: .caption2, weight: .bold)
                }
                .foregroundStyle(Color.withdrawInk)
                .frame(height: 36, alignment: .bottom)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 28)
    }

    private func balanceTitle(_ title: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                TaoziFont.text(title, style: .caption2, weight: .bold)
                Image("withdraw-chevron")
                    .resizable()
                    .frame(width: 6.6, height: 9.6)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.withdrawInk)
            .frame(height: 18)
        }
        .buttonStyle(.plain)
    }

    private var card: some View {
        VStack(spacing: 0) {
            HStack(spacing: 3) {
                Image("withdraw-wechat")
                    .resizable()
                    .frame(width: 22, height: 20)
                    .accessibilityHidden(true)
                TaoziFont.text("微信提现", style: .caption, weight: .bold)
                    .foregroundStyle(Color.withdrawInk)
            }
            .padding(.leading, 13)
            .padding(.top, 13)
            .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 10
            ) {
                ForEach(withdrawTiers) { tier in
                    tierButton(tier)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 15)

            actionButton(title: "立即提现", color: .withdrawGreen, action: {})
                .padding(.horizontal, 14)
                .padding(.top, 20)

            actionButton(title: "看视频领现金", color: .taskAccent, action: {})
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 14))
    }

    private func tierButton(_ tier: WithdrawTier) -> some View {
        let selected = selectedAmount == tier.amount
        return Button {
            selectedAmount = tier.amount
        } label: {
            VStack(spacing: 0) {
                (
                    TaoziFont.text(tier.amount, size: 18, weight: .semibold)
                        + TaoziFont.text("元", size: 14, weight: .bold)
                )
                .foregroundStyle(selected ? Color.taskAccent : Color.withdrawInk)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                TaoziFont.text("今日剩余\(tier.remaining)次", size: 9, weight: .bold)
                    .foregroundStyle(selected ? Color.white : Color.withdrawStone)
                    .frame(maxWidth: .infinity)
                    .frame(height: 23)
                    .background(selected ? Color.taskAccent : Color.withdrawTierFoot)
            }
            .frame(height: 82)
            .background(selected ? Color.withdrawSelected : Color.withdrawTier)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(Color.taskAccent, lineWidth: 2.2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                playIcon
                TaoziFont.text(title, style: .callout, weight: .bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var playIcon: some View {
        Image("withdraw-play-ring")
            .resizable()
            .frame(width: 14, height: 14)
            .overlay {
                Image("withdraw-play-mark")
                    .resizable()
                    .frame(width: 6.75, height: 8)
            }
            .accessibilityHidden(true)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            TaoziFont.text("本服务由桃子小剧提供", size: 9, weight: .bold)
                .foregroundStyle(Color.withdrawStone)
            Button(action: {}) {
                TaoziFont.text("《提现规则》", size: 9, weight: .bold)
                    .foregroundStyle(Color.taskAccent)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WithdrawTier: Identifiable {
    let amount: String
    let remaining: Int
    var id: String { amount }
}

private let withdrawTiers = [
    WithdrawTier(amount: "0.3", remaining: 3),
    WithdrawTier(amount: "0.5", remaining: 3),
    WithdrawTier(amount: "1", remaining: 1),
    WithdrawTier(amount: "2", remaining: 1),
    WithdrawTier(amount: "5", remaining: 2),
    WithdrawTier(amount: "10", remaining: 2),
    WithdrawTier(amount: "20", remaining: 1)
]

#Preview {
    NavigationStack {
        WithdrawView()
    }
}
