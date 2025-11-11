import SwiftUI

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
        } else {
          Color.gray
            .overlay(Text("No image").foregroundColor(.white))
        }
      }
    }
  }
}
