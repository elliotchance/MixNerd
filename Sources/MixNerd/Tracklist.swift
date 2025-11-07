struct Tracklist {
    var artworkURL: String = ""
    var date: String = ""
    var artist: String = ""
    var title: String = ""
    var source: String = ""
    var tracks: [Track] = [
        Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
        Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness (Oliver Lieb Remix)"),
        Track(time: "12:36", artist: "Tiesto", title: "Adagio For Strings"),
        Track(time: "18:54", artist: "Armin Van Buuren", title: "This Is What It Feels Like"),
        Track(time: "25:12", artist: "Tiesto", title: "Adagio For Strings"),
        Track(time: "31:30", artist: "Armin Van Buuren", title: "This Is What It Feels Like"),
        Track(time: "37:48", artist: "Tiesto", title: "Adagio For Strings"),
        Track(time: "44:06", artist: "Armin Van Buuren", title: "This Is What It Feels Like"),
        Track(time: "50:24", artist: "Tiesto", title: "Adagio For Strings"),
        Track(time: "56:42", artist: "Armin Van Buuren", title: "This Is What It Feels Like"),
    ]
    var editable: Bool = false
}
