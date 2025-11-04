import SwiftUI

struct TracklistView: View {
  @State private var imageURL = URL(string: "https://picsum.photos/600/200")!
  @State private var artist = ""
  @AppStorage("pageTitle") var title: String = ""
  @State private var source = ""
  @State private var tracks: [Track] = [
    Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
    Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness (Oliver Lieb Remix)"),
  ]

  var body: some View {
    VStack(spacing: 0) {
      // 1️⃣ Image panel
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .empty:
          ProgressView().frame(maxWidth: .infinity, maxHeight: 200)
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: 200)
            .clipped()
        case .failure:
          Color.gray.overlay(Text("Failed to load image").foregroundColor(.white))
        @unknown default:
          EmptyView()
        }
      }

      Divider()

      // 2️⃣ Form panel
      Form {
        TextField("Artist", text: $artist)
        TextField("Title", text: $title)
        TextField("Source", text: $source)
      }
      .frame(maxHeight: 180)
      .scrollContentBackground(.hidden)

      Divider()

      // 3️⃣ Track list panel
      List(tracks) { track in
        Text("[\(track.time)] \(track.artist) - \(track.title)")
          .font(.system(.body, design: .monospaced))
      }
    }
    .padding()
    .frame(minWidth: 400, minHeight: 600)
  }
}
