///|
/// Semantic-version helpers used by manifest validation.
///
/// The checks are intentionally lenient about semver extras (pre-release
/// and build suffixes) because templates produced by `mxp` always emit
/// plain `MAJOR.MINOR.PATCH` versions; the goal here is to reject clearly
/// malformed values, not to fully implement semver.

///|
fn is_digits(s : StringView) -> Bool {
  s.length() > 0 && s.all(c => c is ('0'..='9'))
}

///|
/// Returns `true` if `s` is a plain `MAJOR.MINOR.PATCH` version where
/// every part is a non-empty run of digits.
///
/// # Example
/// ```mbt check
/// test {
///   assert_true(@mxp_core.is_semver("0.1.0"))
///   assert_false(@mxp_core.is_semver("0.1"))
///   assert_false(@mxp_core.is_semver("alpha"))
/// }
/// ```
pub fn is_semver(s : String) -> Bool {
  let parts = s.split(".").collect()
  parts.length() == 3 && parts.all(is_digits)
}

///|
/// Returns `true` if `s` is a Chrome extension version: one to four
/// dot-separated non-empty integer parts, optionally prefixed with a
/// leading `v`.
///
/// # Example
/// ```mbt check
/// test {
///   assert_true(@mxp_core.is_chrome_version("1.0"))
///   assert_true(@mxp_core.is_chrome_version("1.2.3.4"))
///   assert_false(@mxp_core.is_chrome_version("1.2.3.4.5"))
/// }
/// ```
pub fn is_chrome_version(s : String) -> Bool {
  let s = match s {
    [.. "v", .. rest] => rest.to_owned()
    _ => s
  }
  let parts = s.split(".").collect()
  parts.length() >= 1 && parts.length() <= 4 && parts.all(is_digits)
}

///|
/// Returns `true` if `s` is a VSCode engine range of the common
/// caret/tilde form (`^1.85.0`, `1.85.0`), which is all the toolkit
/// generates.
///
/// # Example
/// ```mbt check
/// test {
///   assert_true(@mxp_core.is_vscode_engine_range("^1.85.0"))
///   assert_false(@mxp_core.is_vscode_engine_range("latest"))
/// }
/// ```
pub fn is_vscode_engine_range(s : String) -> Bool {
  let s = match s {
    [.. "^", .. rest] | [.. "~", .. rest] => rest.to_owned()
    _ => s
  }
  is_semver(s)
}

///|
/// Returns `true` if `s` is a valid VSCode extension identifier segment:
/// lowercase letters, digits, `-`, `.` or `_`, and not empty.
///
/// # Example
/// ```mbt check
/// test {
///   assert_true(@mxp_core.is_vscode_id("hello-world"))
///   assert_false(@mxp_core.is_vscode_id("Hello World"))
/// }
/// ```
pub fn is_vscode_id(s : String) -> Bool {
  let nonempty = s.length() > 0
  nonempty && s.all(c => c is ('a'..='z' | '0'..='9' | '-' | '.' | '_'))
}
