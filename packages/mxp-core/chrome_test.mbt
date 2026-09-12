///|
test "chrome parse happy path" {
  let json =
    #|{
    #|  "manifest_version": 3,
    #|  "name": "Hello Extension",
    #|  "version": "1.0"
    #|}
  let m = @mxp_core.ChromeManifest::parse(json)
  inspect(m.name, content="Hello Extension")
  inspect(m.version, content="1.0")
}

///|
test "chrome parse requires an integer manifest_version" {
  let json =
    #|{
    #|  "manifest_version": "3",
    #|  "name": "Hello Extension",
    #|  "version": "1.0"
    #|}
  try @mxp_core.ChromeManifest::parse(json) catch {
    @mxp_core.ManifestError::InvalidField(field=f, ..) =>
      inspect(f, content="manifest_version")
    _ => fail("expected InvalidField")
  } noraise {
    _ => fail("expected InvalidField")
  }
}

///|
test "chrome validate flags manifest v2 and bad versions" {
  let json =
    #|{
    #|  "manifest_version": 2,
    #|  "name": "Hello Extension",
    #|  "version": "one.two"
    #|}
  let m = @mxp_core.ChromeManifest::parse(json)
  debug_inspect(
    m.validate(),
    content=(
      #|[
      #|  {
      #|    field: "manifest_version",
      #|    message: "only Manifest V3 (3) is supported",
      #|  },
      #|  {
      #|    field: "version",
      #|    message: "must be one to four dot-separated integers",
      #|  },
      #|]
    ),
  )
}
