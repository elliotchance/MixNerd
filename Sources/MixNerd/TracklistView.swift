import SwiftUI

struct TracklistView: View {
  @AppStorage("bgArtURLString") private var bgArtURLString: String = ""
  @AppStorage("tracklistDate") var date: String = ""
  @State private var artist = ""
  // @Binding var title: String
  @State private var source = ""
  @State private var tracks: [Track] = [
    Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
    Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness (Oliver Lieb Remix)"),
  ]
  @Binding var tracklist: Tracklist?
  let artworkSize = 350.0 // in pixels

  var body: some View {
    VStack(spacing: 0) {
      AsyncImage(url: URL(string: bgArtURLString).flatMap { $0 } ?? URL(string: "https://picsum.photos/600/200")!) { phase in
        switch phase {
        case .empty:
          ProgressView().frame(maxWidth: artworkSize, maxHeight: artworkSize)
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(maxWidth: artworkSize, maxHeight: artworkSize)
            .clipped()
        case .failure:
          Color.gray.overlay(Text("Failed to load image").foregroundColor(.white))
        @unknown default:
          EmptyView()
        }
      }

      Divider()

      Form {
        TextField("Date", text: $date)
        TextField("Artist", text: $artist)
        TextField("Title", text: Binding(get: { tracklist?.title ?? "" }, set: { tracklist?.title = $0 }))
        TextField("Source", text: $source)
      }
      .padding(.vertical)
      .padding(.horizontal)
      .scrollContentBackground(.hidden)
      .frame(maxWidth: artworkSize)

      Divider()

      List(tracks) { track in
        Text(track.String())
          .font(.system(.body, design: .monospaced))
      }
    }
    .frame(minWidth: 400, minHeight: 600)
  }
}
