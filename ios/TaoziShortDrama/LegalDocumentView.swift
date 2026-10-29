import SwiftUI

enum LegalDocument: Hashable {
    case userAgreement
    case privacyPolicy

    var title: String {
        switch self {
        case .userAgreement:
            "用户协议"
        case .privacyPolicy:
            "隐私政策"
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        VStack(spacing: 16) {
            TaoziFont.text("\(document.title)暂时无法加载", style: .body, weight: .semibold)
                .multilineTextAlignment(.center)
            Button("重新加载", action: {})
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalDocumentView(document: .privacyPolicy)
    }
}
