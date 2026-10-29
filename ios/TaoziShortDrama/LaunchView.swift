import SwiftUI
import UIKit

struct LaunchView: View {
    @AppStorage("privacyConsentVersion") private var privacyConsentVersion = ""
    @State private var didFinishLoading = false
    @State private var progress = 0.0
    @State private var legalPath = NavigationPath()

    private var needsConsent: Bool {
        privacyConsentVersion != PrivacyConsent.version
    }

    var body: some View {
        if didFinishLoading {
            ContentView()
        } else {
            NavigationStack(path: $legalPath) {
                splash
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: LegalDocument.self) { document in
                        LegalDocumentView(document: document)
                    }
            }
            .task(id: needsConsent) {
                await runLoading()
            }
        }
    }

    private var splash: some View {
        ZStack {
            Image("splash-background")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                VStack(spacing: 18) {
                    Text("桃子小剧")
                        .font(.custom("MaShanZheng-Regular", size: 48, relativeTo: .largeTitle))
                        .tracking(3.2)
                    Text("好剧开场，桃你喜欢")
                        .font(.custom("MaShanZheng-Regular", size: 30, relativeTo: .title))
                        .tracking(2)
                }
                .shadow(color: Color(red: 107 / 255, green: 18 / 255, blue: 20 / 255).opacity(0.2), radius: 2.5, y: 2)
                .padding(.top, 172)
                Spacer(minLength: 0)
                loadingStatus
                    .padding(.bottom, 108)
            }
            .foregroundStyle(.white)

            if needsConsent {
                PrivacyConsentDialog(
                    onAgree: PrivacyConsent.accept,
                    onDisagree: closeApp,
                    onOpen: { legalPath.append($0) }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingStatus: some View {
        VStack(spacing: 0) {
            Text("正在为你准备今日好剧")
                .font(.caption.weight(.bold))
            loadingBar
                .padding(.top, 8)
            Text("\(Int((progress * 100).rounded()))%")
                .font(.caption2.weight(.semibold))
                .padding(.top, 7)
        }
        .opacity(needsConsent ? 0 : 1)
        .accessibilityHidden(needsConsent)
    }

    private var loadingBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.28))
                Capsule()
                    .fill(.white)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(width: 239, height: 6)
    }

    private func runLoading() async {
        guard !needsConsent else {
            progress = 0
            return
        }
        SplashAd.shared.prepare()
        let splash = Task { await waitForSplash() }
        let duration = 1.6
        let start = Date()
        while !Task.isCancelled {
            let value = min(Date().timeIntervalSince(start) / duration, 1)
            progress = value
            if value >= 1 {
                break
            }
            do {
                try await Task.sleep(for: .milliseconds(32))
            } catch {
                return
            }
        }
        guard !Task.isCancelled else { return }
        SplashAd.shared.allowShowAfterBrand()
        await splash.value
        guard !Task.isCancelled else { return }
        didFinishLoading = true
    }

    private func waitForSplash() async {
        await withCheckedContinuation { continuation in
            PangleAds.start { success in
                guard success else {
                    continuation.resume()
                    return
                }
                PangleContent.start { _ in
                    SplashAd.shared.load {
                        continuation.resume()
                    }
                }
            }
        }
    }

    private func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            exit(0)
        }
    }
}

#Preview {
    LaunchView()
}
