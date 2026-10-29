import Foundation
import PangrowthDJX

enum PangleContent {
    private static let authority = ContentAuthority()
    private static var ready = false
    private static var starting = false
    private static var waiters: [(Bool) -> Void] = []

    static func start(completion: @escaping (Bool) -> Void) {
        if ready {
            completion(true)
            return
        }
        waiters.append(completion)
        guard !starting else { return }
        starting = true

        let config = DJXConfig()
        config.authorityDelegate = authority
        #if DEBUG
        config.logLevel = .debug
        #endif
        let path = Bundle.main.path(forResource: "SDK_Setting_5857460", ofType: "json") ?? ""
        print("[短剧] 配置 \(path.isEmpty ? "缺失" : "已找到")")
        DJXManager.initialize(withConfigPath: path, config: config)
        DJXManager.start { status, info in
            let message = info["msg"] ?? ""
            let code = info["error_code"] ?? ""
            print("[短剧] 启动 \(status) \(code) \(message)")
            DispatchQueue.main.async {
                ready = status
                if !status {
                    starting = false
                }
                let callbacks = waiters
                waiters.removeAll()
                callbacks.forEach { $0(status) }
            }
        }
    }

    static func whenReady(_ completion: @escaping (Bool) -> Void) {
        if ready {
            completion(true)
            return
        }
        start(completion: completion)
    }
}

private final class ContentAuthority: NSObject, DJXAuthorityConfigDelegate {
    func allowAccessIDFA() -> Bool { false }
    func turnOnTeenMode() -> Bool { false }
    func isOnlyICPNumber() -> Bool { false }
}
