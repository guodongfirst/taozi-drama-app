import BUAdSDK
import UIKit

enum RewardedScene {
    case dramaUnlock
    case checkInExtra
    case watchTask
    case watchCash

    var slotID: String {
        switch self {
        case .dramaUnlock:
            "104756908"
        case .checkInExtra:
            "104756631"
        case .watchTask:
            "104756493"
        case .watchCash:
            "104754882"
        }
    }
}

enum PangleAds {
    static let appID = "5857460"
    private static var didStart = false
    private static var ready = false

    static func start(completion: @escaping (Bool) -> Void) {
        if ready {
            completion(true)
            return
        }
        guard !didStart else { return }
        didStart = true

        let configuration = BUAdSDKConfiguration()
        configuration.appID = appID
        configuration.useMediation = true
        configuration.mediation.limitPersonalAds = NSNumber(integerLiteral: 0)
        configuration.mediation.limitProgrammaticAds = NSNumber(integerLiteral: 0)
        configuration.themeStatus = NSNumber(integerLiteral: 0)
        BUAdSDKManager.start(asyncCompletionHandler: { success, _ in
            DispatchQueue.main.async {
                ready = success
                if !success {
                    didStart = false
                }
                completion(success)
            }
        })
    }
}

private enum AdRoot {
    static var viewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}

final class SplashAd: NSObject, BUSplashAdDelegate {
    static let shared = SplashAd()
    static let slotID = "104754896"

    private var ad: BUSplashAd?
    private var onFinish: (() -> Void)?
    private var allowShow = false
    private var loaded = false
    private var didFinish = false

    func prepare() {
        allowShow = false
        loaded = false
        didFinish = false
    }

    func load(completion: @escaping () -> Void) {
        onFinish = completion
        let slot = BUAdSlot()
        slot.id = Self.slotID
        let size = AdRoot.viewController?.view.bounds.size ?? CGSize(width: 390, height: 844)
        let splash = BUSplashAd(slot: slot, adSize: size)
        splash.delegate = self
        splash.tolerateTimeout = 3
        ad = splash
        splash.loadData()
    }

    func allowShowAfterBrand() {
        allowShow = true
        showIfReady()
    }

    func splashAdLoadSuccess(_ splashAd: BUSplashAd) {
        loaded = true
        showIfReady()
    }

    func splashAdLoadFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        finish()
    }

    func splashAdRenderSuccess(_ splashAd: BUSplashAd) {}

    func splashAdRenderFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        finish()
    }

    func splashAdWillShow(_ splashAd: BUSplashAd) {}

    func splashAdDidShow(_ splashAd: BUSplashAd) {}

    func splashAdDidClick(_ splashAd: BUSplashAd) {}

    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        finish()
    }

    func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        finish()
    }

    func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {}

    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error?) {}

    private func showIfReady() {
        guard allowShow, loaded, let ad, let controller = AdRoot.viewController else { return }
        loaded = false
        ad.showSplashView(inRootViewController: controller)
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        ad?.mediation?.destoryAd()
        ad = nil
        let completion = onFinish
        onFinish = nil
        completion?()
    }
}

final class FeedExpress: NSObject, BUMNativeExpressAdViewDelegate, BUCustomEventProtocol {
    static let slotID = "104756516"

    private var manager: BUNativeExpressAdManager?
    private var onFinish: ((UIView?) -> Void)?

    func load(
        width: CGFloat,
        from viewController: UIViewController,
        completion: @escaping (UIView?) -> Void
    ) {
        onFinish?(nil)
        onFinish = completion
        let slot = BUAdSlot()
        slot.id = Self.slotID
        slot.mediation.mutedIfCan = true
        let manager = BUNativeExpressAdManager(slot: slot, adSize: CGSize(width: width, height: 0))
        manager.delegate = self
        manager.mediation?.rootViewController = viewController
        self.manager = manager
        manager.loadAdData(withCount: 1)
    }

    func nativeExpressAdSuccess(toLoad nativeExpressAdManager: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        guard let view = views.first else {
            finish(nil)
            return
        }
        view.render()
    }

    func nativeExpressAdFail(toLoad nativeExpressAdManager: BUNativeExpressAdManager, error: Error?) {
        finish(nil)
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        finish(nativeExpressAdView)
    }

    func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        finish(nil)
    }

    private func finish(_ view: UIView?) {
        let completion = onFinish
        onFinish = nil
        completion?(view)
    }
}

final class RewardedVideo: NSObject, BUMNativeExpressRewardedVideoAdDelegate {
    static let shared = RewardedVideo()

    private var ad: BUNativeExpressRewardedVideoAd?
    private var presenter: UIViewController?
    private var onFinish: ((Bool) -> Void)?
    private var rewarded = false

    func show(
        _ scene: RewardedScene,
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        finish(verified: false)
        presenter = viewController
        onFinish = completion
        rewarded = false

        let slot = BUAdSlot()
        slot.id = scene.slotID
        slot.mediation.mutedIfCan = false
        let rewardedVideoModel = BURewardedVideoModel()
        let rewardedVideoAd = BUNativeExpressRewardedVideoAd(slot: slot, rewardedVideoModel: rewardedVideoModel)
        rewardedVideoAd.delegate = self
        rewardedVideoAd.mediation?.addParam(NSNumber(value: 0), withKey: "show_direction")
        ad = rewardedVideoAd
        rewardedVideoAd.loadData()
    }

    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard let presenter else { return }
        if rewardedVideoAd.show(fromRootViewController: presenter) == false {
            finish(verified: false)
        }
    }

    func nativeExpressRewardedVideoAd(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        didFailWithError error: Error?
    ) {
        finish(verified: false)
    }

    func nativeExpressRewardedVideoAdDidShowFailed(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        error: Error
    ) {
        finish(verified: false)
    }

    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        finish(verified: rewarded)
    }

    func nativeExpressRewardedVideoAdServerRewardDidSucceed(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        verify: Bool
    ) {
        if verify {
            rewarded = true
        }
    }

    private func finish(verified: Bool) {
        let completion = onFinish
        onFinish = nil
        presenter = nil
        ad = nil
        rewarded = false
        completion?(verified)
    }
}
