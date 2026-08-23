// haudiotagger web bootstrap
// Automatically downloads, caches, and loads WASM from GitHub releases on first use.
// Add to web/index.html BEFORE main.dart.js:
//   <script src="https://cdn.jsdelivr.net/gh/Hirdaya-Shrestha/haudiotagger@main/haudiotagger/web/bootstrap.js" data-version="1.0.1"></script>

(function () {
  var VERSION = document.currentScript?.getAttribute("data-version") || "1.0.1";
  var RELEASE_BASE =
    "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v" +
    VERSION;
  var WASM_URL = RELEASE_BASE + "/haudiotagger_bg.wasm";
  var JS_URL = RELEASE_BASE + "/haudiotagger.js";
  var CACHE_NAME = "haudiotagger-wasm-v" + VERSION;

  function showFallback() {
    console.warn("haudiotagger failed to auto-load WASM. Falling back to local/web.zip.");
  }

  async function cachedFetch(url) {
    if ("caches" in window) {
      try {
        var cache = await caches.open(CACHE_NAME);
        var hit = await cache.match(url);
        if (hit) return await hit.arrayBuffer();
      } catch (_) {}
    }
    var resp = await fetch(url);
    if (!resp.ok) throw new Error("Fetch failed: " + resp.status);
    var buf = await resp.arrayBuffer();
    if ("caches" in window) {
      try {
        var cache = await caches.open(CACHE_NAME);
        await cache.put(url, new Response(buf));
      } catch (_) {}
    }
    return buf;
  }

  async function init() {
    try {
      var jsBuf = await cachedFetch(JS_URL);
      var wasmBuf = await cachedFetch(WASM_URL);

      var jsBlob = new Blob([jsBuf], { type: "application/javascript" });
      var wasmBlob = new Blob([wasmBuf], { type: "application/wasm" });
      var jsBlobUrl = URL.createObjectURL(jsBlob);

      // Load JS glue — sets window.wasm_bindgen
      await new Promise(function (res, rej) {
        var s = document.createElement("script");
        s.src = jsBlobUrl;
        s.onload = res;
        s.onerror = rej;
        document.head.appendChild(s);
      });

      // Point wasm_bindgen at our cached WASM blob
      if (window.wasm_bindgen && window.wasm_bindgen.init) {
        var orig = window.wasm_bindgen.init.bind(window.wasm_bindgen);
        window.wasm_bindgen.init = function (opts) {
          opts = opts || {};
          opts.module_or_path = wasmBlob;
          return orig(opts);
        };
      }
    } catch (e) {
      console.warn("haudiotagger WASM bootstrap failed, will try local fallback:", e);
      showFallback();
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
