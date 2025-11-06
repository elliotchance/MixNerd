import SwiftUI
import WebKit

struct AudioFileEditorView: View {
    @State private var isOpeningFile: Bool = false
    @State private var showAlert: Bool = false
    @State private var error: Error?
    @State private var tracklist: Tracklist?
    @State private var fileName: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Open...") {
                    isOpeningFile = true
                }

                Text(fileName ?? "No MP3 file loaded")
                    .frame(maxWidth: .infinity)
                
                Button("Save") {
                }
                    .disabled(fileName == nil)
                    .padding()
            }
            .frame(maxWidth: .infinity)

            if let tracklist = tracklist {
                TracklistView(tracklist: Binding(get: { tracklist }, set: { self.tracklist = $0 }))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .fileImporter(
            isPresented: $isOpeningFile,
            allowedContentTypes: [.mp3],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let selectedURL = urls.first else { return }
                do {
                    defer {
                        selectedURL.stopAccessingSecurityScopedResource()
                    }
                    // Start accessing the security-scoped resource
                    if selectedURL.startAccessingSecurityScopedResource() {
                        let content = try String(contentsOf: selectedURL, encoding: .utf8)
                        // state.setFileTracklist(state.webTracklist)
                    } else {
                        // Handle the case where access could not be granted
                        throw NSError(domain: "FileAccessError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not access the selected file."])
                    }
                } catch {
                    self.error = error
                }
            case .failure(let error):
                self.error = error
            }
        }
        // .alert(isPresented: $showAlert, error: error) { _ in
        //     Button("OK") {
        //         // Handle acknowledgement.
        //     }
        // } message: { error in
        //     // Text(error.recoverySuggestion ?? "Try again later.")
        // }
    }
}
