import SwiftUI

extension Image {
    #if os(macOS)
    #else
    func data(_ url: URL?) -> Self {
        guard let url = url else {
            return self
        }

        // First: Check Data(contentsOf:). Let the OS networking / memory cache work.
        guard let data = try? Data(contentsOf: url),
              let remoteImage = UIImage(data: data) else {

            // If the network fails then check the disk cache
            if let cachedData = ImageCache.fetchData(for: url),
               let cachedImage = UIImage(data: cachedData) {
                return Image(uiImage: cachedImage)
            }

            return self
        }

        // Save cache
        ImageCache.save(data, for: url)

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
