import Combine
import SwiftUI
import Foundation

final class Groups: ObservableObject {
    @Published var groups: [InterestGroup] = []
    @Published var selectedGroupName: String?
    @Published var selectedGroup: InterestGroup?
    @Published var state: NetworkState = .loading

    var net = NetworkService()
    let defaults = UserDefaults.standard
    var tokens = Set<AnyCancellable>()

    init() {
        let selectedGroupName = UserDefaults.sharedSuite
            .string(forKey: UserDefaultKeys.selectedGroup.rawValue)
        self.selectedGroupName = selectedGroupName
        net.$groups
            .merge(with: self.$groups)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self = self else { return }
                self.state = .ready
                self.groups = groups
                self.selectedGroupName = self.selectedGroupName
            }
            .store(in: &tokens)
        net.loadGroups()
    }
}

// MARK: - Selected Group Persistance
extension Groups {
    /// Sets and saves the current Group
    /// - Parameter groupName: the name of the group to save
    public func select(_ groupName: String) {
        selectedGroupName = groupName
        let selectedGroup = groups.first {
            $0.name == groupName
        }
        selectedGroup?.setSelected()
    }

    /// Binding owned by this Type that accepts user input for the currently selected group
    /// - Parameter name: Name of a `Group`
    /// - Returns: `Binding<Bool>` fit to idenitify the selected group
    func selectionBinding(for name: String) -> Binding<Bool> {
        Binding<Bool> { () -> Bool in
            self.selectedGroupName == name
        } set: { newValue in
            if newValue {
                self.select(name)
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
