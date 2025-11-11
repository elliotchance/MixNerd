import Foundation

class CueFile {
  /// Parse a CUE file from a string and convert it to a Tracklist
  static func parse(_ content: String) -> Tracklist? {
    let lines = content.components(separatedBy: .newlines)
    var tracklist = Tracklist()
    var currentTrack: Track?

    for line in lines {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      if trimmed.isEmpty || trimmed.hasPrefix("REM") {
        continue
      }

      // Parse PERFORMER (album artist)
      if trimmed.uppercased().hasPrefix("PERFORMER") && currentTrack == nil {
        if let performer = extractQuotedValue(trimmed) {
          tracklist.artist = performer
        }
        continue
      }

      // Parse TITLE (album title)
      if trimmed.uppercased().hasPrefix("TITLE") {
        if let title = extractQuotedValue(trimmed) {
          if currentTrack == nil {
            // Album title
            tracklist.title = title
          } else {
            // Track title
            currentTrack?.title = title
          }
        }
        continue
      }

      // Parse FILE (audio file reference)
      // if trimmed.uppercased().hasPrefix("FILE") {
      //     if let filename = extractQuotedValue(trimmed) {
      //         tracklist.source = filename
      //     }
      //     continue
      // }

      // Parse TRACK
      if trimmed.uppercased().hasPrefix("TRACK") {
        // Save previous track if exists
        if let track = currentTrack {
          tracklist.tracks.append(track)
        }

        // Start new track
        currentTrack = Track(time: "00:00", artist: tracklist.artist, title: "")
        continue
      }

      // Parse INDEX 01 (track start time)
      if trimmed.uppercased().hasPrefix("INDEX 01") {
        if let time = extractIndexTime(trimmed) {
          currentTrack?.time = time
        }
        continue
      }

      // Parse PERFORMER within a track (track artist)
      if trimmed.uppercased().hasPrefix("PERFORMER") && currentTrack != nil {
        if let performer = extractQuotedValue(trimmed) {
          currentTrack?.artist = performer
        }
        continue
      }
    }

    // Add the last track
    if let track = currentTrack {
      tracklist.tracks.append(track)
    }

    return tracklist.tracks.isEmpty ? nil : tracklist
  }

  /// Convert a Tracklist to CUE file format
  static func write(_ tracklist: Tracklist, audioFileName: String? = nil) -> String {
    var lines: [String] = []

    // Write PERFORMER (album artist)
    if !tracklist.artist.isEmpty {
      lines.append("PERFORMER \"\(escapeQuotes(tracklist.artist))\"")
    }

    // Write TITLE (album title)
    if !tracklist.title.isEmpty {
      lines.append("TITLE \"\(escapeQuotes(tracklist.title))\"")
    }

    // Write FILE
    let filename = audioFileName ?? (!tracklist.source.isEmpty ? tracklist.source : "audio.mp3")
    lines.append("FILE \"\(escapeQuotes(filename))\" WAVE")

    // Write tracks
    for (index, track) in tracklist.tracks.enumerated() {
      let trackNum = index + 1
      lines.append("  TRACK \(String(format: "%02d", trackNum)) AUDIO")

      // Track title
      if !track.title.isEmpty {
        lines.append("    TITLE \"\(escapeQuotes(track.title))\"")
      }

      // Track performer (if different from album artist)
      if !track.artist.isEmpty && track.artist != tracklist.artist {
        lines.append("    PERFORMER \"\(escapeQuotes(track.artist))\"")
      }

      // INDEX 01 with time
      let cueTime = convertToCueTime(track.time)
      lines.append("    INDEX 01 \(cueTime)")
    }

    return lines.joined(separator: "\n")
  }

  /// Extract a quoted value from a line (e.g., "value" from KEYWORD "value")
  private static func extractQuotedValue(_ line: String) -> String? {
    guard let startIndex = line.firstIndex(of: "\""),
      let endIndex = line.lastIndex(of: "\"")
    else {
      return nil
    }

    let start = line.index(after: startIndex)
    let end = endIndex
    guard start < end else { return nil }

    return String(line[start..<end])
  }

  /// Extract time from INDEX line (e.g., "00:00:00" from "INDEX 01 00:00:00")
  private static func extractIndexTime(_ line: String) -> String? {
    let parts = line.components(separatedBy: .whitespaces)
    guard parts.count >= 3 else { return nil }

    let timeString = parts[2]  // Format: MM:SS:FF or MM:SS:00
    let timeComponents = timeString.components(separatedBy: ":")

    guard timeComponents.count >= 2 else { return nil }

    // Convert CUE time format (MM:SS:FF) to MM:SS format
    let minutes = timeComponents[0]
    let seconds = timeComponents[1]

    return "\(minutes):\(seconds)"
  }

  /// Convert MM:SS format to CUE time format (MM:SS:00)
  private static func convertToCueTime(_ time: String) -> String {
    let components = time.components(separatedBy: ":")
    if components.count >= 2 {
      let minutes = components[0]
      let seconds = components[1]
      return "\(minutes):\(seconds):00"
    }
    return "00:00:00"
  }

  /// Escape quotes in strings for CUE file format
  private static func escapeQuotes(_ string: String) -> String {
    return string.replacingOccurrences(of: "\"", with: "\\\"")
  }
}
