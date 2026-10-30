import SwiftUI

enum MainTab {
    case drama
    case task
    case mine
}

struct ContentView: View {
    @State private var tab = MainTab.drama
    @State private var homeRefresh = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    HomeView(refreshTick: homeRefresh)
                        .opacity(tab == .drama ? 1 : 0)
                        .allowsHitTesting(tab == .drama)
                    if tab == .task {
                        TaskCenterView(onWatchDrama: { tab = .drama })
                    } else if tab == .mine {
                        MineView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                MainTabBar(tab: $tab)
            }
            .background(Color.homeBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: DramaRoute.self) { route in
                DramaPlayerView(route: route)
                    .toolbar(.hidden, for: .navigationBar)
                    .ignoresSafeArea()
                    .onDisappear { homeRefresh += 1 }
            }
            .navigationDestination(for: WithdrawRoute.self) { _ in
                WithdrawView()
            }
        }
        .preferredColorScheme(.light)
    }
}

private struct MainTabBar: View {
    @Binding var tab: MainTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.homeLine)
                .frame(height: 1)
            HStack(spacing: 0) {
                item(.drama, title: "短剧", image: "nav-drama")
                item(.task, title: "任务", image: "nav-task")
                item(.mine, title: "我的", image: "nav-mine")
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }

    private func item(_ value: MainTab, title: String, image: String) -> some View {
        let selected = tab == value
        return Button {
            tab = value
        } label: {
            VStack(spacing: 3) {
                Image(selected ? "\(image)-selected" : image)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .overlay(alignment: .topTrailing) {
                        if value == .mine {
                            Image("mine-notice")
                                .resizable()
                                .frame(width: 8, height: 8)
                                .offset(x: 3.5, y: -5)
                                .accessibilityHidden(true)
                        }
                    }
                TaoziFont.text(title, style: .caption2, weight: .bold)
                    .foregroundStyle(selected ? Color.homeTabOn : Color.homeTab)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
