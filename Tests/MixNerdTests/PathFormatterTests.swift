import Testing

@testable import MixNerd

struct PathComponentTest {
  let input: String
  let expected: String
}

struct PathNamedComponentTest {
  let named: String
  let expected: String
}

struct PathFormatTest {
  let path: String
  let tracklist: Tracklist
  let expected: String
}

let pathComponentTests: [PathComponentTest] = [
  PathComponentTest(input: "Artist", expected: "Artist"),
  PathComponentTest(input: "Artist/Title", expected: "Artist_Title"),
  PathComponentTest(input: "///", expected: "___"),
  PathComponentTest(input: "A/B/C", expected: "A_B_C"),
  PathComponentTest(input: "Track:01", expected: "Track_01"),
  PathComponentTest(input: "Question?", expected: "Question_"),
  PathComponentTest(input: "Star*Power", expected: "Star_Power"),
  PathComponentTest(input: #"Quote"Test"#, expected: #"Quote_Test"#),
  PathComponentTest(input: "Pipe|Name", expected: "Pipe_Name"),
  PathComponentTest(input: "Less<More>", expected: "Less_More_"),
  PathComponentTest(input: "Back\\Slash", expected: "Back_Slash"),
  PathComponentTest(input: "Percent%Sign", expected: "Percent_Sign"),
]

let pathNamedComponentTests: [PathNamedComponentTest] = [
  PathNamedComponentTest(named: "artist", expected: "Artist"),
  PathNamedComponentTest(named: "year", expected: "2025"),
  PathNamedComponentTest(named: "unknown", expected: "{unknown}"),
]

func makeTracklist(artist: String, title: String, year: Int) -> Tracklist {
  var tracklist = Tracklist()
  tracklist.artist = artist
  tracklist.title = title
  tracklist.date = Date(year: year, month: 1, day: 1)
  return tracklist
}

let pathFormatTests: [PathFormatTest] = [
  PathFormatTest(
    path: "Path/{year}/{artist} - {title}",
    tracklist: makeTracklist(
      artist: "Armin van Buuren",
      title: "A State of Trance 368",
      year: 2025
    ),
    expected: "Path/2025/Armin van Buuren - A State of Trance 368"
  ),
  PathFormatTest(
    path: "{artist}",
    tracklist: makeTracklist(
      artist: "Artist/Name",
      title: "Title",
      year: 2025
    ),
    expected: "Artist_Name"
  ),
  PathFormatTest(
    path: "{year}-{title}",
    tracklist: makeTracklist(
      artist: "Artist",
      title: "Track:01",
      year: 2025
    ),
    expected: "2025-Track_01"
  ),
  PathFormatTest(
    path: "Literal path with no placeholders",
    tracklist: makeTracklist(
      artist: "Artist",
      title: "Title",
      year: 2025
    ),
    expected: "Literal path with no placeholders"
  ),
  PathFormatTest(
    path: "{unknown}",
    tracklist: makeTracklist(
      artist: "Artist",
      title: "Title",
      year: 2025
    ),
    expected: "{unknown}"
  ),
  PathFormatTest(
    path: "Unclosed {artist",
    tracklist: makeTracklist(
      artist: "Artist/Name",
      title: "Title",
      year: 2025
    ),
    expected: "Unclosed {artist"
  ),
]

@Test
func testTracklistFormatter_yearComponent_returnsYearString() {
  var tracklist = Tracklist()
  tracklist.date = Date(year: 2025, month: 11, day: 4)

  let formatter = TracklistFormatter()
  #expect(formatter.yearComponent(tracklist: tracklist) == "2025")
}

@Test
func testTracklistFormatter_artistComponent_returnsArtistString() {
  var tracklist = Tracklist()
  tracklist.artist = "Artist"

  let formatter = TracklistFormatter()
  #expect(formatter.artistComponent(tracklist: tracklist) == "Artist")
}

@Test(arguments: pathComponentTests)
func testTracklistFormatter_componentEscapedForPath(test: PathComponentTest) {
  let formatter = TracklistFormatter()
  #expect(formatter.componentEscapedForPath(component: test.input) == test.expected)
}

@Test(arguments: pathNamedComponentTests)
func testTracklistFormatter_componentNamed_returnsExpectedComponent(test: PathNamedComponentTest) {
  var tracklist = Tracklist()
  tracklist.artist = "Artist"
  tracklist.date = Date(year: 2025, month: 11, day: 4)

  let formatter = TracklistFormatter()
  #expect(formatter.component(named: test.named, tracklist: tracklist) == test.expected)
}

@Test(arguments: pathFormatTests)
func testTracklistFormatter_format_replacesNamedComponentsAndEscapes(test: PathFormatTest) {
  let formatter = TracklistFormatter()
  #expect(
    formatter.format(
      tracklist: test.tracklist, format: test.path, escapeForPath: true)
      == test.expected)
}
