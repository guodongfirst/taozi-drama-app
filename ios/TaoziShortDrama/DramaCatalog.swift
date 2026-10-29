import Foundation

enum DramaCatalogError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "短剧加载失败"
    }
}

protocol DramaCatalog {
    func categories() async throws -> [DramaCategory]
    func dramas(categoryID: String, tag: String?) async throws -> [DramaSummary]
}

enum DramaFeed {
    static let recommendID = "recommend"
}
