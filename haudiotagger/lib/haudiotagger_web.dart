export 'src/rust/frb_generated.web.dart';

// Flutter web plugin registration contract. The actual WASM implementation
// lives in `src/rust/frb_generated.web.dart` and is loaded by `RustLib.init()`
// (invoked from `Haudiotagger.init()`), so there is nothing to register here.
class HaudiotaggerWeb {
  static void registerWith([dynamic _]) {}
}
