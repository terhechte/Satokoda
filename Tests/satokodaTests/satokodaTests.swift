import XCTest
@testable import satokoda

final class satokodaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(satokoda().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
