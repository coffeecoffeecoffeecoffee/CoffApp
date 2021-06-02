import Combine

final class FocusState: ObservableObject {
    @Published var inFocus: Bool = false

    func toggleFocus(_ shouldFocus: Bool? = nil) {
        print("toggleFocus()")
        if let shouldFocus = shouldFocus {
            self.inFocus = shouldFocus
        } else {
            self.inFocus.toggle()
        }
    }
}
