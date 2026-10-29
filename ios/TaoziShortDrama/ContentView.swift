import SwiftUI

enum MainTab {
    case drama
    case task
    case mine
}

struct ContentView: View {
    @State private var tab = MainTab.drama

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    HomeView()
                        .opacity(tab == .drama ? 1 : 0)
                        .allowsHitTesting(tab == .drama)
                    if tab == .task {
                        MainTabPlaceholder(title: "任务")
                    } else if tab == .mine {
                        MainTabPlaceholder(title: "我的")
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
            }
        }
        .preferredColorScheme(.light)
    }
}

private struct MainTabPlaceholder: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.homeInk)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.homeBackground)
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
                Text(title)
                    .font(.caption2.weight(.bold))
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
