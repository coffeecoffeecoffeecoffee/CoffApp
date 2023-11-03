import Logging
import SwiftUI

@main
struct TheCoffeeWrist: App {
    @StateObject var profile = UserProfile()
    let logger = Logger(label: "TheCoffeeWrist")
    @State private var showGroups: Bool = false
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            GeometryReader { _ in
                NavigationStack(path: $path) {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            Button("Groups") {
                                showGroups.toggle()
                            }
                            .zIndex(100)
                            ForEach(profile.events) { event in
                                ZStack(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.3))
                                        .frame(height: 150)
                                    VStack(alignment: .leading) {
                                        AsyncImagePhaseView(event.imageURL)
                                            .frame(height: 100)
                                            .clipped()
                                        VStack(alignment: .leading) {
                                            Text(event.venueName)
                                                .bold()
                                            Text(event.localizedStartTime(.short))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 10)
                                        .onTapGesture {
                                            event.venue?.getDirections()
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
                                GroupListView()
                                    .environmentObject(profile)
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
