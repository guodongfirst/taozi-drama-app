import SwiftUI

struct TaskCenterView: View {
    var onWatchDrama: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TaoziFont.text("任务中心", style: .callout, weight: .bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        assetCard
                        dailyCard(minHeight: max(proxy.size.height - 134, 0))
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Image("task-background")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
                .ignoresSafeArea(edges: .top)
                .accessibilityHidden(true)
        }
    }

    private var assetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom, spacing: 0) {
                balanceColumn(title: "金币余额") {
                    TaoziFont.text("3500", size: 28, weight: .semibold)
                }
                balanceColumn(title: "现金余额") {
                    TaoziFont.text("0.71", size: 28, weight: .semibold)
                    + TaoziFont.text("元", style: .caption2, weight: .bold)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                NavigationLink(value: WithdrawRoute.page) {
                    TaoziFont.text("提现", style: .caption, weight: .bold)
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 32)
                        .background(Color.taskAccent, in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
            }
            TaoziFont.text("每天凌晨自动兑换成现金", size: 10, weight: .bold)
                .foregroundStyle(Color.taskStone)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
    }

    private func balanceColumn(title: String, @ViewBuilder value: () -> Text) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TaoziFont.text(title, style: .caption, weight: .bold)
                .foregroundStyle(Color.taskInk)
            value()
                .foregroundStyle(Color.taskAccent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dailyCard(minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image("task-badge")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                TaoziFont.text("每日任务", style: .callout, weight: .bold)
                    .foregroundStyle(Color.taskAccent)
            }
            .padding(.top, 10)
            .padding(.bottom, 12)

            taskRow(title: "签到", coins: 8300, button: "已完成", active: false) {
                TaoziFont.text("签到领金币，看短剧可获得额外奖励", size: 10, weight: .bold)
            }

            taskDivider
                .padding(.top, 10)

            taskRow(title: "看剧得奖励", coins: 146420, button: "去看剧", active: true, action: onWatchDrama) {
                watchedTodayText
            }
            .padding(.top, 14)

            watchRewards
                .padding(.top, 10)

            taskDivider
                .padding(.top, 10)

            taskRow(title: "看视频领金币", coins: nil, button: "去观看", active: true, action: {}) {
                TaoziFont.text("观看视频即可获得金币", size: 10, weight: .bold)
            }
            .padding(.top, 14)

            videoProgress
                .padding(.top, 12)

            taskDivider
                .padding(.top, 18)

            taskRow(title: "饭点看剧奖励", coins: 500, button: "去看剧", active: true, action: onWatchDrama) {
                TaoziFont.text("17:00可领取晚间补贴，先去看剧吧", size: 10, weight: .bold)
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
    }

    private var watchRewards: some View {
        HStack(spacing: 9) {
            ForEach(watchRewardItems) { reward in
                VStack(spacing: 4) {
                    VStack(spacing: 10) {
                        Image("task-coin")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .accessibilityHidden(true)
                            .padding(.top, 8)
                        TaoziFont.text("+\(reward.coins)", style: .caption, weight: .semibold)
                            .foregroundStyle(.white)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 56, height: 62)
                    .background {
                        Image("task-reward")
                            .resizable()
                            .accessibilityHidden(true)
                    }
                    TaoziFont.text("\(reward.episodes)集", size: 9, weight: .bold)
                    .foregroundStyle(Color.taskStone)
                }
            }
        }
    }

    private var videoProgress: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(Color.taskTrack)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.taskAccent)
                        .frame(width: 2, height: 5)
                }
            TaoziFont.text("0/5次", size: 9, weight: .bold)
            .foregroundStyle(Color.taskStone)
        }
    }

    private func taskRow(
        title: String,
        coins: Int?,
        button: String,
        active: Bool,
        action: (() -> Void)? = nil,
        @ViewBuilder subtitle: () -> Text
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                HStack(spacing: 4) {
                    TaoziFont.text(title, style: .footnote, weight: .bold)
                        .foregroundStyle(Color.taskInk)
                        .padding(.trailing, 12)
                    if let coins {
                        Image("task-coin")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .accessibilityHidden(true)
                        TaoziFont.text("\(coins)", style: .footnote, weight: .semibold)
                            .foregroundStyle(Color.taskAccent)
                            // DIN Condensed 字面偏上，下移后与金币图标垂直居中。
                            .offset(y: 1.5)
                    }
                }
                Spacer(minLength: 8)
                taskButton(button, active: active, action: action)
            }
            subtitle()
                .foregroundStyle(Color.taskStone)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func taskButton(_ title: String, active: Bool, action: (() -> Void)?) -> some View {
        let label = TaoziFont.text(title, size: 10, weight: .bold)
            .foregroundStyle(active ? Color.taskAccent : Color.taskStone)
            .frame(width: 60, height: 28)
            .background(active ? Color.taskAction : Color.homeChipOff, in: RoundedRectangle(cornerRadius: 9))
        if let action, active {
            Button(action: action) { label }
                .buttonStyle(.plain)
        } else {
            label
        }
    }

    private var watchedTodayText: Text {
        var prefix = AttributedString("今日已观看：")
        prefix.font = .system(size: 10, weight: .bold)
        var count = AttributedString("0")
        count.font = .custom("DINCondensed-Bold", size: 10)
        // 数字和汉字分成两段字体后，SwiftUI 会在「0」和「集」之间多出空隙。
        count.kern = -5
        var unit = AttributedString("集")
        unit.font = .system(size: 10, weight: .bold)
        return Text(prefix + count + unit)
    }

    private var taskDivider: some View {
        Rectangle()
            .fill(Color.homeLine)
            .frame(height: 1)
    }
}

private struct WatchReward: Identifiable {
    let episodes: Int
    let coins: Int
    var id: Int { episodes }
}

private let watchRewardItems = [
    WatchReward(episodes: 1, coins: 1180),
    WatchReward(episodes: 2, coins: 1180),
    WatchReward(episodes: 5, coins: 2180),
    WatchReward(episodes: 10, coins: 2880),
    WatchReward(episodes: 18, coins: 3880)
]

#Preview {
    TaskCenterView(onWatchDrama: {})
        .preferredColorScheme(.light)
}
