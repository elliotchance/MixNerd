import SwiftUI

#if os(macOS)
  import AppKit
  import UniformTypeIdentifiers
#else
  import UIKit
#endif

struct TextTracklistView: View {
  @Binding var tracklist: Tracklist
  @Binding var estimateMissingTrackTimes: Bool
  @Binding var includeLabels: Bool
  let artworkSize = 200.0  // in pixels

  var body: some View {
    VStack(spacing: 0) {
      ArtworkView(artwork: Binding(get: { tracklist.artwork }, set: { tracklist.artwork = $0 }))
        .frame(width: artworkSize, height: artworkSize)

      Form {
        Text("Duration: \(tracklist.duration.description)")
        Toggle("Estimate missing track times", isOn: $estimateMissingTrackTimes)
          .toggleStyle(.checkbox)
        Toggle("Include labels", isOn: $includeLabels)
          .toggleStyle(.checkbox)
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)

      GeometryReader { geometry in
        ScrollView([.vertical, .horizontal]) {
          Text(displayTracklistText)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: geometry.size.height, alignment: .topLeading)
            .padding(6)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomTrailing)
        .overlay(alignment: .bottomTrailing) {
          HStack(spacing: 8) {
            Button {
              saveTracklistToFile()
            } label: {
              Label("Save", systemImage: "square.and.arrow.down")
            }
            Button {
              copyTracklistToClipboard()
            } label: {
              Label("Copy", systemImage: "doc.on.doc")
            }
          }
          .padding(12)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .overlay(
        RoundedRectangle(cornerRadius: 0)
          .stroke(Color.gray.opacity(0.3))
      )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  private var displayTracklistText: String {
    var s = "\(tracklist.artist) - \(tracklist.title) \(tracklist.date)\n\n"

    var trackNumber = 1
    for track in tracklist.tracks {
      if track.time.isEstimated && !estimateMissingTrackTimes {
        s += "\(String(format: "%02d", trackNumber)). \(track.artist) - \(track.title)"
      } else {
        s += "[\(track.time.description)] \(track.artist) - \(track.title)"
      }
      if includeLabels && !track.label.isEmpty {
        s += " [\(track.label)]"
      }
      s += "\n"
      trackNumber += 1
    }

    s +=
      "\nPlease set a backlink to keep the tracklist up-to-date: \(tracklist.shortLink?.absoluteString ?? "")\n"

    return s
  }

  private func copyTracklistToClipboard() {
    #if os(macOS)
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(displayTracklistText, forType: .string)
    #else
      UIPasteboard.general.string = displayTracklistText
    #endif
  }

  @MainActor
  private func saveTracklistToFile() {
    #if os(macOS)
      let panel = NSSavePanel()
      if #available(macOS 12.0, *) {
        panel.allowedContentTypes = [.plainText]
      } else {
        panel.allowedFileTypes = ["txt"]
      }
      panel.canCreateDirectories = true
      panel.nameFieldStringValue = "\(sanitizedTracklistTitle()).txt"

      panel.begin { [displayTracklistText] response in
        guard response == .OK, let url = panel.url else {
          return
        }

        do {
          try displayTracklistText.write(to: url, atomically: true, encoding: .utf8)
        } catch {
          let alert = NSAlert()
          alert.messageText = "Unable to Save Tracklist"
          alert.informativeText = error.localizedDescription
          alert.alertStyle = .warning
          alert.runModal()
        }
      }
    #else
      copyTracklistToClipboard()
    #endif
  }

  private func sanitizedTracklistTitle() -> String {
    let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
    let baseName = "\(tracklist.artist) - \(tracklist.title) \(tracklist.date)"
    let sanitized = baseName.components(separatedBy: invalidCharacters).joined(separator: " ")
    let trimmed = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "Tracklist" : trimmed
  }
}
