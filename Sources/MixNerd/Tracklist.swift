struct Tracklist {
    var artworkURL: String
    var date: String
    var artist: String
    var title: String
    var source: String
    var tracks: [Track] = [
        Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
        Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness (Oliver Lieb Remix)"),
    ]
}
