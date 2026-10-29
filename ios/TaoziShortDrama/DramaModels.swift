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

struct DramaPage {
    let items: [DramaSummary]
    let hasMore: Bool
}

struct DramaRoute: Hashable {
    let id: Int64
    let title: String
    let episodeCount: Int
    var episode: Int = 1
    var startTime: Double = 0
}

struct ContinueWatchingItem: Equatable, Sendable {
    let id: Int64
    let title: String
    let coverURL: URL?
    let episode: Int
    let episodeCount: Int
    let progress: Double
    let duration: Double
    let updatedAt: TimeInterval

    var resumeEpisode: Int {
        let current = max(episode, 1)
        if progress >= 0.98, episodeCount > current {
            return current + 1
        }
        return current
    }

    var resumeTime: Double {
        guard progress > 0.02, progress < 0.98, duration > 1 else { return 0 }
        return progress * duration
    }
}

enum ContinueWatching {
    private static let recordKey = "continueWatchingRecord"

    private struct Record: Codable {
        var id: Int64
        var title: String
        var cover: String?
        var episode: Int
        var episodeCount: Int
        var progress: Double
        var duration: Double
        var updatedAt: TimeInterval
        var hidden: Bool

        var item: ContinueWatchingItem {
            ContinueWatchingItem(
                id: id,
                title: title,
                coverURL: cover.flatMap(URL.init(string:)),
                episode: episode,
                episodeCount: episodeCount,
                progress: progress,
                duration: duration,
                updatedAt: updatedAt
            )
        }
    }

    static func current() -> ContinueWatchingItem? {
        guard let record = load(), !record.hidden, record.episode > 0 else { return nil }
        return record.item
    }

    static func remember(
        id: Int64,
        title: String,
        coverURL: URL?,
        episode: Int,
        episodeCount: Int,
        progress: Double?,
        duration: Double?
    ) {
        guard id > 0, episode > 0 else { return }
        let existing = load()
        let sameDrama = existing?.id == id
        let record = Record(
            id: id,
            title: title.isEmpty ? (existing?.title ?? "") : title,
            cover: coverURL?.absoluteString ?? (sameDrama ? existing?.cover : nil),
            episode: episode,
            episodeCount: episodeCount > 0 ? episodeCount : (sameDrama ? existing?.episodeCount ?? 0 : 0),
            progress: progress ?? (sameDrama ? existing?.progress ?? 0 : 0),
            duration: duration ?? (sameDrama ? existing?.duration ?? 0 : 0),
            updatedAt: Date().timeIntervalSince1970,
            hidden: false
        )
        store(record)
    }

    static func noteProgress(_ progress: Double, duration: Double?, id: Int64) {
        guard var record = load(), record.id == id, !record.hidden else { return }
        record.progress = min(max(progress, 0), 1)
        if let duration, duration > 0 {
            record.duration = duration
        }
        store(record)
    }

    static func dismiss() {
        guard var record = load() else { return }
        record.hidden = true
        store(record)
    }

    @discardableResult
    static func adopt(_ item: ContinueWatchingItem) -> Bool {
        guard item.updatedAt > 0, item.episode > 0 else { return false }
        if let existing = load(), item.updatedAt <= existing.updatedAt {
            return false
        }
        store(Record(
            id: item.id,
            title: item.title,
            cover: item.coverURL?.absoluteString,
            episode: item.episode,
            episodeCount: item.episodeCount,
            progress: item.progress,
            duration: item.duration,
            updatedAt: item.updatedAt,
            hidden: false
        ))
        return true
    }

    private static func load() -> Record? {
        guard let data = UserDefaults.standard.data(forKey: recordKey) else { return nil }
        return try? JSONDecoder().decode(Record.self, from: data)
    }

    private static func store(_ record: Record) {
        guard let data = try? JSONEncoder().encode(record) else { return }
        UserDefaults.standard.set(data, forKey: recordKey)
    }
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
