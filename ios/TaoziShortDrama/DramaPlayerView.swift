import SwiftUI
import PangrowthDJX

struct DramaPlayerView: UIViewControllerRepresentable {
    let route: DramaRoute

    func makeCoordinator() -> Coordinator {
        Coordinator(route: route)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        WatchedDramas.mark(route.id)
        let config = DJXPlayletConfig()
        config.skitId = Int(route.id)
        config.episode = max(route.episode, 1)
        if route.startTime > 0 {
            config.playStartTime = route.startTime
        }
        config.playletUnlockADMode = .common
        config.entranceType = .home
        config.freeEpisodesCount = Self.freeCount(route.episodeCount)
        config.unlockEpisodesCountUsingAD = 10
        config.hideBackButton = false
        config.playerDelegate = context.coordinator
        if let model = PangleDramaCatalog.shared.model(for: route.id) {
            config.infoModel = model
        }
        return DJXPlayletManager.shareInstance().playletViewController(withParams: config)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private static func freeCount(_ total: Int) -> Int {
        guard total > 0 else { return 1 }
        let percent = Int((Double(total) * 0.2).rounded())
        return min(20, max(1, percent))
    }
}

extension DramaPlayerView {
    final class Coordinator: NSObject, DJXPlayletPlayerProtocol {
        let route: DramaRoute

        init(route: DramaRoute) {
            self.route = route
        }

        func drawVideoStartPlay(_ viewController: UIViewController, config: DJXPlayletInfoModel) {
            remember(config, progress: nil)
        }

        func drawVideoOverPlay(_ viewController: UIViewController, config: DJXPlayletInfoModel) {
            remember(config, progress: nil)
        }

        func drawVideoPause(_ viewController: UIViewController, config: DJXPlayletInfoModel) {
            remember(config, progress: nil)
        }

        func drawVideoContinue(_ viewController: UIViewController, config: DJXPlayletInfoModel) {
            remember(config, progress: nil)
        }

        func drawVideoPlayCompletion(_ viewController: UIViewController, config: DJXPlayletInfoModel) {
            remember(config, progress: 1)
        }

        func onVideSeek(toTime endTime: TimeInterval, inPosition position: Int) {}

        func drawVideo(_ viewController: UIViewController, config: DJXPlayletInfoModel, progress: CGFloat) {
            guard let fraction = Self.fraction(progress, duration: config.video_duration) else { return }
            let duration = config.video_duration > 0 ? Double(config.video_duration) : nil
            ContinueWatching.noteProgress(fraction, duration: duration, id: Int64(config.shortplay_id))
        }

        func drawVideoError(_ viewController: UIViewController, config: DJXPlayletInfoModel) {}

        private func remember(_ model: DJXPlayletInfoModel, progress: CGFloat?) {
            let id = Int64(model.shortplay_id)
            guard id > 0 else { return }
            let episode = model.current_episode > 0 ? Int(model.current_episode) : max(route.episode, 1)
            ContinueWatching.remember(
                id: id,
                title: model.title.isEmpty ? route.title : model.title,
                coverURL: URL(string: model.cover_image),
                episode: episode,
                episodeCount: model.total > 0 ? Int(model.total) : route.episodeCount,
                progress: Self.fraction(progress, duration: model.video_duration),
                duration: model.video_duration > 0 ? Double(model.video_duration) : nil
            )
        }

        private static func fraction(_ progress: CGFloat?, duration: CGFloat) -> Double? {
            guard let progress, progress.isFinite, progress > 0 else { return nil }
            if progress <= 1 {
                return Double(progress)
            }
            guard duration > 0 else { return nil }
            if progress <= duration * 1.2 {
                return min(1, Double(progress / duration))
            }
            let millis = duration * 1000
            if progress <= millis * 1.2 {
                return min(1, Double(progress / millis))
            }
            return nil
        }
    }
}
