mod api;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

#[cfg(test)]
mod tests {
    use crate::api::api;
    use crate::api::picture;
    use crate::api::tag::Tag;
    use anyhow::Context;
    use std::io::Read;
    use std::sync::atomic::{AtomicU64, Ordering};

    static SCRATCH_COUNTER: AtomicU64 = AtomicU64::new(0);

    /// Copies a sample file into a unique temp path so concurrent tests don't
    /// clobber each other's fixtures.
    fn scratch(src: &str) -> String {
        let n = SCRATCH_COUNTER.fetch_add(1, Ordering::SeqCst);
        let ext = std::path::Path::new(src)
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("");
        let name = if ext.is_empty() {
            format!("haudiotagger_test_{}_{}", std::process::id(), n)
        } else {
            format!("haudiotagger_test_{}_{}.{}", std::process::id(), n, ext)
        };
        let dst = std::env::temp_dir().join(name);
        std::fs::copy(src, &dst).expect("Could not copy sample to scratch file.");
        dst.to_string_lossy().into_owned()
    }

    fn read_tag(path: &str) -> anyhow::Result<()> {
        let tag = api::read(path.to_string()).context("Could not read tag.")?;

        println!("{:?}", tag.title);
        println!("{:?}", tag.track_artist);
        println!("{:?}", tag.album);
        println!("{:?}", tag.album_artist);
        println!("{:?}", tag.year);
        println!("{:?}", tag.track_number);
        println!("{:?}", tag.track_total);
        println!("{:?}", tag.disc_number);
        println!("{:?}", tag.disc_total);
        println!("{:?}", tag.genre);
        println!("{:?}", tag.lyrics);
        println!("{:?}", tag.duration);
        println!("{:?}", tag.bpm);
        println!("{:?}", tag.pictures);

        Ok(())
    }

    fn empty_tag() -> Tag {
        Tag {
            title: None,
            track_artist: None,
            album: None,
            album_artist: None,
            year: None,
            genre: None,
            track_number: None,
            track_total: None,
            disc_number: None,
            disc_total: None,
            lyrics: None,
            duration: None,
            pictures: Vec::new(),
            bpm: None,
        }
    }

    fn full_tag() -> Tag {
        let picture1 = picture::Picture::new(
            picture::PictureType::CoverFront,
            Some(picture::MimeType::Jpeg),
            std::fs::File::open("samples/picture1.jpg")
                .unwrap()
                .bytes()
                .map(|b| b.unwrap())
                .collect(),
        );

        let picture2 = picture::Picture::new(
            picture::PictureType::CoverBack,
            Some(picture::MimeType::Jpeg),
            std::fs::File::open("samples/picture2.jpg")
                .unwrap()
                .bytes()
                .map(|b| b.unwrap())
                .collect(),
        );

        Tag {
            title: Some("Title".to_string()),
            track_artist: Some("Track Artist".to_string()),
            album: Some("Album".to_string()),
            album_artist: Some("Album Artist".to_string()),
            year: Some(2022),
            track_number: Some(1),
            track_total: Some(2),
            disc_number: Some(1),
            disc_total: Some(3),
            genre: Some("Genre".to_string()),
            lyrics: Some("Lyrics - test string".to_string()),
            bpm: Some(140.0),
            pictures: vec![picture1, picture2],
            ..Default::default()
        }
    }

    #[test]
    fn clear_tag_mp3() {
        let path = scratch("samples/test.mp3");
        api::write(path.clone(), empty_tag()).expect("Could not write tag.");

        assert!(read_tag(&path).is_err());
    }

    #[test]
    fn write_tag_mp3() {
        let path = scratch("samples/test.mp3");
        api::write(path.clone(), full_tag()).expect("Failed to write tag.");

        assert!(read_tag(&path).is_ok());
    }

    #[test]
    fn clear_tag_mp4() {
        let path = scratch("samples/test.mp4");
        api::write(path.clone(), empty_tag()).expect("Could not write tag.");

        assert!(read_tag(&path).is_err());
    }

    #[test]
    fn write_tag_mp4() {
        let path = scratch("samples/test.mp4");
        api::write(path.clone(), full_tag()).expect("Failed to write tag.");

        assert!(read_tag(&path).is_ok());
    }

    #[test]
    fn lyrics_roundtrip_mp3() {
        let path = scratch("samples/test.mp3");
        let mut tag = full_tag();
        tag.lyrics = Some("My Lyrics Line".to_string());
        api::write(path.clone(), tag).expect("Failed to write tag.");
        let read = api::read(path.clone()).expect("Failed to read tag.");
        assert_eq!(read.lyrics.as_deref(), Some("My Lyrics Line"));
    }

    #[test]
    fn lyrics_roundtrip_mp4() {
        let path = scratch("samples/test.mp4");
        let mut tag = full_tag();
        tag.lyrics = Some("My Lyrics Line".to_string());
        api::write(path.clone(), tag).expect("Failed to write tag.");
        let read = api::read(path.clone()).expect("Failed to read tag.");
        assert_eq!(read.lyrics.as_deref(), Some("My Lyrics Line"));
    }
}
