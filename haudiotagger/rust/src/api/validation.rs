use super::tag::Tag;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ValidationSeverity {
    Error,
    Warning,
}

#[derive(Debug, Clone)]
pub struct ValidationIssue {
    pub field: String,
    pub message: String,
    pub severity: ValidationSeverity,
}

#[derive(Debug, Clone)]
pub struct ValidationResult {
    pub issues: Vec<ValidationIssue>,
}

impl ValidationResult {
    pub fn is_valid(&self) -> bool {
        self.issues
            .iter()
            .all(|i| i.severity == ValidationSeverity::Warning)
    }
}

pub fn validate(tag: &Tag) -> ValidationResult {
    let mut issues = Vec::new();

    if tag.track_number.unwrap_or(0) == 0 && tag.track_total.is_some() {
        issues.push(ValidationIssue {
            field: "track_number".into(),
            message: "Track number is 0 but track total is set".into(),
            severity: ValidationSeverity::Error,
        });
    }

    if let (Some(num), Some(total)) = (tag.track_number, tag.track_total) {
        if num > total {
            issues.push(ValidationIssue {
                field: "track_number".into(),
                message: format!("Track number ({num}) exceeds total ({total})"),
                severity: ValidationSeverity::Error,
            });
        }
    }

    if let (Some(num), Some(total)) = (tag.disc_number, tag.disc_total) {
        if num > total {
            issues.push(ValidationIssue {
                field: "disc_number".into(),
                message: format!("Disc number ({num}) exceeds total ({total})"),
                severity: ValidationSeverity::Error,
            });
        }
    }

    if tag.track_artist.is_none() {
        issues.push(ValidationIssue {
            field: "track_artist".into(),
            message: "Missing artist".into(),
            severity: ValidationSeverity::Warning,
        });
    }

    if tag.album.is_none() {
        issues.push(ValidationIssue {
            field: "album".into(),
            message: "Missing album".into(),
            severity: ValidationSeverity::Warning,
        });
    }

    if tag.pictures.is_empty() {
        issues.push(ValidationIssue {
            field: "pictures".into(),
            message: "Missing artwork".into(),
            severity: ValidationSeverity::Warning,
        });
    }

    if let Some(bpm) = tag.bpm {
        if !(1.0..=999.0).contains(&bpm) {
            issues.push(ValidationIssue {
                field: "bpm".into(),
                message: format!("Invalid BPM value: {bpm}"),
                severity: ValidationSeverity::Warning,
            });
        }
    }

    if let Some(year) = tag.year {
        if year == 0 || year > 2100 {
            issues.push(ValidationIssue {
                field: "year".into(),
                message: format!("Invalid year: {year}"),
                severity: ValidationSeverity::Warning,
            });
        }
    }

    ValidationResult { issues }
}
