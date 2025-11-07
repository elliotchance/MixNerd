import SwiftUI

struct TracklistView: View {
  @Binding var tracklist: Tracklist
  let artworkSize = 200.0 - 30.0 // in pixels

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      Group {
        if let artwork = tracklist.artwork {
          Image(nsImage: artwork)
            .resizable()
            .scaledToFill()
            .frame(width: artworkSize, height: artworkSize)
            .clipped()
        } else if let url = URL(string: tracklist.artworkURL), !tracklist.artworkURL.isEmpty {
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
          // TextField("Date", text: Binding(get: { tracklist.date }, set: { tracklist.date = $0 }))
          //   .disabled(!tracklist.editable)
          TextField("Artist", text: Binding(get: { tracklist.artist }, set: { tracklist.artist = $0 }))
            .disabled(!tracklist.editable)
          TextField("Title", text: Binding(get: { tracklist.title }, set: { tracklist.title = $0 }))
            .disabled(!tracklist.editable)
          TextField("Grouping", text: Binding(get: { tracklist.source }, set: { tracklist.source = $0 }))
            .disabled(!tracklist.editable)
          TextField("Genre", text: Binding(get: { tracklist.genre }, set: { tracklist.genre = $0 }))
            .disabled(!tracklist.editable)

          ForEach(Array(tracklist.tracks.enumerated()), id: \.element.id) { index, track in
            HStack(alignment: .top) {
              VStack {
                Text(String(format: "%02d", index + 1)).font(.title3).bold()
                
                TextField("", text: Binding(get: { track.time }, set: { _ in }))
                  .disabled(!tracklist.editable)
                  .frame(width: 80)
                  .font(.system(.body, design: .monospaced))
                  .multilineTextAlignment(.trailing)
              }
              VStack {
                TextField("", text: Binding(get: { track.artist }, set: { _ in }))
                  .disabled(!tracklist.editable)
                TextField("", text: Binding(get: { track.title }, set: { _ in }))
                  .disabled(!tracklist.editable)
              }
            }
            Divider()
          }
        }
        .padding(.vertical)
        .padding(.horizontal)
      }
      .frame(height: artworkSize)
    }
  }
}
