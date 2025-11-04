import Testing
@testable import MixNerd

let parserTests: [[String: String]] = [
    [
        "input": "Silvio Carrano - Total Freedom 419 2025-11-04",
        "title": "Silvio Carrano - Total Freedom 419",
        "date": "2025-11-04",
    ],
]

@Test
func testParseTitle() {
    let parser = TitleParser()
    for test in parserTests {
        let result = parser.parseTitle(title: test["input"]!)
        #expect(result == test["title"]!)
    }
}

@Test
func testParseDate() {
    let parser = TitleParser()
    for test in parserTests {
        let result = parser.parseDate(title: test["input"]!)
        #expect(result == test["date"]!)
    }
}
