///|
test "vscode parse surfaces structural errors" {
  try @mxp_core.VsCodeManifest::parse("{ not json") catch {
    @mxp_core.ManifestError::InvalidJson(_) =>
      inspect("invalid json", content="invalid json")
    _ => fail("expected InvalidJson")
  } noraise {
    _ => fail("expected InvalidJson")
  }
}

///|
test "vscode parse reports missing fields by name" {
  let json =
    #|{
    #|  "name": "hello-world"
    #|}
  try @mxp_core.VsCodeManifest::parse(json) catch {
    @mxp_core.ManifestError::MissingField(field=f) =>
      inspect(f, content="displayName")
    _ => fail("expected MissingField")
  } noraise {
    _ => fail("expected MissingField")
  }
}

///|
test "vscode parse rejects mistyped nested engines" {
  let json =
    #|{
    #|  "name": "hello-world",
    #|  "displayName": "Hello World",
    #|  "version": "0.1.0",
    #|  "publisher": "obitare",
    #|  "engines": "latest"
    #|}
  try @mxp_core.VsCodeManifest::parse(json) catch {
    @mxp_core.ManifestError::InvalidField(field=f, ..) =>
      inspect(f, content="engines")
    _ => fail("expected InvalidField")
  } noraise {
    _ => fail("expected InvalidField")
  }
}

///|
test "vscode parse ignores extra fields" {
  let json =
    #|{
    #|  "name": "hello-world",
    #|  "displayName": "Hello World",
    #|  "version": "0.1.0",
    #|  "publisher": "obitare",
    #|  "engines": { "vscode": "^1.85.0" },
    #|  "contributes": { "commands": [] }
    #|}
  let m = @mxp_core.VsCodeManifest::parse(json)
  inspect(m.validate().length(), content="0")
}
