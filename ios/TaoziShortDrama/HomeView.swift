import SwiftUI
import UIKit

struct HomeView: View {
    var catalog: any DramaCatalog = PangleDramaCatalog.shared

    @State private var categories: [DramaCategory] = []
    @State private var categoryID = DramaFeed.recommendID
    @State private var selectedTags: [String: String] = [:]
    @State private var pages: [String: [DramaSummary]] = [:]
    @State private var nextPage: [String: Int] = [:]
    @State private var hasMore: [String: Bool] = [:]
    @State private var anchors: [String: Int64?] = [:]
    @State private var loading = true
    @State private var loadingMore = false
    @State private var failed = false
    @State private var pageFailed = false
    @State private var requestID = 0
    @State private var watchedTick = 0

    private var selectedTag: String {
        selectedTags[categoryID] ?? "全部"
    }

    private var feedKey: String {
        "\(categoryID)|\(selectedTag)"
    }

    private var items: [DramaSummary] {
        pages[feedKey] ?? []
    }

    private var currentCategory: DramaCategory? {
        categories.first { $0.id == categoryID }
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryBar
            if let tags = currentCategory?.tags, tags.count > 1 {
                tagBar(tags)
                    .padding(.top, 12)
            }
            feed
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.homeBackground)
        .onAppear { watchedTick += 1 }
        .task(id: feedKey) {
            await loadIfNeeded()
        }
    }

    private var categoryBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                            categoryID = category.id
                        } label: {
                            VStack(spacing: 4) {
                                Text(category.name)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(category.id == categoryID ? Color.homeInk : Color.homeStone)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                Capsule()
                                    .fill(category.id == categoryID ? Color.accentColor : Color.clear)
                                    .frame(width: 22, height: 3)
                            }
                            .padding(.horizontal, 8)
                            .frame(minWidth: 58)
                        }
                        .buttonStyle(.plain)
                        .id(category.id)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
            }
            .onChange(of: categoryID) { _, newID in
                alignCategory(newID, proxy: proxy)
            }
        }
    }

    private func alignCategory(_ id: String, proxy: ScrollViewProxy) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        let anchor: UnitPoint
        if index == 0 {
            anchor = .leading
        } else if index == categories.count - 1 {
            anchor = .trailing
        } else {
            anchor = .center
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(id, anchor: anchor)
        }
    }

    private func tagBar(_ tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        selectedTags[categoryID] = tag
                    } label: {
                        Text(tag)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(tag == selectedTag ? Color.accentColor : Color.homeStone)
                            .padding(.horizontal, 12)
                            .frame(height: 28)
                            .background(tag == selectedTag ? Color.homeChipOn : Color.homeChipOff, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 15)
        }
    }

    @ViewBuilder
    private var feed: some View {
        if loading && items.isEmpty {
            placeholder
        } else if failed && items.isEmpty {
            failure(message: DramaCatalogError.unavailable.localizedDescription) {
                Task { await reload() }
            }
        } else if items.isEmpty {
            failure(message: "暂无短剧") {
                Task { await reload() }
            }
        } else {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3),
                    spacing: 14
                ) {
                    ForEach(items) { item in
                        NavigationLink(value: DramaRoute(id: item.id, title: item.title, episodeCount: item.episodeCount ?? 0)) {
                            DramaCard(drama: item, watched: watchedTick > 0 && WatchedDramas.contains(item.id))
                        }
                        .buttonStyle(.plain)
                        .id(item.id)
                        .onAppear {
                            catalog.trackImpression(item.id)
                            if item.id == items.last?.id {
                                Task { await loadMore() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                footer
                    .padding(.top, 16)
                    .padding(.bottom, 12)
            }
            .id(feedKey)
            .scrollPosition(id: anchorBinding, anchor: .top)
            .refreshable {
                await reload()
            }
        }
    }

    private var anchorBinding: Binding<Int64?> {
        Binding(
            get: { anchors[feedKey] ?? nil },
            set: { anchors[feedKey] = $0 }
        )
    }

    private var placeholder: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3),
            spacing: 14
        ) {
            ForEach(0..<9, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.homeChipOff)
                        .aspectRatio(109 / 145, contentMode: .fit)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.homeChipOff)
                        .frame(height: 13)
                        .padding(.trailing, 18)
                }
            }
        }
        .padding(.horizontal, 15)
    }

    @ViewBuilder
    private var footer: some View {
        if pageFailed {
            Button("重试") {
                Task { await loadMore() }
            }
            .font(.footnote.weight(.bold))
            .foregroundStyle(Color.homeStone)
        } else if loadingMore {
            ProgressView()
        } else if hasMore[feedKey] == false {
            Text("已加载完成")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.homeStone)
        }
    }

    private func failure(message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.homeStone)
            Button("重试", action: retry)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadIfNeeded() async {
        guard pages[feedKey] == nil else { return }
        await reload()
    }

    private func reload() async {
        requestID += 1
        let token = requestID
        loading = pages[feedKey] == nil
        failed = false
        pageFailed = false
        do {
            if categories.isEmpty {
                let loaded = try await catalog.categories()
                guard token == requestID, !Task.isCancelled else { return }
                categories = loaded
                if !loaded.contains(where: { $0.id == categoryID }) {
                    categoryID = loaded.first?.id ?? DramaFeed.recommendID
                }
            }
            let key = feedKey
            let page = try await catalog.dramas(
                categoryID: categoryID,
                tag: selectedTag == "全部" ? nil : selectedTag,
                page: 1
            )
            guard token == requestID, !Task.isCancelled else { return }
            pages[key] = page.items
            nextPage[key] = 2
            hasMore[key] = page.hasMore
            loading = false
        } catch {
            guard token == requestID, !Task.isCancelled else { return }
            loading = false
            failed = pages[feedKey]?.isEmpty != false
        }
    }

    private func loadMore() async {
        let key = feedKey
        guard hasMore[key] == true, !loadingMore, !loading else { return }
        loadingMore = true
        pageFailed = false
        let token = requestID
        let pageNumber = nextPage[key] ?? 2
        do {
            let page = try await catalog.dramas(
                categoryID: categoryID,
                tag: selectedTag == "全部" ? nil : selectedTag,
                page: pageNumber
            )
            guard token == requestID, key == feedKey, !Task.isCancelled else {
                loadingMore = false
                return
            }
            var merged = pages[key] ?? []
            let seen = Set(merged.map(\.id))
            merged.append(contentsOf: page.items.filter { !seen.contains($0.id) })
            pages[key] = merged
            nextPage[key] = pageNumber + 1
            hasMore[key] = page.hasMore && !page.items.isEmpty
            loadingMore = false
        } catch {
            guard token == requestID, !Task.isCancelled else { return }
            loadingMore = false
            pageFailed = true
        }
    }
}

private struct DramaCard: View {
    let drama: DramaSummary
    var watched = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            cover
            Text(drama.title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.homeInk)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cover: some View {
        Color.clear
            .aspectRatio(109 / 145, contentMode: .fit)
            .overlay {
                coverImage
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topTrailing) {
                if let corner = watched ? DramaCorner(title: "看过", tone: .neutral) : drama.corner {
                    Text(corner.title)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 18)
                        .background(cornerColor(corner.tone), in: UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 7, bottomTrailingRadius: 0, topTrailingRadius: 7))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let count = drama.episodeCount, count > 0 {
                    Text("\(count)集")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .frame(height: 20)
                        .background(Color.homeEpisode, in: Capsule())
                        .padding(6)
                }
            }
    }

    private var coverImage: some View {
        DramaCoverImage(url: drama.coverURL)
    }

    private func cornerColor(_ tone: DramaCornerTone) -> Color {
        switch tone {
        case .accent:
            Color.accentColor
        case .fresh:
            Color.homeFresh
        case .neutral:
            Color.homeStone
        }
    }
}

private enum DramaCoverStore {
    static var images: [URL: UIImage] = [:]
}

private struct DramaCoverImage: View {
    let url: URL?
    @State private var image: UIImage?

    var body: some View {
        Color.homeChipOff
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .task(id: url) {
                await load()
            }
    }

    private func load() async {
        guard let url else { return }
        if let cached = DramaCoverStore.images[url] {
            image = cached
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled, let loaded = UIImage(data: data) else { return }
            DramaCoverStore.images[url] = loaded
            image = loaded
        } catch {
            return
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(catalog: PreviewDramaCatalog())
    }
}

private struct PreviewDramaCatalog: DramaCatalog {
    func categories() async throws -> [DramaCategory] {
        [
            DramaCategory(id: DramaFeed.recommendID, name: "推荐", tags: ["全部", "仙侠奇缘", "萌宝团宠", "逆袭战神"]),
            DramaCategory(id: "都市", name: "都市", tags: ["全部", "仙侠奇缘", "萌宝团宠", "战神龙王"]),
            DramaCategory(id: "热血", name: "热血", tags: []),
            DramaCategory(id: "现代", name: "现代", tags: []),
            DramaCategory(id: "玄幻", name: "玄幻", tags: ["全部", "仙侠奇缘"]),
            DramaCategory(id: "其他", name: "其他", tags: ["全部", "仙侠奇缘"])
        ]
    }

    func dramas(categoryID: String, tag: String?, page: Int) async throws -> DramaPage {
        guard page == 1 else { return DramaPage(items: [], hasMore: false) }
        let samples: [(String, Int, String, DramaCornerTone)] = [
            ("春风替我告白", 81, "爆款", .accent),
            ("她从雨中归来", 95, "爆款", .accent),
            ("小叔超宠我", 76, "上新", .fresh),
            ("凤归梧桐", 100, "上新", .fresh),
            ("长安旧梦", 88, "爆款", .accent),
            ("困局破晓", 90, "热播", .accent),
            ("镇国神帅", 72, "爆款", .accent),
            ("妈妈救救我", 64, "上新", .fresh),
            ("掌心玫瑰", 92, "爆款", .accent)
        ]
        let items = samples.enumerated().map { index, sample in
            DramaSummary(
                id: Int64(index + 1),
                title: sample.0,
                coverURL: nil,
                episodeCount: sample.1,
                corner: DramaCorner(title: sample.2, tone: sample.3),
                categoryID: categoryID
            )
        }
        return DramaPage(items: items, hasMore: false)
    }

    func trackImpression(_ id: Int64) {}
}
