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
    /*
    Armin van Buuren - A State Of Trance 001 2001-06-01

[00:15] Warrior - Voodoo (Oliver Lieb Remix) [INCENTIVE]
[05:45] Mutiny - Secrets (Ian Wilkie C-bit Dub Mix) [VC]
[11:26] Joker Jam - Innocence (Planisphere Remix) [GREEN MARTIAN]
[19:49] Liquid DJ Team - Liquidation (Marco V Remix) [UNITED]
Tune Of The Week:
[24:36] Sonic Inc. - The Taste Of Summer (Fire & Ice Vital Remix) [BONZAI]
[31:13] Natural Born Grooves - Kickback (TDR Remix) [NATURAL BORN GROOVES]
[37:11] RR Workshop - 50K [JOURNEY]
Classic:
[43:34] The Ultimate Seduction - The Ultimate Seduction [VENDETTA (BLANCO Y NEGRO)]
[47:57] System F ft. Armin van Buuren - Exhale (Inhale Remix) [TSUNAMI]
[53:32] Blank & Jones - Tribal Attack [GANG GO]
Armin van Buuren Non-Stop In The Mix:
[59:30] Drax & Scott Mac - Sublime (Darkstar Remix)
[1:06:30] Orion ft. Rebecca Raine - See Me Here (Darren Tate Beachcomber Dub Mix) [MONDO]
[1:12:58] Xian - Pachinko (Praha Part 2 Remix) [PLATIPUS]
[1:18:29] Rising Star - Clear Blue Moon [ARMIND (ARMADA)]
[1:27:21] Ralphie B - Massive [ITWT (BLACK HOLE)]
[1:35:31] Members Of Mayday - 10 In 01 (Paul van Dyk Remix) [DEVIANT]
[1:41:49] Rank 1 ft. Shanokee - Such Is Life [ID&T]
[1:48:10] S.O.L.I.S. - Dolphins [ALIEN]
[1:55:55] Armin van Buuren - Blue Fear [CYBER (ARMADA)]

Please set a backlink to keep the tracklist up-to-date: https://1001.tl/38zxw8k


Armin van Buuren - A State Of Trance 000 2001-05-18

A State Of Trance Preview Part 1
01. Satoshi Tomiie ft. Kelli Ali - Love In Traffic (Satoshi Tomiie Dark Path Remix) [INCREDIBLE]
02. Utah Saints - Lost Vagueness (Oliver Lieb Main Mix) [ECHO]
[13:25] Orion ft. Rebecca Raine - See Me Here (Skope Vocal Mix) [MONDO]
04. Yahel - U Inside [CYBER (ARMADA)]
05. Transa - Kinetic [HOOK]
06. Natural Born Grooves - Kickback (TDR Remix) [NATURAL BORN GROOVES]
07. Perpetuous Dreamer ft. Elles De Graaf - The Sound Of Goodbye (Above & Beyond Remix) [ARMIND (ARMADA)]
08. Airwave - Mysteries Of Life [BONZAI TRANCE PROG]
09. Rising Star - Star Theme [ARMIND (ARMADA)]
A State Of Trance Preview Part 2
10. Delerium ft. Leigh Nash - Innocente (Mr Sam The Space Between Us Mix) [NETTWERK]
11. Green Court ft. De Vision - Take (Chrome Romance In Ny Remix) [CLUB CULTURE]
12. Moogwai - The Labyrinth (Part Two) [PLATIPUS]
13. Guy Naets & Michel Bierlin - Beam Me Up! [PROGREZ]
14. Coast 2 Coast ft. Discovery - Home (Tiësto Remix) [ID&T]
15. Ultra Vibe - Choose Freedom [CAMOUFLAGE (SUBTRAXX)]
16. System F - Mode Confusion [FLASHOVER]
17. M.I.K.E. pres. Push - Strange World (Airwave Remix) [BONZAI]
18. Dennis M - Right Now [REZZONANT]

Please set a backlink to keep the tracklist up-to-date: https://1001.tl/2xbh9b9
*/
    var s = "\(tracklist.artist) - \(tracklist.title) \(tracklist.date)\n\n"

    var trackNumber = 1
    for track in tracklist.tracks {
      if track.timeIsEstimated && !estimateMissingTrackTimes {
        s += "\(String(format: "%02d", trackNumber)). \(track.artist) - \(track.title)"
      } else {
        s += "[\(track.formattedTime())] \(track.artist) - \(track.title)"
      }
      if includeLabels && !track.label.isEmpty {
        s += " [\(track.label)]"
      }
      s += "\n"
      trackNumber += 1
    }

    s +=
      "\nPlease set a backlink to keep the tracklist up-to-date: \(tracklist.shortLink)\n"

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
