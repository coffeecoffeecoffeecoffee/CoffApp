import Combine
import SwiftUI
import Foundation

final class Groups: ObservableObject {
    @Published var groups: [Group] = []
    @Published var selectedGroupName: String?
    @Published var state: NetworkState = .loading

    var net = NetworkService()
    let defaults = UserDefaults.standard
    var tokens = Set<AnyCancellable>()

    init() {
        load()
        net.$groups
            .merge(with: self.$groups)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self = self else { return }
                self.state = .ready
                self.groups = groups
                self.selectedGroupName = UserDefaults.standard.string(forKey: UserDefaultKeys.selectedGroup.rawValue)
                self.save()
            }
            .store(in: &tokens)
        net.loadGroups()
    }
}

extension Groups {
    public func select(_ group: Group) {
        selectedGroupName = group.name
        save()
    }

    public func save() {
        if let data = try? PropertyListEncoder().encode(groups) {
            defaults.setValue(data, forKey: UserDefaultKeys.allGroups.rawValue)
        }
        defaults.setValue(selectedGroupName, forKey: UserDefaultKeys.selectedGroup.rawValue)
    }

    public func load() {
        if let saved = UserDefaults.standard.value(forKey: UserDefaultKeys.allGroups.rawValue) as? [Group] {
            self.groups = saved
        }

        selectedGroupName = UserDefaults.standard.string(forKey: UserDefaultKeys.selectedGroup.rawValue)
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
                self.selectedGroupName = nil
            }
        }
    }
}
