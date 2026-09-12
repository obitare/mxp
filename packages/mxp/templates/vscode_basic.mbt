///|
/// Files for the `vscode-basic` template: a minimal VSCode extension
/// whose activation logic is written in MoonBit and compiled to JS.
fn vscode_basic_files(project_name : String) -> Array[TemplateFile] {
  let moon_mod =
    $|name = "local/\{project_name}"
    $|version = "0.1.0"
    $|license = "MIT"
    $|description = "VSCode extension '\{project_name}' written in MoonBit"
    $|
  let src_moon_pkg =
    #|options(
    #|  "link": {
    #|    "js": {
    #|      "exports": [
    #|        "activate",
    #|        "deactivate",
    #|      ],
    #|    },
    #|  },
    #|)
  let src_lib =
    #|///|
    #|/// Called by the VSCode extension host when the extension activates.
    #|pub fn activate() -> Unit {
    #|  show_information_message("Hello from a MoonBit-powered VSCode extension!")
    #|}
    #|
    #|///|
    #|/// Called by the extension host on shutdown.
    #|pub fn deactivate() -> Unit {
    #|  ()
    #|}
    #|
    #|///|
    #|extern "js" fn show_information_message(message : String) -> Unit =
    #|  "(message) => require('vscode').window.showInformationMessage(message)"
  let package_json =
    $|{
    $|  "name": "\{project_name}",
    $|  "displayName": "\{project_name}",
    $|  "description": "VSCode extension '\{project_name}' written in MoonBit",
    $|  "publisher": "obitare",
    $|  "version": "0.1.0",
    $|  "engines": {
    $|    "vscode": "^1.85.0"
    $|  },
    $|  "categories": [
    $|    "Other"
    $|  ],
    $|  "type": "module",
    $|  "main": "./_build/js/release/build/src/src.js",
    $|  "activationEvents": [],
    $|  "contributes": {
    $|    "commands": [
    $|      {
    $|        "command": "\{project_name}.hello",
    $|        "title": "Hello from MoonBit"
    $|      }
    $|    ]
    $|  }
    $|}
    $|
  let gitignore =
    #|_build/
    #|node_modules/
  let readme =
    $|# \{project_name}
    $|
    $|A VSCode extension whose activation logic is written in MoonBit.
    $|
    $|## Build
    $|
    $|Requires the MoonBit toolchain (`moon`) and `npm`.
    $|
    $|```bash
    $|moon build --target js --release
    $|```
    $|
    $|## Run in VSCode
    $|
    $|1. Open this directory in VSCode.
    $|2. Press `F5` to launch an Extension Development Host.
    $|3. Run the command palette entry "Hello from MoonBit".
    $|
    $|The extension host loads `package.json`'s `main`, which points at the
    $|ESM JS module produced by `moon build --target js --release`.
    $|
  [
    file("moon.mod", moon_mod),
    file("src/moon.pkg", src_moon_pkg),
    file("src/lib.mbt", src_lib),
    file("package.json", package_json),
    file(".gitignore", gitignore),
    file("README.md", readme),
  ]
}
