import SwiftUI
import WebKit

class TracklistEditorState: ObservableObject, @unchecked Sendable {
    @Published var webTracklist: Tracklist?
    @Published var fileTracklist: Tracklist?
    
    @MainActor
    func setWebTracklist(_ tl: Tracklist?) {
        webTracklist = tl
    }

    @MainActor
    func setFileTracklist(_ tl: Tracklist?) {
        fileTracklist = tl
    }
}

struct TracklistEditorWebView: View {
    @StateObject private var state = TracklistEditorState()
    @State private var isOpeningFile: Bool = false
    @State private var showAlert: Bool = false
    @State private var error: Error?
    private let initialURL = URL(
        string:
            "https://www.1001tracklists.com/tracklist/2klx8j7t/armin-van-buuren-ruben-de-ronde-ferry-corsten-a-state-of-trance-1248-ade-special-amsterdam-dance-event-netherlands-2025-10-23.html"
    )!
    private let tracklistWebViewHeight = 200.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                TracklistWebView(
                    url: initialURL,
                    setTracklist: { [state] tl in
                        let tracklist = tl
                        Task { @MainActor in
                            state.setWebTracklist(tracklist)
                        }
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height - tracklistWebViewHeight)
                .border(Color.gray.opacity(0.3))
                .clipped()

                Divider()

                HStack {
                    VStack {
                        if let tracklist = state.webTracklist {
                            TracklistView(tracklist: Binding(get: { tracklist }, set: { state.setWebTracklist($0) }))
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
                    .frame(width: geometry.size.width * 0.5, height: tracklistWebViewHeight)

                    AudioFileEditorView()
                        .frame(width: geometry.size.width * 0.5, height: tracklistWebViewHeight)
                }
            }
        }
    }
}
