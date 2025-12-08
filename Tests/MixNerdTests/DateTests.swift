import Testing

@testable import MixNerd

struct DateTest {
  let dateString: String
  let year: Int
  let month: Int
  let day: Int
  let description: String
}

let dateTests: [DateTest] = [
  DateTest(dateString: "2025-11-04", year: 2025, month: 11, day: 4, description: "2025-11-04"),
  DateTest(dateString: "2025-1-5", year: 2025, month: 1, day: 5, description: "2025-01-05"),
  DateTest(dateString: "2025-01-05", year: 2025, month: 1, day: 5, description: "2025-01-05"),
  DateTest(dateString: "2024-02-29", year: 2024, month: 2, day: 29, description: "2024-02-29"),
  DateTest(dateString: "2025-01-01", year: 2025, month: 1, day: 1, description: "2025-01-01"),

  // Spaces
  DateTest(dateString: "  2025-11-04 ", year: 2025, month: 11, day: 4, description: "2025-11-04"),
  DateTest(dateString: " 2023", year: 2023, month: 0, day: 0, description: "2023"),

  // Year only
  DateTest(dateString: "2021-00-00", year: 2021, month: 0, day: 0, description: "2021"),
  DateTest(dateString: "2025", year: 2025, month: 0, day: 0, description: "2025"),

  // Invalid date strings
  DateTest(dateString: "2025-01-01-07", year: 0, month: 0, day: 0, description: ""),
  DateTest(dateString: "", year: 0, month: 0, day: 0, description: ""),
  DateTest(dateString: "foo", year: 0, month: 0, day: 0, description: ""),
  DateTest(dateString: "1-1-1", year: 0, month: 0, day: 0, description: ""),
  DateTest(dateString: "2250", year: 0, month: 0, day: 0, description: ""),
  DateTest(dateString: "1778-03-04", year: 0, month: 0, day: 0, description: ""),
]

@Test(arguments: dateTests)
func testDate_fromString(test: DateTest) {
  let date = Date(fromString: test.dateString)
  #expect(date.year == test.year)
  #expect(date.month == test.month)
  #expect(date.day == test.day)
}

@Test(arguments: dateTests)
func testDate_description(test: DateTest) {
  let date = Date(year: test.year, month: test.month, day: test.day)
  #expect(date.description == test.description)
}
