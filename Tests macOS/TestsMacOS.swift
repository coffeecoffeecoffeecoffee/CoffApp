import XCTest

class TestsMacOS: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the
        // initial state - such as interface orientation - required
        // for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppLaunchUI() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let window = XCUIApplication().windows.firstMatch
        XCTAssert(window.staticTexts["Choose a group"].exists)
        XCTAssert(window.toolbars.buttons["split view horizontally left"].exists)
//        XCTAssert(window.outlines.buttons["SF iOS Coffee"].exists)
    }

    #if TEST_PERFORMANCE
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    #endif
}
