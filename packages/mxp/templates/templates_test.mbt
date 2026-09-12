///|
test "templates render unique non-empty paths" {
  for template in @templates.TemplateId::all() {
    let files = template.render("demo")
    let seen : Map[String, Unit] = Map([])
    for file in files {
      guard !seen.contains(file.path) else {
        fail("duplicate path \{file.path} in \{template.name()}")
      }
      seen[file.path] = ()
      guard file.content.length() > 0 else {
        fail("empty content for \{file.path}")
      }
    }
  }
}

///|
fn content_of(files : Array[@templates.TemplateFile], path : String) -> String {
  let mut found = ""
  for f in files {
    if f.path == path {
      found = f.content
    }
  }
  found
}

///|
test "vscode-basic manifest passes core validation" {
  let package_json = content_of(
    @templates.TemplateId::from_name("vscode-basic")
    .unwrap()
    .render("hello_world"),
    "package.json",
  )
  let manifest = @mxp_core.VsCodeManifest::parse(package_json)
  debug_inspect(manifest.validate(), content="[]")
  inspect(manifest.name, content="hello_world")
  inspect(manifest.publisher, content="obitare")
}

///|
test "chrome-basic manifest passes core validation" {
  let manifest_json = content_of(
    @templates.TemplateId::from_name("chrome-basic")
    .unwrap()
    .render("hello_world"),
    "manifest.json",
  )
  let manifest = @mxp_core.ChromeManifest::parse(manifest_json)
  debug_inspect(manifest.validate(), content="[]")
  inspect(manifest.manifest_version, content="3")
}
