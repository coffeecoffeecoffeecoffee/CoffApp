import SwiftUI

struct AsyncImagePhaseView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url,
                   transaction: .init(animation: .easeIn(duration: 0.7))) { phase in
            switch phase {
            case .success(let img):
                img.resizable()
                    .centerCropped()
                    .transition(.opacity)
            default:
                Image("coffee-\(Int.random(in: 1...10))")
                    .resizable()
                    .centerCropped()
                    .transition(.opacity)
            }
        }
    }

    init(_ url: URL?) {
        self.url = url
    }
}
