import Foundation

struct DramaCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let tags: [String]
}

enum DramaCornerTone {
    case accent
    case fresh
    case neutral
}

struct DramaCorner: Hashable {
    let title: String
    let tone: DramaCornerTone
}

struct DramaSummary: Identifiable, Hashable {
    let id: Int64
    let title: String
    let coverURL: URL?
    let episodeCount: Int?
    let corner: DramaCorner?
    let categoryID: String
}

struct DramaRoute: Hashable {
    let id: Int64
    let title: String
}

enum WatchedDramas {
    private static let key = "watchedDramaIDs"

    static func contains(_ id: Int64) -> Bool {
        ids().contains(id)
    }

    static func mark(_ id: Int64) {
        var values = ids()
        values.insert(id)
        let stored = values.map(String.init)
        UserDefaults.standard.set(stored, forKey: key)
    }

    private static func ids() -> Set<Int64> {
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(stored.compactMap(Int64.init))
    }
}
