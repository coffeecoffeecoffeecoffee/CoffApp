import XCTest
@testable import CoffApp

final class TestURLAppURLSs: XCTestCase {
    func testBaseURL() {
        XCTAssertNotNil(URL.baseURL)
        XCTAssertNoThrow(URL.baseURL)
    }

    func testAppURLWithComponents() {
        let urlWithComponenets = URL.appURL(with: "some", "path", "components")
        let baseURLPath = URL.baseURL.path
        let testPath = baseURLPath.appending("/some/path/components")
        XCTAssertEqual(urlWithComponenets.path, testPath)
    }
}
