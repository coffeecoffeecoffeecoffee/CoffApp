import SwiftUI

struct AsyncImagePhaseView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let img):
                img.resizable()
                    .centerCropped()
            default:
                Image("coffee-\(Int.random(in: 1...10))")
                    .resizable()
                    .centerCropped()
            }
        }
    }

    init(_ url: URL?) {
        self.url = url
    }
}
