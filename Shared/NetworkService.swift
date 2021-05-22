import Combine
import Foundation
import Logging

final class NetworkService: ObservableObject {
    @Published var groups = [Group]()
    @Published var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.description
                                    .appending(".loggers"))
    private var subscribers = Set<AnyCancellable>()
    private var session = URLSession.shared
    private var decoder = JSONDecoder()

    private let groupURL = URL(string: "https://coffeecoffeecoffee.coffee/api/groups/")!

    func cancelAll() {
        subscribers.removeAll()
    }

    func loadGroups() {
        netState = .loading
        session.dataTaskPublisher(for: groupURL)
            .retry(5)
            .map { $0.data }
            .decode(type: [Group].self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    self.logger.critical("Network Error \n\(error.localizedDescription)")
                    self.netState = .failed(error)
                case .finished:
                    self.logger.debug("Group Fetch Complete")
                    self.netState = .ready
                }
            } receiveValue: { netGroups in
                self.logger.debug("fetched groups \n\(netGroups.count)")
                self.groups = netGroups
            }
            .store(in: &subscribers)
    }

    init() {
        print(Bundle.main.description)
        loadGroups()
    }
}
