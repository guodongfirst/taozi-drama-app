import Foundation

enum DramaCatalogError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "短剧加载失败"
    }
}

protocol DramaCatalog {
    func categories() async throws -> [DramaCategory]
    func dramas(categoryID: String, tag: String?, page: Int) async throws -> DramaPage
    func trackImpression(_ id: Int64)
    func latestContinueWatching() async -> ContinueWatchingItem?
}

extension DramaCatalog {
    func latestContinueWatching() async -> ContinueWatchingItem? { nil }
}

enum DramaFeed {
    static let recommendID = "recommend"
}
