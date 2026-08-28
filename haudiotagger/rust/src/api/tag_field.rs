/// A specific tag field that can be individually removed.
#[derive(Debug, Clone, Copy)]
pub enum TagField {
    /// The title of the song.
    Title,
    /// The artist of the song.
    Artist,
    /// The album the song is from.
    Album,
    /// The artist of the album.
    AlbumArtist,
    /// The year the song was made.
    Year,
    /// The genre of the song.
    Genre,
    /// The position of the song in a list.
    TrackNumber,
    /// The total amount of songs in a list.
    TrackTotal,
    /// The position of the disc in a list.
    DiscNumber,
    /// The total amount of discs in a list.
    DiscTotal,
    /// The lyrics of the song.
    Lyrics,
    /// A comment about the song.
    Comment,
    /// Beats per minute.
    Bpm,
    /// All embedded pictures.
    Pictures,
}
