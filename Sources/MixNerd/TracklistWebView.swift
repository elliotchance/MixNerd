import SwiftUI
import WebKit

struct TracklistWebView: View {
    @AppStorage("pageTitle") private var pageTitle: String = ""
    @AppStorage("currentURLString") private var currentURLString: String = ""
    private let initialURL = URL(
        string:
            "https://www.1001tracklists.com/tracklist/2klx8j7t/armin-van-buuren-ruben-de-ronde-ferry-corsten-a-state-of-trance-1248-ade-special-amsterdam-dance-event-netherlands-2025-10-23.html"
    )!
    private let tracklistWebViewWidth = 350.0
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                CustomWebView(
                    url: initialURL
                )
                .frame(width: geometry.size.width - tracklistWebViewWidth, height: geometry.size.height)
                .border(Color.gray.opacity(0.3))
                .clipped()

                Divider()

                HStack {
                    let urlString = currentURLString.isEmpty ? initialURL.absoluteString : currentURLString
                    if urlString.hasPrefix("https://www.1001tracklists.com/tracklist/") {
                        TracklistView()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Not a track list page")
                                .font(.headline)
                            Text("Open a URL starting with \"https://www.1001tracklists.com/tracklist/\" to see track details.")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(width: tracklistWebViewWidth, height: geometry.size.height)
                .background(Color(NSColor.windowBackgroundColor))
            }
            .onAppear {
                if currentURLString.isEmpty {
                    currentURLString = initialURL.absoluteString
                }
            }
        }
    }
}
