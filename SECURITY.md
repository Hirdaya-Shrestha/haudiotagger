# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | :white_check_mark: |
| < 1.3   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in haudiotagger, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, email: **hirdaya098@gmail.com** with:

- A description of the vulnerability
- Steps to reproduce
- The potential impact
- Any suggested fix (if applicable)

## What to Expect

- **Acknowledgement** within 48 hours of your report
- **Status update** within 7 days with an assessment and planned timeline
- **Fix released** as a patch version once confirmed and resolved
- **Credit** in the changelog (unless you prefer to remain anonymous)

## Scope

This policy applies to:

- The `haudiotagger` Dart package published on pub.dev
- The underlying Rust native library (`libhaudiotagger`)
- The build scripts and CI/CD pipeline in this repository

## Out of Scope

- Vulnerabilities in third-party dependencies (report these to the respective maintainers)
- Issues that require physical access to the user's device
- Denial of service attacks against the package registry or CI

## Security Best Practices for Consumers

- Always use the latest version of haudiotagger
- Validate and sanitize file paths before passing them to the library
- Do not process untrusted audio files in privilege-escalated contexts
- When using the web (WASM) build, ensure your deployment environment follows standard web security practices

## Dependency Security

- Dependencies are audited via `cargo audit` for Rust crates
- Dart dependencies are pinned in `pubspec.lock`
- CI runs `dart analyze` and `cargo clippy` to catch common issues
