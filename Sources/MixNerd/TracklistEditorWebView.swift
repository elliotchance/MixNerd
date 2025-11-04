import SwiftUI
import WebKit

class TracklistEditorState: ObservableObject, @unchecked Sendable {
    @Published var tracklist: Tracklist?
    
    @MainActor
    func setTracklist(_ tl: Tracklist?) {
        tracklist = tl
    }

}

struct TracklistEditorWebView: View {
    @StateObject private var state = TracklistEditorState()
    private let initialURL = URL(
        string:
            "https://www.1001tracklists.com/tracklist/2klx8j7t/armin-van-buuren-ruben-de-ronde-ferry-corsten-a-state-of-trance-1248-ade-special-amsterdam-dance-event-netherlands-2025-10-23.html"
    )!
    private let tracklistWebViewWidth = 350.0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                TracklistWebView(
                    url: initialURL,
                    setTracklist: { [state] tl in
                        print("tracklist: \(String(describing: tl))")
                        Task { @MainActor in
                            state.setTracklist(tl)
                        }
                    }
                )
                .frame(width: geometry.size.width - tracklistWebViewWidth, height: geometry.size.height)
                .border(Color.gray.opacity(0.3))
                .clipped()

                Divider()

                HStack {
                    if let tracklist = state.tracklist {
                        TracklistView(tracklist: Binding(get: { tracklist }, set: { state.setTracklist($0) }))
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
        }
    }
}
