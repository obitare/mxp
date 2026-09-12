///|
/// Parsed subset of a Chrome extension manifest (`manifest.json`,
/// Manifest V3) that the toolkit cares about. Constructed via
/// [ChromeManifest::parse].
pub struct ChromeManifest {
  /// Must be `3` for Manifest V3.
  manifest_version : Int
  /// Extension name as shown in the browser.
  name : String
  /// Extension version, one to four dot-separated integers.
  version : String
} derive(Eq, Debug)

///|
/// Parse a Chrome extension manifest (`manifest.json`) from JSON text.
///
/// Structural problems raise [ManifestError]; semantic problems
/// (a `manifest_version` other than 3, bad version strings) are
/// reported by [ChromeManifest::validate] instead.
///
/// # Example
/// ```mbt check
/// test {
///   let m = @mxp_core.ChromeManifest::parse(
///     (
///       #|{
///       #|  "manifest_version": 3,
///       #|  "name": "Hello Extension",
///       #|  "version": "1.0"
///       #|}
///     ),
///   )
///   inspect(m.manifest_version, content="3")
/// }
/// ```
pub fn ChromeManifest::parse(
  json : String,
) -> ChromeManifest raise ManifestError {
  let parsed = @json.parse(json) catch {
    err => raise ManifestError::InvalidJson(err.to_string())
  }
  let fields = parse_top_object(parsed)
  {
    manifest_version: require_int(fields, "manifest_version"),
    name: require_string(fields, "name"),
    version: require_string(fields, "version"),
  }
}
