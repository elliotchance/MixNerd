import SwiftUI
import WebKit

struct ContentView: View {
    @AppStorage("pageTitle") private var pageTitle: String = ""
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                CustomWebView(
                    url: URL(
                        string:
                            "https://www.1001tracklists.com/tracklist/2klx8j7t/armin-van-buuren-ruben-de-ronde-ferry-corsten-a-state-of-trance-1248-ade-special-amsterdam-dance-event-netherlands-2025-10-23.html"
                    )!
                )
                .border(Color.gray.opacity(0.3))

                Divider()

                HStack {
                    TracklistView()
                }
                .frame(height: geometry.size.height * 0.4)
                .background(Color(NSColor.windowBackgroundColor))
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
