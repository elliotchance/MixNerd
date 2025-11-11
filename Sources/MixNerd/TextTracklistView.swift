import SwiftUI

struct TextTracklistView: View {
  @Binding var tracklist: Tracklist
  @Binding var estimateTrackTimes: Bool
  let artworkSize = 200.0  // in pixels

  var body: some View {
    VStack(spacing: 0) {
      ArtworkView(artwork: Binding(get: { tracklist.artwork }, set: { tracklist.artwork = $0 }))
        .frame(width: artworkSize, height: artworkSize)

      Form {
        Toggle("Estimate track times", isOn: $estimateTrackTimes)
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
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
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
*/
    var s = "\(tracklist.artist) - \(tracklist.title) \(tracklist.date)\n\n"

    for track in tracklist.tracks {
      if track.time.isEmpty {
        s += "\(track.artist) - \(track.title)\n"
      } else {
        s += "[\(track.time)] \(track.artist) - \(track.title)\n"
      }
    }

    s +=
      "\nPlease set a backlink to keep the tracklist up-to-date: https://\(tracklist.shortLink)\n"

    return s
  }
}
