import SwiftUI

struct TaskCenterView: View {
    var onWatchDrama: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("任务中心")
                .font(.callout.weight(.bold))
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
                    Text("3500")
                        .font(.system(size: 28, weight: .semibold))
                        .fontWidth(.condensed)
                }
                balanceColumn(title: "现金余额") {
                    Text("0.71")
                        .font(.system(size: 28, weight: .semibold))
                        .fontWidth(.condensed)
                    + Text("元")
                        .font(.caption2.weight(.bold))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {}) {
                    Text("提现")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 32)
                        .background(Color.taskAccent, in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
            }
            Text("每天凌晨自动兑换成现金")
                .font(.system(size: 10, weight: .bold))
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
            Text(title)
                .font(.caption.weight(.bold))
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
                Text("每日任务")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(Color.taskAccent)
            }
            .padding(.top, 10)
            .padding(.bottom, 12)

            taskRow(title: "签到", coins: 8300, button: "已完成", active: false) {
                Text("签到领金币，看短剧可获得额外奖励")
                    .font(.system(size: 10, weight: .bold))
            }

            taskDivider
                .padding(.top, 10)

            taskRow(title: "看剧得奖励", coins: 146420, button: "去看剧", active: true, action: onWatchDrama) {
                Text("今日已观看：")
                    .font(.system(size: 10, weight: .bold))
                + Text("0")
                    .font(.system(size: 10, weight: .semibold).width(.condensed))
                + Text("集")
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.top, 14)

            watchRewards
                .padding(.top, 10)

            taskDivider
                .padding(.top, 10)

            taskRow(title: "看视频领金币", coins: nil, button: "去观看", active: true, action: {}) {
                Text("观看视频即可获得金币")
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.top, 14)

            videoProgress
                .padding(.top, 12)

            taskDivider
                .padding(.top, 18)

            taskRow(title: "饭点看剧奖励", coins: 500, button: "去看剧", active: true, action: onWatchDrama) {
                Text("17:00")
                    .font(.system(size: 10, weight: .semibold).width(.condensed))
                + Text("可领取晚间补贴，先去看剧吧")
                    .font(.system(size: 10, weight: .bold))
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
                    VStack(spacing: 2) {
                        Image("task-coin")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .accessibilityHidden(true)
                            .padding(.top, 8)
                        Text("+\(reward.coins)")
                            .font(.caption.weight(.semibold))
                            .fontWidth(.condensed)
                            .foregroundStyle(.white)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 56, height: 62)
                    .background {
                        Image("task-reward")
                            .resizable()
                            .accessibilityHidden(true)
                    }
                    (Text("\(reward.episodes)")
                        .font(.system(size: 9, weight: .semibold).width(.condensed))
                    + Text("集")
                        .font(.system(size: 9, weight: .bold)))
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
            (Text("0")
                .font(.system(size: 9, weight: .semibold).width(.condensed))
            + Text("/")
                .font(.system(size: 9, weight: .bold))
            + Text("5")
                .font(.system(size: 9, weight: .semibold).width(.condensed))
            + Text("次")
                .font(.system(size: 9, weight: .bold)))
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
                    Text(title)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.taskInk)
                        .padding(.trailing, 12)
                    if let coins {
                        Image("task-coin")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .accessibilityHidden(true)
                        Text("\(coins)")
                            .font(.footnote.weight(.semibold))
                            .fontWidth(.condensed)
                            .foregroundStyle(Color.taskAccent)
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
        let label = Text(title)
            .font(.system(size: 10, weight: .bold))
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
