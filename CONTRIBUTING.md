# Contributing

Large changes? Open an issue first — lets us align on scope so your effort isn't wasted.

All contributions must be MIT-licensed.

## Setup

This project uses `flutter_rust_bridge`. Ensure all `flutter_rust_bridge` versions (codegen CLI, Rust crate, Dart dep) match.

```bash
# Generate Dart bindings after Rust API changes
dart run cli codegen

# Build for a specific platform (OS-specific)
dart run cli build <platform>
```

> Builds are OS-specific (e.g. macOS libs can't be built on Linux). CI handles cross-platform builds.

## Structure

| Path | What |
|------|------|
| `haudiotagger/lib` | Public Dart API |
| `haudiotagger/rust` | Core implementation (Rust) |

Most contributions go in Rust. Run codegen after any Rust API change. If the change touches the Dart layer, keep the public API clean and export new types.

## Guidelines

- Readable over clever
- Doc comments on public API elements
- Proper naming conventions

## PRs

Keep PRs focused. Reference related issues in the description.
