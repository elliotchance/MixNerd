import SwiftUI

struct TracklistView: View {
  @AppStorage("bgArtURLString") private var bgArtURLString: String = ""
  @Binding var tracklist: Tracklist
  let artworkSize = 200.0 // in pixels

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
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

      ScrollView {
        Form {
          TextField("Date", text: Binding(get: { tracklist.date }, set: { tracklist.date = $0 }))
          TextField("Artist", text: Binding(get: { tracklist.artist }, set: { tracklist.artist = $0 }))
          TextField("Title", text: Binding(get: { tracklist.title }, set: { tracklist.title = $0 }))
          TextField("Source", text: Binding(get: { tracklist.source }, set: { tracklist.source = $0 }))

          ForEach(tracklist.tracks) { track in
            TextField("", text: Binding(get: { track.String() }, set: { _ in }))
          }
        }
        .padding(.vertical)
        .padding(.horizontal)
      }
      .frame(height: 200)
    }
  }
}
