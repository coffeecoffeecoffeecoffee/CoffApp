import SwiftUI

struct StatusView: View {
    private var viewModel: StatusViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: viewModel.symbolName)
                .font(.largeTitle)
            Text(viewModel.headline)
                .bold()
            Text(viewModel.description)
                .multilineTextAlignment(.center)
        }
    }

    init(_ viewModel: StatusViewModel = .init()) {
        self.viewModel = viewModel
    }

    init(_ title: String, description: String, symbolName: String = "exclamationmark.triangle") {
        let viewmodel = StatusViewModel(headline: title,
                                 description: description,
                                 symbolName: symbolName)
        self.init(viewmodel)
    }
}

#if DEBUG
struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusView()
            let anotherModel = StatusViewModel(headline: "Yo dawg!",
                                               description: "Some error we got here",
                                               symbolName: "trash")
            StatusView(anotherModel)
        }
    }
}
#endif
