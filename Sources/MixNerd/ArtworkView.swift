import SwiftUI
import UniformTypeIdentifiers

struct ArtworkView: View {
  @Binding var artwork: NSImage?

  var body: some View {
    VStack(spacing: 12) {
      Group {
        if let artwork = artwork {
          Image(nsImage: artwork)
            .resizable()
            .scaledToFill()
            .clipped()
            .overlay(alignment: .bottomTrailing) {
              Button(action: { saveArtwork(artwork) }) {
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

  fileprivate func saveArtwork(_ image: NSImage) {
    guard let imageData = makeJPEGData(from: image) else {
      return
    }

    let panel = NSSavePanel()
    panel.title = "Save Artwork"
    panel.nameFieldStringValue = "cover.jpg"
    panel.allowedContentTypes = [.jpeg]
    panel.canCreateDirectories = true

    if panel.runModal() == .OK, let url = panel.url {
      do {
        try imageData.write(to: url)
      } catch {
        NSLog("Failed to save artwork: \(error.localizedDescription)")
      }
    }
  }

  fileprivate func makeJPEGData(from image: NSImage) -> Data? {
    guard
      let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let data = bitmap.representation(
        using: .jpeg,
        properties: [.compressionFactor: 0.9]
      )
    else {
      return nil
    }

    return data
  }
}
