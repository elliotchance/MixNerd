class TitleParser {
  func parseTitle(title: String) -> String {
    let lastSpaceIndex = title.lastIndex(of: " ")!
    return String(title[..<lastSpaceIndex])
  }

  func parseDate(title: String) -> String {
    let lastSpaceIndex = title.lastIndex(of: " ")!
    let dateStartIndex = title.index(after: lastSpaceIndex)
    return String(title[dateStartIndex...])
  }
}
