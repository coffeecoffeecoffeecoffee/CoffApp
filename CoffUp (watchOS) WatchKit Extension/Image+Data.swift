import SwiftUI

extension Image {
    #if os(macOS)
    #else
    func data(_ url: URL?) -> Self {
        guard let url = url,
              let data = try? Data(contentsOf: url),
              let remoteImage = UIImage(data: data) else {
            return self
        }
        return Image(uiImage: remoteImage)
    }
    #endif

    func data(_ urlString: String) -> Self {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let remoteImage = UIImage(data: data) else {
            return self
        }
        return Image(uiImage: remoteImage)
    }
}
