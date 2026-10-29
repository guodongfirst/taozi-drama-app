import Foundation
import PangrowthDJX

final class PangleDramaCatalog: DramaCatalog {
    static let shared = PangleDramaCatalog()

    private let pageSize = 20
    private var models: [Int64: DJXPlayletInfoModel] = [:]

    func categories() async throws -> [DramaCategory] {
        try await ready()
        let names = try await categoryNames()
        return Self.makeCategories(names)
    }

    func dramas(categoryID: String, tag: String?, page: Int) async throws -> DramaPage {
        try await ready()
        let query = (tag?.isEmpty == false && tag != "全部") ? tag! : categoryID
        if categoryID == DramaFeed.recommendID && query == DramaFeed.recommendID {
            return try await recommended(page: page)
        }
        return try await category(query, page: page)
    }

    func trackImpression(_ id: Int64) {
        guard let model = models[id] else { return }
        DJXPlayletManager.shareInstance().trackEvent(.clientShow, withPlayletInfo: model)
    }

    func model(for id: Int64) -> DJXPlayletInfoModel? {
        models[id]
    }

    func latestContinueWatching() async -> ContinueWatchingItem? {
        do {
            try await ready()
        } catch {
            return nil
        }
        return await withCheckedContinuation { continuation in
            DJXPlayletManager.shareInstance().requestPlayletHistoryList(withPage: 1, num: 20) { [weak self] list in
                continuation.resume(returning: self?.continueItem(list))
            } failure: { _ in
                continuation.resume(returning: nil)
            }
        }
    }

    private func ready() async throws {
        let started = await withCheckedContinuation { continuation in
            PangleContent.whenReady { success in
                continuation.resume(returning: success)
            }
        }
        guard started else { throw DramaCatalogError.unavailable }
    }

    private func categoryNames() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            DJXPlayletManager.shareInstance().requestCategoryList { list in
                print("[短剧] 分类 \(list.count) \(list)")
                continuation.resume(returning: list)
            } failure: { error in
                print("[短剧] 分类失败 \(error)")
                continuation.resume(throwing: DramaCatalogError.unavailable)
            }
        }
    }

    private func recommended(page: Int) async throws -> DramaPage {
        try await withCheckedThrowingContinuation { continuation in
            DJXPlayletManager.shareInstance().requestRecommendedPlayletListPage(
                page,
                num: pageSize,
                success: { [weak self] list, info in
                    print("[短剧] 推荐 \(list.count)")
                    continuation.resume(returning: self?.page(from: list, info: info, categoryID: DramaFeed.recommendID) ?? DramaPage(items: [], hasMore: false))
                },
                failure: { error in
                    print("[短剧] 推荐失败 \(error)")
                    continuation.resume(throwing: DramaCatalogError.unavailable)
                }
            )
        }
    }

    private func category(_ name: String, page: Int) async throws -> DramaPage {
        try await withCheckedThrowingContinuation { continuation in
            DJXPlayletManager.shareInstance().requestCategoryPlayletLis(
                withCategory: name,
                page: page,
                num: pageSize,
                order: .reverse,
                success: { [weak self] list in
                    let items = self?.summaries(list, categoryID: name) ?? []
                    continuation.resume(returning: DramaPage(items: items, hasMore: list.count >= (self?.pageSize ?? 20)))
                },
                failure: { error in
                    print("[短剧] 分类列表失败 \(error)")
                    continuation.resume(throwing: DramaCatalogError.unavailable)
                }
            )
        }
    }

    private func page(from list: [DJXPlayletInfoModel]?, info: [String: NSObject]?, categoryID: String) -> DramaPage {
        let items = summaries(list, categoryID: categoryID)
        let hasMore = Self.hasMore(info: info, count: list?.count ?? 0, pageSize: pageSize)
        return DramaPage(items: items, hasMore: hasMore)
    }

    private func summaries(_ list: [DJXPlayletInfoModel]?, categoryID: String) -> [DramaSummary] {
        (list ?? []).compactMap { model in
            guard model.shortplay_id > 0 else { return nil }
            let id = Int64(model.shortplay_id)
            models[id] = model
            let count = model.total > 0 ? Int(model.total) : nil
            return DramaSummary(
                id: id,
                title: model.title,
                coverURL: URL(string: model.cover_image),
                episodeCount: count,
                corner: Self.corner(model),
                categoryID: categoryID
            )
        }
    }

    private static func hasMore(info: [String: NSObject]?, count: Int, pageSize: Int) -> Bool {
        if let value = info?["has_more"] as? Bool {
            return value
        }
        if let number = info?["has_more"] as? NSNumber {
            return number.boolValue
        }
        return count >= pageSize
    }

    private func continueItem(_ list: [DJXPlayletInfoModel]?) -> ContinueWatchingItem? {
        guard let model = list?.max(by: { Self.watchedAt($0) < Self.watchedAt($1) }) else { return nil }
        let id = Int64(model.shortplay_id)
        let updatedAt = Self.watchedAt(model)
        guard id > 0, model.current_episode > 0, updatedAt > 0 else { return nil }
        models[id] = model
        return ContinueWatchingItem(
            id: id,
            title: model.title,
            coverURL: URL(string: model.cover_image),
            episode: Int(model.current_episode),
            episodeCount: model.total > 0 ? Int(model.total) : 0,
            progress: 0,
            duration: model.video_duration > 0 ? Double(model.video_duration) : 0,
            updatedAt: updatedAt
        )
    }

    private static func watchedAt(_ model: DJXPlayletInfoModel) -> TimeInterval {
        let time = TimeInterval(model.action_time)
        if time > 10_000_000_000 {
            return time / 1000
        }
        return time
    }

    private static func corner(_ model: DJXPlayletInfoModel) -> DramaCorner? {
        if WatchedDramas.contains(Int64(model.shortplay_id)) {
            return DramaCorner(title: "看过", tone: .neutral)
        }
        if model.is_potential {
            return DramaCorner(title: "上新", tone: .fresh)
        }
        switch model.level_label {
        case 1:
            return DramaCorner(title: "爆款", tone: .accent)
        case 2:
            return DramaCorner(title: "热播", tone: .accent)
        default:
            return nil
        }
    }

    private static func makeCategories(_ names: [String]) -> [DramaCategory] {
        let available = Set(names)
        let primaries = ["都市", "热血", "现代", "玄幻", "其他"]
        let useDesigned = primaries.allSatisfy { available.contains($0) }
        if useDesigned {
            return [
                DramaCategory(
                    id: DramaFeed.recommendID,
                    name: "推荐",
                    tags: tags(["仙侠奇缘", "萌宝团宠", "逆袭战神"], available: available)
                ),
                DramaCategory(id: "都市", name: "都市", tags: tags(["仙侠奇缘", "萌宝团宠", "战神龙王"], available: available)),
                DramaCategory(id: "热血", name: "热血", tags: []),
                DramaCategory(id: "现代", name: "现代", tags: []),
                DramaCategory(id: "玄幻", name: "玄幻", tags: tags(["仙侠奇缘"], available: available)),
                DramaCategory(id: "其他", name: "其他", tags: tags(["仙侠奇缘"], available: available))
            ]
        }
        return [DramaCategory(id: DramaFeed.recommendID, name: "推荐", tags: [])] + names.map { name in
            DramaCategory(id: name, name: name, tags: [])
        }
    }

    private static func tags(_ names: [String], available: Set<String>) -> [String] {
        let matched = names.filter { available.contains($0) }
        guard !matched.isEmpty else { return [] }
        return ["全部"] + matched
    }
}
