///|
/// Error raised when parsing an extension manifest fails.
///
/// `parse` reports structural problems (malformed JSON, missing or
/// mistyped required fields); semantic problems such as a malformed
/// version string are reported by `validate` as `@mxp_core.Issue`s.
pub(all) suberror ManifestError {
  /// The manifest is not valid JSON.
  InvalidJson(String)
  /// A required field is absent.
  MissingField(field~ : String)
  /// A field is present but has the wrong type or shape.
  InvalidField(field~ : String, reason~ : String)
} derive(Eq, Debug)

///|
pub impl Show for ManifestError with fn output(self, logger) {
  match self {
    InvalidJson(detail) => logger <+ "invalid manifest JSON: \{detail}"
    MissingField(field~) => logger <+ "missing required field \"\{field}\""
    InvalidField(field~, reason~) =>
      logger <+ "invalid field \"\{field}\": \{reason}"
  }
}
