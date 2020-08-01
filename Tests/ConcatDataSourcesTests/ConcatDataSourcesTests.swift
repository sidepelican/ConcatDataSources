import XCTest
@testable import ConcatDataSources

final class ConcatDataSourcesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ConcatDataSources().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
