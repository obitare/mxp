///|
/// One semantic problem found while validating a manifest. `field` is
/// the manifest key the issue refers to (`version`, `engines.vscode`,
/// ...), `message` a human-readable explanation.
pub(all) struct Issue {
  field : String
  message : String
} derive(Eq, Debug)

///|
/// Validate the semantic rules the toolkit imposes on a VSCode manifest.
/// Structural problems are already rejected by
/// [VsCodeManifest::parse]; this returns one [Issue] per violated rule.
///
/// # Example
/// ```mbt check
/// test {
///   let m = @mxp_core.VsCodeManifest::parse(
///     (
///       #|{
///       #|  "name": "hello-world",
///       #|  "displayName": "Hello World",
///       #|  "version": "zero",
///       #|  "publisher": "obitare",
///       #|  "engines": { "vscode": "^1.85.0" }
///       #|}
///     ),
///   )
///   inspect(m.validate().length(), content="1")
/// }
/// ```
pub fn VsCodeManifest::validate(self : Self) -> Array[Issue] {
  let issues : Array[Issue] = []
  if !is_vscode_id(self.name) {
    issues.push({
      field: "name",
      message: "must be lowercase letters, digits, '-', '.' or '_'",
    })
  }
  if self.display_name is "" {
    issues.push({ field: "displayName", message: "must not be empty", })
  }
  if !is_semver(self.version) {
    issues.push({ field: "version", message: "must be MAJOR.MINOR.PATCH", })
  }
  if self.publisher is "" {
    issues.push({ field: "publisher", message: "must not be empty", })
  }
  if !is_vscode_engine_range(self.engines_vscode) {
    issues.push({
      field: "engines.vscode",
      message: "must be a semver range like ^1.85.0",
    })
  }
  issues
}

///|
/// Validate the semantic rules the toolkit imposes on a Chrome
/// Manifest V3 manifest.
///
/// # Example
/// ```mbt check
/// test {
///   let m = @mxp_core.ChromeManifest::parse(
///     (
///       #|{
///       #|  "manifest_version": 2,
///       #|  "name": "Hello Extension",
///       #|  "version": "1.0"
///       #|}
///     ),
///   )
///   inspect(m.validate().length(), content="1")
/// }
/// ```
pub fn ChromeManifest::validate(self : Self) -> Array[Issue] {
  let issues : Array[Issue] = []
  if self.manifest_version != 3 {
    issues.push({
      field: "manifest_version",
      message: "only Manifest V3 (3) is supported",
    })
  }
  if self.name is "" {
    issues.push({ field: "name", message: "must not be empty", })
  }
  if !is_chrome_version(self.version) {
    issues.push({
      field: "version",
      message: "must be one to four dot-separated integers",
    })
  }
  issues
}
