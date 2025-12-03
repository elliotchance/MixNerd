public class TitleParser {
  let pattern = #/(.*) [@-] (.*) (\d{4}-\d{2}-\d{2})/#

  public func parseArtist(_ title: String) -> String {
    if let match = try? pattern.firstMatch(in: title) {
      return String(match.1)
    }
    return ""
  }

  public func parseTitle(_ title: String) -> String {
    if let match = try? pattern.firstMatch(in: title) {
      return String(match.2)
    }
    return ""
  }

  public func parseDate(_ title: String) -> Date {
    if let match = try? pattern.firstMatch(in: title) {
      return Date(fromString: String(match.3))
    }
    return Date()
  }
}
