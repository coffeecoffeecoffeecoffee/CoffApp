import Combine
import SwiftUI
import Foundation

final class Groups: ObservableObject {
    @Published var groups: [Group] = []
    @AppStorage("selectedGroupName") var selectedGroupName = ""
    @Published var state: NetworkState = .loading

    var net = NetworkService()
    let defaults = UserDefaults.standard
    var tokens = Set<AnyCancellable>()

    init() {
        net.$groups
            .merge(with: self.$groups)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self = self else { return }
                self.state = .ready
                self.groups = groups
            }
            .store(in: &tokens)
        net.loadGroups()
    }
}

extension Groups {
    public func select(_ group: Group) {
        selectedGroupName = group.name
    }
}

extension Groups {
    func selectionBinding(for name: String) -> Binding<Bool> {
        Binding<Bool> { () -> Bool in
            self.selectedGroupName == name
        } set: { newValue in
            if newValue {
                self.selectedGroupName = name
            } else {
                #if os(iOS)
                // not necessary for anything other than iOS
                // and macOS in particular has a bug for
                // navigation view selection
                self.selectedGroupName = ""
                #endif
            }
        }
    }
}
