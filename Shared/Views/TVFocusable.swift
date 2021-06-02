import SwiftUI

struct TVFocusable<Content: View>: View {
    let content: Content
    @ObservedObject var focusState: FocusState

    init(_ bindingValue: FocusState, @ViewBuilder content: () -> Content) {
        self.focusState = bindingValue
        self.content = content()
    }

    var body: some View {
        #if os(tvOS)
        return content
            .focusable(true) { inFocus in
                withAnimation {
                    focusState.toggleFocus(inFocus)
                }
            }
        #else
            return content
        #endif
    }
}

