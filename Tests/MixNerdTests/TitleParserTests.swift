import Testing
@testable import MixNerd

let parserTests: [[String: String]] = [
    [
        "input": "Silvio Carrano - Total Freedom 419 2025-11-04",
        "artist": "Silvio Carrano",
        "title": "Total Freedom 419",
        "date": "2025-11-04",
    ],
    [
        "input": "Menno De Jong @ A State Of Trance Festival 300, Pettelaarse Schans, Den Bosch, Netherlands 2007-05-17",
        "artist": "Menno De Jong",
        "title": "A State Of Trance Festival 300, Pettelaarse Schans, Den Bosch, Netherlands",
        "date": "2007-05-17",
    ],
]

@Test(arguments: parserTests)
func testParseArtist(test: [String: String]) {
    let parser = TitleParser()
    let result = parser.parseArtist(test["input"]!)
    #expect(result == test["artist"]!)
}

@Test(arguments: parserTests)
func testParseTitle(test: [String: String]) {
    let parser = TitleParser()
    let result = parser.parseTitle(test["input"]!)
    #expect(result == test["title"]!)
}

@Test(arguments: parserTests)
func testParseDate(test: [String: String]) {
    let parser = TitleParser()
    let result = parser.parseDate(test["input"]!)
    #expect(result == test["date"]!)
}
