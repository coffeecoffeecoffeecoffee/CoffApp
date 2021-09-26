import BackgroundTasks

final class BackgroundActivityController: NSObject, URLSessionDelegate {

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func registerBackgroundFetch() {
        guard RuntimeOS.current == .iOS else { return }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "science.pixel.brew", using: nil) { task in
            print("task", task)
        }
    }
}
