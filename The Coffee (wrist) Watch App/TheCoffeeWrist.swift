import Logging
import SwiftUI

@main
struct TheCoffeeWrist: App {
    private let net = NetworkService()
    @State var profile: UserProfile
    let logger = Logger(label: "TheCoffeeWrist")
    @State private var showGroups: Bool = false
    @State private var path = NavigationPath()
    
    init() {
        self.profile = .init(net: net)
    }

    var body: some Scene {
        WindowGroup {
            GeometryReader { _ in // TODO: Remove
                NavigationStack(path: $path) {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            Button("Groups") {
                                showGroups.toggle()
                            }
                            .zIndex(100)
                            ForEach(profile.events, id: \.id) { event in
                                ZStack(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.3))
                                        .frame(height: 150)
                                    VStack(alignment: .leading) {
                                        if let eventImageURL = event.imageURL {
                                            AsyncImagePhaseView(eventImageURL)
                                                .frame(height: 100)
                                                .clipped()
                                        }
                                        VStack(alignment: .leading) {
                                            Text(event.venue.name)
                                                .bold()
                                            Text(event.localizedStartTime(.short))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 10)
                                        .onTapGesture {
                                            event.venue.getDirections()
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(height: 150)
                                .cornerRadius(10)
                            }
                        }
                        .sheet(isPresented: $showGroups) {
                            VStack {
                                Button("Done") {
                                    showGroups.toggle()
                                }
                                GroupListView(net: net)
                            }
                        }
                    }
                }
                .task {
                    do {
                        try await profile.sync()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}
