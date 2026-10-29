import SwiftUI
import PangrowthDJX

struct DramaPlayerView: UIViewControllerRepresentable {
    let route: DramaRoute

    func makeUIViewController(context: Context) -> UIViewController {
        WatchedDramas.mark(route.id)
        let config = DJXPlayletConfig()
        config.skitId = Int(route.id)
        config.episode = 1
        config.playletUnlockADMode = .common
        config.entranceType = .home
        config.freeEpisodesCount = Self.freeCount(route.episodeCount)
        config.unlockEpisodesCountUsingAD = 10
        config.hideBackButton = false
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
