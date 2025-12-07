import Foundation

class TracklistFormatter {
  /// Formats a string containing named components. For example:
  /// "Path/{year}/{artist} - {title}" -> "Path/2025/Armin van Buuren - A State of Trance 368"
  func format(tracklist: Tracklist, format: String, escapeForPath: Bool = false) -> String {
    var result = ""
    var currentName = ""
    var isInPlaceholder = false

    for character in format {
      if character == "{" {
        if isInPlaceholder {
          // Nested `{` – treat the previous `{` and collected name as literal.
          result.append("{")
          result.append(currentName)
          currentName = ""
        }

        isInPlaceholder = true
        continue
      }

      if character == "}" && isInPlaceholder {
        let componentValue = component(named: currentName, tracklist: tracklist)
        result.append(
          escapeForPath ? componentEscapedForPath(component: componentValue) : componentValue)

        currentName = ""
        isInPlaceholder = false
        continue
      }

      if isInPlaceholder {
        currentName.append(character)
      } else {
        result.append(character)
      }
    }

    // If we ended while still inside a placeholder, treat it as literal text.
    if isInPlaceholder {
      result.append("{")
      result.append(currentName)
    }

    return result
  }

  func yearComponent(tracklist: Tracklist) -> String {
    return String(tracklist.date.year)
  }

  func dateComponent(tracklist: Tracklist) -> String {
    return tracklist.date.description
  }

  func artistComponent(tracklist: Tracklist) -> String {
    return tracklist.artist
  }

  func titleComponent(tracklist: Tracklist) -> String {
    return tracklist.title
  }

  func sourceComponent(tracklist: Tracklist) -> String {
    return tracklist.source
  }

  func shortLinkComponent(tracklist: Tracklist) -> String {
    return tracklist.shortLink?.absoluteString ?? ""
  }

  func genreComponent(tracklist: Tracklist) -> String {
    return tracklist.genre
  }

  /// Escapes a component for use in a path.
  /// Unsafe characters are replaced with an underscore.
  func componentEscapedForPath(component: String) -> String {
    let unsafeCharacters = CharacterSet(charactersIn: "/\\\\:?%*|\"<>")

    return component.unicodeScalars
      .map { unsafeCharacters.contains($0) ? "_" : String($0) }
      .joined()
  }

  func component(named: String, tracklist: Tracklist) -> String {
    switch named {
    case "artist":
      return tracklist.artistComponent
    case "date":
      return dateComponent(tracklist: tracklist)
    case "genre":
      return tracklist.genreComponent
    case "shortLink":
      return shortLinkComponent(tracklist: tracklist)
    case "source":
      return sourceComponent(tracklist: tracklist)
    case "title":
      return tracklist.titleComponent
    case "year":
      return yearComponent(tracklist: tracklist)
    default:
      return "{\(named)}"
    }
  }
}
