import SwiftUI

struct RoundFilledButtonStyle: ButtonStyle {
    var color: Color = .blue

    public func makeBody(configuration: Self.Configuration) -> some View {
        BigButton(configuration: configuration, color: color)
    }

    struct BigButton: View {
        let configuration: RoundFilledButtonStyle.Configuration
        let color: Color

        var body: some View {
            configuration.label
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 40).fill(color))
                .compositingGroup()
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }

}

#if DEBUG
struct BigButton_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {
            print("Yo!")
        }, label: {
            HStack {
                Image(systemName: "plus.message.fill")
                Text("Button Title")
            }
        })
        .buttonStyle(RoundFilledButtonStyle(color: .blue))
    }
}
#endif
