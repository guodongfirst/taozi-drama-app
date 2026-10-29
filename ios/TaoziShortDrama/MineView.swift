import SwiftUI

struct MineView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                    .padding(.top, 38)
                VStack(spacing: 10) {
                    ForEach(mineEntries) { entry in
                        entryRow(entry)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 31)
                .padding(.bottom, 12)
            }
        }
        .scrollIndicators(.hidden)
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
            .ignoresSafeArea(edges: .top)
        }
    }

    private var profileHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            Image("mine-avatar")
                .resizable()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 4) {
                    TaoziFont.text("桃桃剧迷", size: 20, weight: .bold)
                        .foregroundStyle(Color.mineInk)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image("mine-setting")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .accessibilityHidden(true)
                            TaoziFont.text("设置", style: .footnote, weight: .bold)
                        }
                        .foregroundStyle(Color.mineInk)
                    }
                    .buttonStyle(.plain)
                }
                TaoziFont.text("ID: 8PQY5A8D883", size: 11, weight: .semibold)
                    .foregroundStyle(Color.mineStone)
                    .lineLimit(1)
            }
            .padding(.top, 8)
        }
        .padding(.leading, 24)
        .padding(.trailing, 31)
    }

    private func entryRow(_ entry: MineEntry) -> some View {
        Button(action: {}) {
            HStack(spacing: 0) {
                Image(entry.icon)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .accessibilityHidden(true)
                TaoziFont.text(entry.title, style: .subheadline, weight: .bold)
                    .foregroundStyle(Color.mineInk)
                    .padding(.leading, 12)
                Spacer(minLength: 8)
                if let detail = entry.detail {
                    TaoziFont.text(detail, style: .footnote, weight: .bold)
                        .foregroundStyle(Color.mineStone)
                        .padding(.trailing, 15)
                }
                Image("mine-chevron")
                    .resizable()
                    .frame(width: 5.8, height: 9.8)
                    .accessibilityHidden(true)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct MineEntry: Identifiable {
    let icon: String
    let title: String
    var detail: String?
    var id: String { title }
}

private let mineEntries = [
    MineEntry(icon: "mine-preference", title: "看剧偏好", detail: "女频"),
    MineEntry(icon: "mine-record", title: "追剧记录"),
    MineEntry(icon: "mine-watch", title: "看剧设置"),
    MineEntry(icon: "mine-feedback", title: "意见反馈"),
    MineEntry(icon: "mine-faq", title: "常见问题")
]

#Preview {
    MineView()
        .preferredColorScheme(.light)
}
