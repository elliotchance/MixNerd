import SwiftUI

struct TracklistView: View {
  @AppStorage("bgArtURLString") private var bgArtURLString: String = ""
  @State private var tracks: [Track] = [
    Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
    Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness (Oliver Lieb Remix)"),
  ]
  @Binding var tracklist: Tracklist
  let artworkSize = 200.0 // in pixels

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      // Image section
      Group {
        if let url = URL(string: bgArtURLString), !bgArtURLString.isEmpty {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              ProgressView()
                .frame(width: artworkSize, height: artworkSize)
            case .success(let image):
              image
                .resizable()
                .scaledToFill()
                .frame(width: artworkSize, height: artworkSize)
                .clipped()
            case .failure:
              Color.gray
                .frame(width: artworkSize, height: artworkSize)
                .overlay(Text("Failed to load image").foregroundColor(.white))
            @unknown default:
              Color.clear
                .frame(width: artworkSize, height: artworkSize)
            }
          }
        } else {
          Color.gray
            .frame(width: artworkSize, height: artworkSize)
            .overlay(Text("No image").foregroundColor(.white))
        }
      }
      .frame(width: artworkSize, height: artworkSize)

      Divider()

      VStack {
        Form {
          TextField("Date", text: Binding(get: { tracklist.date }, set: { tracklist.date = $0 }))
          TextField("Artist", text: Binding(get: { tracklist.artist }, set: { tracklist.artist = $0 }))
          TextField("Title", text: Binding(get: { tracklist.title }, set: { tracklist.title = $0 }))
          TextField("Source", text: Binding(get: { tracklist.source }, set: { tracklist.source = $0 }))
        }
        .padding(.vertical)
        .padding(.horizontal)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 300, maxWidth: 400)

        List(tracks) { track in
          Text(track.String())
            .font(.system(.body, design: .monospaced))
        }
        // .frame(minWidth: 300)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
