import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("桃子小剧")
                    .font(.largeTitle)
                Text("Taozi Short Drama")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationTitle("桃子小剧")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
