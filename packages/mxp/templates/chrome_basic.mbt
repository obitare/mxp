///|
/// Files for the `chrome-basic` template: a Manifest V3 Chrome extension
/// whose service worker logic is written in MoonBit and compiled to JS.
fn chrome_basic_files(project_name : String) -> Array[TemplateFile] {
  let moon_mod =
    $|name = "local/\{project_name}"
    $|version = "0.1.0"
    $|license = "MIT"
    $|description = "Chrome extension '\{project_name}' written in MoonBit"
    $|
  let src_moon_pkg =
    #|options(
    #|  "link": {
    #|    "js": {
    #|      "exports": [
    #|        "on_install",
    #|      ],
    #|    },
    #|  },
    #|)
  let src_lib =
    #|///|
    #|/// Runs when the service worker loads and the extension is installed
    #|/// or updated.
    #|pub fn on_install() -> Unit {
    #|  log("MoonBit service worker installed")
    #|}
    #|
    #|///|
    #|extern "js" fn log(message : String) -> Unit = "console.log"
  let manifest_json =
    $|{
    $|  "manifest_version": 3,
    $|  "name": "\{project_name}",
    $|  "description": "Chrome extension '\{project_name}' powered by MoonBit",
    $|  "version": "1.0",
    $|  "background": {
    $|    "service_worker": "service_worker.js",
    $|    "type": "module"
    $|  }
    $|}
    $|
  let service_worker_js =
    $|import { on_install } from "./_build/js/release/build/src/src.js"
    $|
    $|on_install()
    $|
  let gitignore =
    #|_build/
    #|node_modules/
  let readme =
    $|# \{project_name}
    $|
    $|A Chrome extension (Manifest V3) whose service worker is written in MoonBit.
    $|
    $|## Build
    $|
    $|Requires the MoonBit toolchain (`moon`).
    $|
    $|```bash
    $|moon build --target js --release
    $|```
    $|
    $|## Load in Chrome
    $|
    $|1. Open `chrome://extensions` and enable Developer mode.
    $|2. Click "Load unpacked" and select this directory.
    $|3. The service worker log is visible under "Inspect views: service worker".
    $|
  [
    file("moon.mod", moon_mod),
    file("src/moon.pkg", src_moon_pkg),
    file("src/lib.mbt", src_lib),
    file("manifest.json", manifest_json),
    file("service_worker.js", service_worker_js),
    file(".gitignore", gitignore),
    file("README.md", readme),
  ]
}
