///|
/// Parsed subset of a VSCode extension manifest (`package.json`) that the
/// toolkit cares about. Constructed via [VsCodeManifest::parse]; read the
/// public fields directly.
pub struct VsCodeManifest {
  /// Extension identifier segment, lowercase (`hello-world`).
  name : String
  /// Human-readable name (`displayName` in the manifest).
  display_name : String
  /// Extension version, `MAJOR.MINOR.PATCH`.
  version : String
  /// Publisher identifier (`obitare`).
  publisher : String
  /// Supported VSCode range (`engines.vscode`, e.g. `^1.85.0`).
  engines_vscode : String
} derive(Eq, Debug)

///|
/// Parse a VSCode extension manifest (`package.json`) from JSON text.
///
/// Only the fields the toolkit consumes are extracted; extra fields in
/// the manifest are ignored. Structural problems raise
/// [ManifestError]; semantic problems (bad version strings etc.) are
/// reported by [VsCodeManifest::validate] instead.
///
/// # Example
/// ```mbt check
/// test {
///   let m = @mxp_core.VsCodeManifest::parse(
///     (
///       #|{
///       #|  "name": "hello-world",
///       #|  "displayName": "Hello World",
///       #|  "version": "0.1.0",
///       #|  "publisher": "obitare",
///       #|  "engines": { "vscode": "^1.85.0" }
///       #|}
///     ),
///   )
///   inspect(m.publisher, content="obitare")
/// }
/// ```
pub fn VsCodeManifest::parse(
  json : String,
) -> VsCodeManifest raise ManifestError {
  let parsed = @json.parse(json) catch {
    err => raise ManifestError::InvalidJson(err.to_string())
  }
  let fields = parse_top_object(parsed)
  {
    name: require_string(fields, "name"),
    display_name: require_string(fields, "displayName"),
    version: require_string(fields, "version"),
    publisher: require_string(fields, "publisher"),
    engines_vscode: require_string(require_object(fields, "engines"), "vscode"),
  }
}
