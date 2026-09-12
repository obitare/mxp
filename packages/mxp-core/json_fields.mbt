///|
/// Field extraction helpers shared by the manifest parsers.
///
/// They live in the root package next to the public types because they
/// raise the public `ManifestError` and are the single place where JSON
/// shapes are translated into toolkit errors.

///|
fn parse_top_object(json : Json) -> Map[String, Json] raise ManifestError {
  match json {
    Object(fields) => fields
    _ =>
      raise ManifestError::InvalidJson(
        "expected a JSON object at the top level",
      )
  }
}

///|
fn require_string(
  fields : Map[String, Json],
  key : String,
) -> String raise ManifestError {
  let value = match fields.get(key) {
    Some(value) => value
    None => raise ManifestError::MissingField(field=key)
  }
  match value {
    String(s) => s
    _ =>
      raise ManifestError::InvalidField(field=key, reason="expected a string")
  }
}

///|
fn require_int(
  fields : Map[String, Json],
  key : String,
) -> Int raise ManifestError {
  let value = match fields.get(key) {
    Some(value) => value
    None => raise ManifestError::MissingField(field=key)
  }
  match value {
    Number(d, ..) => {
      let n = d.to_int()
      if n.to_double() == d {
        n
      } else {
        raise ManifestError::InvalidField(
          field=key,
          reason="expected an integer",
        )
      }
    }
    _ =>
      raise ManifestError::InvalidField(field=key, reason="expected a number")
  }
}

///|
fn require_object(
  fields : Map[String, Json],
  key : String,
) -> Map[String, Json] raise ManifestError {
  let value = match fields.get(key) {
    Some(value) => value
    None => raise ManifestError::MissingField(field=key)
  }
  match value {
    Object(nested) => nested
    _ =>
      raise ManifestError::InvalidField(field=key, reason="expected an object")
  }
}
