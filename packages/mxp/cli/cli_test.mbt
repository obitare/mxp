///|
test "parse commands" {
  debug_inspect(@cli.parse_command([]), content="Help")
  debug_inspect(@cli.parse_command(["list"]), content="List")
  debug_inspect(
    @cli.parse_command(["new", "vscode-basic", "hello_world"]),
    content=(
      #|New(template=VsCodeBasic, name="hello_world")
    ),
  )
}

///|
test "parse errors" {
  try @cli.parse_command(["new", "flutter-app", "demo"]) catch {
    @cli.CliError::UnknownTemplate(name~) =>
      inspect(name, content="flutter-app")
    _ => fail("expected UnknownTemplate")
  } noraise {
    _ => fail("expected UnknownTemplate")
  }
  try @cli.parse_command(["new", "vscode-basic"]) catch {
    @cli.CliError::MissingArguments(hint~) =>
      inspect(hint, content="usage: mxp new <template> <project-name>")
    _ => fail("expected MissingArguments")
  } noraise {
    _ => fail("expected MissingArguments")
  }
}

///|
test "project name validation" {
  try
    @cli.validate_project_name(
      @templates.TemplateId::from_name("vscode-basic").unwrap(),
      "Hello World",
    )
  catch {
    @cli.CliError::InvalidProjectName(name~) =>
      inspect(name, content="Hello World")
    _ => fail("expected InvalidProjectName")
  } noraise {
    _ => fail("expected InvalidProjectName")
  }
  try
    @cli.validate_project_name(
      @templates.TemplateId::from_name("chrome-basic").unwrap(),
      "../escape",
    )
  catch {
    @cli.CliError::InvalidProjectName(_) => ()
    _ => fail("expected InvalidProjectName")
  } noraise {
    _ => fail("expected InvalidProjectName")
  }
}
