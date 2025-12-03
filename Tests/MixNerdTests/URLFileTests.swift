import Foundation
import Testing

@testable import MixNerd

@Test
func testURLFileWrite() async throws {
  let url = URL(string: "https://example.com/")!
  let tempDirectory = FileManager.default.temporaryDirectory
  let fileURL = tempDirectory.appendingPathComponent("test-urlfile.url")

  URLFile.write(url: url, to: fileURL)

  let contents = try String(contentsOf: fileURL, encoding: .utf8)
  #expect(contents == "[InternetShortcut]\nURL=https://example.com/")
}
