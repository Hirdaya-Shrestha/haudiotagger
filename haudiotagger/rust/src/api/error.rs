#[derive(Debug)]
pub enum HaudiotaggerError {
    InvalidPath,
    NoTags,
    OpenFile { message: String },
    Write { message: String },
}

impl std::error::Error for HaudiotaggerError {}

impl std::fmt::Display for HaudiotaggerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidPath => write!(f, "Invalid or inaccessible file path"),
            Self::NoTags => write!(f, "No metadata tags found in file"),
            Self::OpenFile { message } => write!(f, "Failed to open file: {message}"),
            Self::Write { message } => write!(f, "Failed to write tag: {message}"),
        }
    }
}
