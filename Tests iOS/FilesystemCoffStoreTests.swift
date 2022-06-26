//
//  FilesystemCoffStoreTests.swift
//  Tests iOS
//
//  Created by Brennan Stehling on 10/31/21.
//

import XCTest
@testable import CoffApp

class FilesystemCoffStoreTests: XCTestCase {

    var temporaryRootDirectoryURL: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let storeDirectoryURL = paths[0].appendingPathComponent(UUID().uuidString, isDirectory: true)
        return storeDirectoryURL
    }

    var sut: FilesystemCoffStore!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = FilesystemCoffStore(rootDirectoryURL: temporaryRootDirectoryURL)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testLoadingSelectedInterestGroupWithoutFile() throws {
        let exp = expectation(description: #function)
        var result: Result<InterestGroup?, Error>?
        sut.loadSelectedInterestGroup {
            result = $0
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        XCTAssertNotNil(result)
        guard let result = result else {
            XCTFail("Result is required")
            return
        }
        do {
            let selectedInterestGroup = try result.get()
            XCTAssertNil(selectedInterestGroup)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testLoadingEventsWithoutFile() throws {
        let exp = expectation(description: #function)
        var result: Result<Events, Error>?
        sut.loadEvents {
            result = $0
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        XCTAssertNotNil(result)
        guard let result = result else {
            XCTFail("Result is required")
            return
        }
        do {
            let events = try result.get()
            XCTAssertNotNil(events)
            XCTAssertTrue(events.isEmpty)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
