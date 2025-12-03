import Foundation

class URLFile {
  static func write(url: URL, to file: URL) {
    // Write a standard Internet Shortcut (.url) file which is understood by both
    // Windows and macOS Finder.
    //
    // Example:
    // [InternetShortcut]
    // URL=https://example.com/
    let content = """
      [InternetShortcut]
      URL=\(url.absoluteString)
      """

    try? content.write(to: file, atomically: true, encoding: .utf8)
  }
}
