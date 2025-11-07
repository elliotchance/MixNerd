import SwiftUI
import WebKit
import ID3TagEditor

struct AudioFileEditorView: View {
    @State private var isOpeningFile: Bool = false
    @State private var showAlert: Bool = false
    @State private var error: Error?
    @State private var tracklist: Tracklist?
    @State private var fileName: String? = nil
    let titleHeight = 30.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button("Open...") {
                    isOpeningFile = true
                }
                .controlSize(.small)

                Text(fileName ?? "No MP3 file loaded")
                .frame(maxWidth: .infinity)
                .controlSize(.small)
                
                Button("Save") {
                }
                .controlSize(.small)
                .disabled(fileName == nil)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: titleHeight)

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
                    // Start accessing the security-scoped resource
                    guard selectedURL.startAccessingSecurityScopedResource() else {
                        throw NSError(domain: "FileAccessError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not access the selected file."])
                    }
                    defer {
                        selectedURL.stopAccessingSecurityScopedResource()
                    }

                    // Get the file path from the URL
                    let filePath = selectedURL.path
                    fileName = selectedURL.lastPathComponent
                    
                    // Create ID3TagEditor instance and read the tag
                    let id3TagEditor = ID3TagEditor()
                    if let id3Tag = try id3TagEditor.read(from: filePath) {
                        let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)
                        tracklist = Tracklist(
                            artist: stringValue(tagContentReader.artist()),
                            title: stringValue(tagContentReader.title()),
                            editable: true,
                        )
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

    func stringValue(_ s: String?) -> String {
        if let s = s {
            return s.replacingOccurrences(of: "\0", with: "")
        }
        return ""
    }
}
