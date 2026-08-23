# Contributing
Any contributions are valued and welcome. If you want to make a big contribution, please create an issue ahead of time.
This will allow us to discuss and determine if your work fits into the project's goals, as well as making sure your effort is not wasted.

All contributions must be licensed under the MIT license to be accepted.

## Project Setup
This project uses `flutter_rust_bridge` which does all the hard work for allowing Dart to use the Rust codebase.
The versions of `flutter_rust_bridge` must match with every instance. For example,
there is `flutter_rust_bridge_codegen` (CLI tool) and `flutter_rust_bridge` (Rust + Dart dependency).
These must all have the same version for proper functionality.

## CLI Tool
A Dart CLI tool is provided for common commands.

Generate code:
```
dart run cli codegen
```

Build:
```
dart run cli build <platform>
```

**NOTE**: The builds are OS specific. For example, you can't build macOS libraries from Linux.
This isn't a big issue because the CI handles the building, but keep this in mind if you are testing.

## Project Structure
- Dart (`./haudiotagger/lib`)
  - Contains the public API.
- Rust (`./haudiotagger/rust`)
  - Main codebase that provides all the functionality.

When contributing, you will most likely be writing code in Rust.
If needed, you will have to run the codegen. There are some cases where you
will not need to run the codegen (ex. method body was not modified). If you are unsure, run the codegen anyways.

Depending on what you write, some changes may have to be made to the Dart side. In this case, please create
an easy to use public API and make sure that any new types are exported if they are needed.

## Code Guidelines
- Readable
- Proper naming
- Comments where needed
- Doc comments for new API elements

## Submit a PR
Maintainers will be able to review your code to make sure that it functions as expected and also follows the guidelines above.
If your PR fixes open issues, please make sure you include them in the description.
