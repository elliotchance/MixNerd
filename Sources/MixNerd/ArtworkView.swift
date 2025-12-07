import SwiftUI
import UniformTypeIdentifiers

struct ArtworkView: View {
  @Binding var artwork: Artwork

  var body: some View {
    VStack(spacing: 12) {
      Group {
        if let image = artwork.image {
          Image(nsImage: image)
            .resizable()
            .scaledToFill()
            .clipped()
            .overlay(alignment: .bottomTrailing) {
              Button(action: {
                do {
                  try saveArtwork(artwork)
                } catch {
                  print("Error saving artwork: \(error)")
                }
              }) {
                Label("Save", systemImage: "square.and.arrow.down")
                  .labelStyle(.titleAndIcon)
              }
              .padding(12)
            }
        } else {
          Color.gray
            .overlay(Text("No image").foregroundColor(.white))
        }
      }
    }
  }

  @MainActor
  fileprivate func saveArtwork(_ artwork: Artwork) throws {
    let imageData = artwork.jpegData()
    let panel = NSSavePanel()
    panel.title = "Save Artwork"
    panel.nameFieldStringValue = "cover.jpg"
    panel.allowedContentTypes = [.jpeg]
    panel.canCreateDirectories = true

    if panel.runModal() == .OK, let url = panel.url {
      try imageData.write(to: url)
    }
  }
}
