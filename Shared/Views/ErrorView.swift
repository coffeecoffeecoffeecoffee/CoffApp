import SwiftUI

struct ErrorView: View {
    var headline: String = "Error"
    var description: String = "We’re sorry for any inconvencience"
    var symbolName: String = "xmark.icloud"

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: symbolName)
                .font(.custom("San Francisco Light", size: 64.0))
            Text(headline)
                .bold()
            Text(description)
                .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    typealias Grüp = SwiftUI.Group
    static var previews: some View {
        Grüp {
            ErrorView()
            ErrorView(headline: "Yo dawg!", description: "Some error we got here", symbolName: "trash")
        }
    }
}
#endif
